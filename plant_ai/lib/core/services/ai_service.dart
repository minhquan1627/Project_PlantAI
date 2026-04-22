import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img; 
import 'package:tflite_flutter/tflite_flutter.dart'; 

class AiPipelineService {
  static final AiPipelineService _instance = AiPipelineService._internal();
  factory AiPipelineService() => _instance;
  AiPipelineService._internal();

  Interpreter? _modelDet;
  Interpreter? _modelSeg;
  Interpreter? _modelCls;

  bool get isReady => _modelDet != null && _modelSeg != null && _modelCls != null;

  final Map<String, Map<String, String>> diseaseDictionary = {
    "Coffee_CoffeeLeaf_miner": {"vi_name": "Sâu vẽ bùa", "en_name": "Leaf Miner (Cà Phê)"},
    "Coffee_CoffeeLeaf_nodisease": {"vi_name": "Cây khỏe mạnh", "en_name": "Healthy (Cà Phê)"},
    "Coffee_CoffeeLeaf_phoma": {"vi_name": "Bệnh đốm đen", "en_name": "Phoma Leaf Spot (Cà Phê)"},
    "Coffee_CoffeeLeaf_rust": {"vi_name": "Bệnh gỉ sắt", "en_name": "Coffee Rust (Cà Phê)"},
    "Rice_RiceLeaf_Blast": {"vi_name": "Bệnh đạo ôn", "en_name": "Rice Blast (Lúa)"},
    "Rice_RiceLeaf_BrownSpot": {"vi_name": "Bệnh đốm nâu", "en_name": "Brown Spot (Lúa)"},
    "Rice_RiceLeaf_Healthy": {"vi_name": "Cây khỏe mạnh", "en_name": "Healthy (Lúa)"},
    "Rice_RiceLeaf_Hispa": {"vi_name": "Bọ gai hại lúa", "en_name": "Rice Hispa (Lúa)"},
    "Rice_RiceLeaf_scald": {"vi_name": "Bệnh vàng còi", "en_name": "Leaf Scald (Lúa)"}
  };

  // ==========================================
  // 1. TẢI MÔ HÌNH (Chế độ Ổn định XNNPACK)
  // ==========================================
  Future<void> loadModels() async {
    try {
      print("🚀 Đang khởi động hệ thống PlantAI Edge...");
      var options = InterpreterOptions()..threads = 2;

      _modelDet = await Interpreter.fromAsset('assets/models/leaf_ObjectDetection_int8.tflite', options: options);
      _modelSeg = await Interpreter.fromAsset('assets/models/leaf_segmentation_float16.tflite', options: options);
      _modelCls = await Interpreter.fromAsset('assets/models/leaf_Classification_int8.tflite', options: options);

      print("✅ Đã nạp xong Pipeline 3 Lớp TFLite!");
    } catch (e) {
      print("⚠️ Lỗi tải mô hình: $e");
    }
  }

  // ==========================================
  // 2. PIPELINE XỬ LÝ 3 GIAI ĐOẠN 
  // ==========================================
  Future<Map<String, dynamic>?> processPipeline(String imagePath) async {
    if (!isReady) return {"status": "error", "message": "Các mô hình chưa nạp đủ."};

    try {
      final File file = File(imagePath);
      final Uint8List bytes = await file.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) return null;

      // --- GIAI ĐOẠN 1: DETECTION ---
      print("▶️ BẮT ĐẦU GIAI ĐOẠN 1: DETECTION");
      List<int> bbox = await _runDetection(originalImage); 
      if (bbox.isEmpty) {
        return {"status": "error", "message": "❌ TỪ CHỐI: AI không tìm thấy lá cây hợp lệ!"};
      }
      int x1 = bbox[0], y1 = bbox[1], x2 = bbox[2], y2 = bbox[3];
      img.Image leafCrop = img.copyCrop(originalImage, x: x1, y: y1, width: x2 - x1, height: y2 - y1);
      
      // --- GIAI ĐOẠN 2: SEGMENTATION ---
      print("▶️ BẮT ĐẦU GIAI ĐOẠN 2: SEGMENTATION");
      img.Image pureLeaf = await _runSegmentation(leafCrop);
      int leafAreaPixels = _countLeafPixels(pureLeaf);
      print("🍀 Số pixel lá giữ lại sau tẩy nền: $leafAreaPixels");

      // 🚀 CHỐT CHẶN CUỐI CÙNG ĐỂ DIỆT CÁI CỬA GỖ
      // Cửa gỗ hoặc rác sẽ bị bôi đen thành 0 pixel -> Cấm cửa luôn!
      if (leafAreaPixels < 1500) {
        print("❌ CẢNH BÁO: Rác hoặc Cửa gỗ lọt vào. Đã bị Segmentation tiêu diệt!");
        return {"status": "error", "message": "❌ TỪ CHỐI: Khung hình không chứa cấu trúc lá cây!"};
      }

      // --- GIAI ĐOẠN 3: CLASSIFICATION ---
      print("▶️ BẮT ĐẦU GIAI ĐOẠN 3: CLASSIFICATION");
      Map<String, dynamic> clsResult = await _runClassification(pureLeaf);
      
      double confidence = clsResult['confidence'];
      String rawDiseaseName = clsResult['label'];

      if (confidence < 0.60 || rawDiseaseName == "CONFUSED") {
        return {
          "status": "error", 
          "message": "⚠️ TỪ CHỐI:\nKhông thể xác định rõ bệnh.\n(Độ tự tin: ${(confidence * 100).toStringAsFixed(1)}%)"
        };
      }

      final diseaseTranslated = diseaseDictionary[rawDiseaseName] ?? {
        "vi_name": "Chưa xác định",
        "en_name": rawDiseaseName
      };

      print("🏆 CHỐT KẾT QUẢ: ${diseaseTranslated['vi_name']}!");

      return {
        "status": "success",
        "raw_label": rawDiseaseName,
        "vi_name": diseaseTranslated["vi_name"],
        "en_name": diseaseTranslated["en_name"],
        "confidence": confidence,
        "leaf_area": leafAreaPixels,
      };

    } catch (e) {
      print("Lỗi trong Pipeline: $e");
      return {"status": "error", "message": "Lỗi hệ thống AI."};
    }
  }

  // ==========================================
  // GIAI ĐOẠN 1: DETECTION (Đã FIX lỗi Type Casting)
  // ==========================================
 Future<List<int>> _runDetection(img.Image inputImage) async {
    print("🔍 Bắt đầu chạy AI Detection (Chuẩn YOLO Letterbox)...");
    int inputSize = 640; 

    // 🚀 BƯỚC 1: LETTERBOX (Thêm viền xám chống méo hình)
    int wOrg = inputImage.width;
    int hOrg = inputImage.height;
    int maxDim = max(wOrg, hOrg);

    img.Image squareImg = img.Image(width: maxDim, height: maxDim);
    // YOLO mặc định dùng màu xám (114, 114, 114) làm phần đệm
    img.fill(squareImg, color: img.ColorRgb8(114, 114, 114));

    int padX = (maxDim - wOrg) ~/ 2;
    int padY = (maxDim - hOrg) ~/ 2;
    img.compositeImage(squareImg, inputImage, dstX: padX, dstY: padY);

    // Bây giờ mới resize ảnh vuông hoàn hảo xuống 640x640
    img.Image resizedImage = img.copyResize(squareImg, width: inputSize, height: inputSize);

    // 🚀 BƯỚC 2: TỰ ĐỘNG DÒ MA TRẬN & ÉP KIỂU
    var inputTensor = _modelDet!.getInputTensor(0);
    var inShape = inputTensor.shape;
    bool isNCHW = inShape.length == 4 && inShape[1] == 3; 

    double scale = inputTensor.params.scale == 0.0 ? 1.0 : inputTensor.params.scale;
    int zeroPoint = inputTensor.params.zeroPoint;
    String typeStr = inputTensor.type.toString().toLowerCase();

    Object inputData;

    if (typeStr.contains('int8') || typeStr.contains('uint8') || typeStr.contains('int')) {
      if (isNCHW) {
        var intInput = List.generate(1, (i) => List.generate(3, (c) => List.generate(inputSize, (y) => List.filled(inputSize, 0))));
        for (int y = 0; y < inputSize; y++) {
          for (int x = 0; x < inputSize; x++) {
            img.Pixel p = resizedImage.getPixel(x, y);
            intInput[0][0][y][x] = ((p.r / 255.0) / scale + zeroPoint).round().clamp(-128, 127);
            intInput[0][1][y][x] = ((p.g / 255.0) / scale + zeroPoint).round().clamp(-128, 127);
            intInput[0][2][y][x] = ((p.b / 255.0) / scale + zeroPoint).round().clamp(-128, 127);
          }
        }
        inputData = intInput;
      } else {
        var intInput = List.generate(1, (i) => List.generate(inputSize, (y) => List.generate(inputSize, (x) => List.filled(3, 0))));
        for (int y = 0; y < inputSize; y++) {
          for (int x = 0; x < inputSize; x++) {
            img.Pixel p = resizedImage.getPixel(x, y);
            intInput[0][y][x][0] = ((p.r / 255.0) / scale + zeroPoint).round().clamp(-128, 127);
            intInput[0][y][x][1] = ((p.g / 255.0) / scale + zeroPoint).round().clamp(-128, 127);
            intInput[0][y][x][2] = ((p.b / 255.0) / scale + zeroPoint).round().clamp(-128, 127);
          }
        }
        inputData = intInput;
      }
    } else {
      if (isNCHW) {
        var floatInput = List.generate(1, (i) => List.generate(3, (c) => List.generate(inputSize, (y) => List.filled(inputSize, 0.0))));
        for (int y = 0; y < inputSize; y++) {
          for (int x = 0; x < inputSize; x++) {
            img.Pixel p = resizedImage.getPixel(x, y);
            floatInput[0][0][y][x] = p.r / 255.0; 
            floatInput[0][1][y][x] = p.g / 255.0; 
            floatInput[0][2][y][x] = p.b / 255.0; 
          }
        }
        inputData = floatInput;
      } else {
        var floatInput = List.generate(1, (i) => List.generate(inputSize, (y) => List.generate(inputSize, (x) => List.filled(3, 0.0))));
        for (int y = 0; y < inputSize; y++) {
          for (int x = 0; x < inputSize; x++) {
            img.Pixel p = resizedImage.getPixel(x, y);
            floatInput[0][y][x][0] = p.r / 255.0; 
            floatInput[0][y][x][1] = p.g / 255.0; 
            floatInput[0][y][x][2] = p.b / 255.0; 
          }
        }
        inputData = floatInput;
      }
    }

    var outputTensor = _modelDet!.getOutputTensor(0);
    String outTypeStr = outputTensor.type.toString().toLowerCase();
    double outScale = outputTensor.params.scale == 0.0 ? 1.0 : outputTensor.params.scale;
    int outZeroPoint = outputTensor.params.zeroPoint;

    Object outputData;
    if (outTypeStr.contains('int')) {
       outputData = List.generate(1, (i) => List.generate(300, (j) => List.filled(6, 0)));
    } else {
       outputData = List.generate(1, (i) => List.generate(300, (j) => List.filled(6, 0.0)));
    }

    _modelDet!.run(inputData, outputData);

    double maxConf = 0.0;
    int bestBoxIndex = -1;
    var outList = outputData as List;

    for (int i = 0; i < 300; i++) {
      double conf = 0.0;
      if (outTypeStr.contains('int')) {
          int rawConf1 = outList[0][i][4];
          int rawConf2 = outList[0][i][5];
          conf = (max(rawConf1, rawConf2) - outZeroPoint) * outScale;
      } else {
          double conf1 = outList[0][i][4].toDouble();
          double conf2 = outList[0][i][5].toDouble();
          conf = max(conf1, conf2);
      }

      if (conf > maxConf) {
        maxConf = conf;
        bestBoxIndex = i;
      }
    }

    print("🧐 Detection tự tin: ${(maxConf * 100).toStringAsFixed(1)}%");

    if (maxConf < 0.65 || bestBoxIndex == -1) return [];

    // 🚀 BƯỚC A: TRÍCH XUẤT W VÀ H TỪ OUTPUT TRƯỚC (Để tính diện tích)
    double wRaw = 0.0, hRaw = 0.0;
    if (outTypeStr.contains('int')) {
        // Trường hợp model Quantization int8
        wRaw = (outList[0][bestBoxIndex][2] - outZeroPoint) * outScale;
        hRaw = (outList[0][bestBoxIndex][3] - outZeroPoint) * outScale;
    } else {
        // Trường hợp model Float
        wRaw = outList[0][bestBoxIndex][2].toDouble();
        hRaw = outList[0][bestBoxIndex][3].toDouble();
    }

    // Nếu tọa độ bị nén ở dạng 0.0 - 1.0, nhân lên kích thước inputSize (640)
    if (wRaw <= 2.0 && hRaw <= 2.0) {
        wRaw = wRaw * inputSize;
        hRaw = hRaw * inputSize;
    }

    // Tính toán kích thước thực tế dựa trên tỷ lệ maxDim
    double scaleFactor = maxDim / inputSize;
    double boxW = wRaw * scaleFactor;
    double boxH = hRaw * scaleFactor;

    // 🚀 BƯỚC B: BÂY GIỜ MỚI TÍNH RATIO (HẾT ĐỎ!)
    double boxAreaRatio = (boxW * boxH) / (maxDim * maxDim);

    if (boxAreaRatio < 0.10) {
      print("⚠️ TỪ CHỐI: Vật thể chiếm diện tích quá nhỏ (${ (boxAreaRatio * 100).toStringAsFixed(1) } %), khả năng cao là nhiễu.");
      return [];
    }
    
    // 🚀 BƯỚC C: TIẾP TỤC DỊCH CÁC TỌA ĐỘ CÒN LẠI (XC, YC)
    double xcRaw = 0.0, ycRaw = 0.0;
    if (outTypeStr.contains('int')) {
        xcRaw = (outList[0][bestBoxIndex][0] - outZeroPoint) * outScale;
        ycRaw = (outList[0][bestBoxIndex][1] - outZeroPoint) * outScale;
    } else {
        xcRaw = outList[0][bestBoxIndex][0].toDouble();
        ycRaw = outList[0][bestBoxIndex][1].toDouble();
    }

    if (xcRaw <= 2.0 && ycRaw <= 2.0) {
        xcRaw = xcRaw * inputSize;
        ycRaw = ycRaw * inputSize;
    }

    double boxXc = xcRaw * scaleFactor;
    double boxYc = ycRaw * scaleFactor;

    // TRỪ ĐI PHẦN VIỀN XÁM ĐỂ LẤY TỌA ĐỘ TRÊN ẢNH GỐC
    boxXc -= padX;
    boxYc -= padY;

    double x1 = boxXc - (boxW / 2);
    double y1 = boxYc - (boxH / 2);
    double x2 = boxXc + (boxW / 2);
    double y2 = boxYc + (boxH / 2);

    int padCrop = 10;
    int finalX1 = max(0, x1.toInt() - padCrop);
    int finalY1 = max(0, y1.toInt() - padCrop);
    int finalX2 = min(wOrg, x2.toInt() + padCrop);
    int finalY2 = min(hOrg, y2.toInt() + padCrop);

    return [finalX1, finalY1, finalX2, finalY2];
  }

  // ==========================================
  // GIAI ĐOẠN 2: SEGMENTATION (Đã FIX lỗi 0 Pixel)
  // ==========================================
  Future<img.Image> _runSegmentation(img.Image cropImage) async {
    int hCrop = cropImage.height;
    int wCrop = cropImage.width;
    int maxDim = max(hCrop, wCrop);
    double scale = 224.0 / maxDim;
    int newH = (hCrop * scale).toInt();
    int newW = (wCrop * scale).toInt();

    img.Image resizedCrop = img.copyResize(cropImage, width: newW, height: newH);
    int padY = (224 - newH) ~/ 2;
    int padX = (224 - newW) ~/ 2;

    double normBlackR = (0.0 - 0.485) / 0.229;
    double normBlackG = (0.0 - 0.456) / 0.224;
    double normBlackB = (0.0 - 0.406) / 0.225;

    var input = List.generate(1, (i) => List.generate(224, (y) => List.generate(224, (x) => 
        [normBlackR, normBlackG, normBlackB] 
    )));
    
    for (int y = 0; y < newH; y++) {
      for (int x = 0; x < newW; x++) {
        img.Pixel p = resizedCrop.getPixel(x, y);
        input[0][y + padY][x + padX][0] = (p.r / 255.0 - 0.485) / 0.229;
        input[0][y + padY][x + padX][1] = (p.g / 255.0 - 0.456) / 0.224;
        input[0][y + padY][x + padX][2] = (p.b / 255.0 - 0.406) / 0.225;
      }
    }

    // 🚀 ĐỘT PHÁ TẠI ĐÂY: Tự động đếm số lượng kênh Output
    var outShape = _modelSeg!.getOutputTensor(0).shape;
    int channels = outShape.last; // Sẽ là 1 hoặc 2 tùy mô hình của ông
    print("🧠 TFLite Segmentation Channels: $channels");

    Object outputData;
    if (channels == 1) {
       outputData = List.generate(1, (i) => List.generate(224, (y) => List.generate(224, (x) => List.filled(1, 0.0))));
    } else {
       outputData = List.generate(1, (i) => List.generate(224, (y) => List.generate(224, (x) => List.filled(2, 0.0))));
    }

    _modelSeg!.run(input, outputData);
    var segOut = outputData as List;

    img.Image pureLeaf = img.Image.from(cropImage); 
    
    for (int y = 0; y < hCrop; y++) {
      for (int x = 0; x < wCrop; x++) {
        int maskY = min(223, padY + (y * scale).toInt());
        int maskX = min(223, padX + (x * scale).toInt());

        bool isBackground = true;
        
        // Dịch kết quả linh hoạt theo số lượng kênh
        if (channels == 2) {
            double probBg = segOut[0][maskY][maskX][0].toDouble();
            double probLf = segOut[0][maskY][maskX][1].toDouble();
            isBackground = probBg >= probLf; // Nếu điểm Nền lớn hơn Lá -> Xóa
        } else {
            double probLf = segOut[0][maskY][maskX][0].toDouble();
            isBackground = probLf < 0.0; // Đối với 1 kênh (Logit), âm là Nền, dương là Lá
        }

        if (isBackground) {
          pureLeaf.setPixelRgba(x, y, 0, 0, 0, 255); 
        }
      }
    }
    return pureLeaf;
  }

  int _countLeafPixels(img.Image pureLeaf) {
    int count = 0;
    for (var p in pureLeaf) {
      if (p.r != 0 || p.g != 0 || p.b != 0) count++;
    }
    return count;
  }

  // ==========================================
  // GIAI ĐOẠN 3: CLASSIFICATION 
  // ==========================================
  // ==========================================
  // GIAI ĐOẠN 3: CLASSIFICATION (Đã TRẢ VỀ RGB GỐC CHUẨN)
  // ==========================================
  Future<Map<String, dynamic>> _runClassification(img.Image imageForClassify) async {
    final List<String> classNames = [
      "Coffee_CoffeeLeaf_miner",
      "Coffee_CoffeeLeaf_nodisease",
      "Coffee_CoffeeLeaf_phoma",
      "Coffee_CoffeeLeaf_rust",
      "Rice_RiceLeaf_Blast",
      "Rice_RiceLeaf_BrownSpot",
      "Rice_RiceLeaf_Healthy",
      "Rice_RiceLeaf_Hispa",
      "Rice_RiceLeaf_scald"
    ];

    // CENTER CROP - Chống méo hình
    int w = imageForClassify.width;
    int h = imageForClassify.height;
    int minDim = min(w, h);
    int cropX = (w - minDim) ~/ 2;
    int cropY = (h - minDim) ~/ 2;
    
    img.Image croppedImg = img.copyCrop(imageForClassify, x: cropX, y: cropY, width: minDim, height: minDim);
    img.Image resizedImage = img.copyResize(croppedImg, width: 224, height: 224);

    var inputTensor = _modelCls!.getInputTensor(0);
    var inShape = inputTensor.shape;
    bool isNCHW = inShape.length == 4 && inShape[1] == 3; 
    
    double scale = inputTensor.params.scale == 0.0 ? 1.0 : inputTensor.params.scale;
    int zeroPoint = inputTensor.params.zeroPoint;
    String typeStr = inputTensor.type.toString().toLowerCase();

    Object inputData;

    if (typeStr.contains('int8') || typeStr.contains('uint8') || typeStr.contains('int')) {
      if (isNCHW) {
        var intInput = List.generate(1, (i) => List.generate(3, (c) => List.generate(224, (y) => List.filled(224, 0))));
        for (int y = 0; y < 224; y++) {
          for (int x = 0; x < 224; x++) {
            img.Pixel p = resizedImage.getPixel(x, y);
            // 🚀 ĐÃ TRẢ LẠI RGB: Red -> Green -> Blue
            intInput[0][0][y][x] = ((p.r / 255.0) / scale + zeroPoint).round().clamp(-128, 127);
            intInput[0][1][y][x] = ((p.g / 255.0) / scale + zeroPoint).round().clamp(-128, 127);
            intInput[0][2][y][x] = ((p.b / 255.0) / scale + zeroPoint).round().clamp(-128, 127);
          }
        }
        inputData = intInput;
      } else {
        var intInput = List.generate(1, (i) => List.generate(224, (y) => List.generate(224, (x) => List.filled(3, 0))));
        for (int y = 0; y < 224; y++) {
          for (int x = 0; x < 224; x++) {
            img.Pixel p = resizedImage.getPixel(x, y);
            // 🚀 ĐÃ TRẢ LẠI RGB: Red -> Green -> Blue
            intInput[0][y][x][0] = ((p.r / 255.0) / scale + zeroPoint).round().clamp(-128, 127);
            intInput[0][y][x][1] = ((p.g / 255.0) / scale + zeroPoint).round().clamp(-128, 127);
            intInput[0][y][x][2] = ((p.b / 255.0) / scale + zeroPoint).round().clamp(-128, 127);
          }
        }
        inputData = intInput;
      }
    } else {
      if (isNCHW) {
        var floatInput = List.generate(1, (i) => List.generate(3, (c) => List.generate(224, (y) => List.filled(224, 0.0))));
        for (int y = 0; y < 224; y++) {
          for (int x = 0; x < 224; x++) {
            img.Pixel p = resizedImage.getPixel(x, y);
            // 🚀 ĐÃ TRẢ LẠI RGB
            floatInput[0][0][y][x] = p.r / 255.0; 
            floatInput[0][1][y][x] = p.g / 255.0; 
            floatInput[0][2][y][x] = p.b / 255.0; 
          }
        }
        inputData = floatInput;
      } else {
        var floatInput = List.generate(1, (i) => List.generate(224, (y) => List.generate(224, (x) => List.filled(3, 0.0))));
        for (int y = 0; y < 224; y++) {
          for (int x = 0; x < 224; x++) {
            img.Pixel p = resizedImage.getPixel(x, y);
            // 🚀 ĐÃ TRẢ LẠI RGB
            floatInput[0][y][x][0] = p.r / 255.0; 
            floatInput[0][y][x][1] = p.g / 255.0; 
            floatInput[0][y][x][2] = p.b / 255.0; 
          }
        }
        inputData = floatInput;
      }
    }

    var outputTensor = _modelCls!.getOutputTensor(0);
    String outTypeStr = outputTensor.type.toString().toLowerCase();
    double outScale = outputTensor.params.scale == 0.0 ? 1.0 : outputTensor.params.scale;
    int outZeroPoint = outputTensor.params.zeroPoint;
    
    Object outputData;
    if (outTypeStr.contains('int')) {
       outputData = List.generate(1, (i) => List.filled(9, 0));
    } else {
       outputData = List.generate(1, (i) => List.filled(9, 0.0));
    }

    _modelCls!.run(inputData, outputData);
    var clsOut = outputData as List;

    
    double max1 = -1.0;    // Điểm cao nhất (Top 1)
    double max2 = -1.0;    // Điểm cao thứ nhì (Top 2)
    int maxIndex = -1;
    
    print("📊 BẢNG ĐIỂM DỰ ĐOÁN TỪ AI (PHÂN TÍCH MARGIN):");

    for (int i = 0; i < 9; i++) {
      double conf = 0.0;

      // 1. TRÍCH XUẤT ĐIỂM TỪ TENSOR (GIỮ NGUYÊN LOGIC CỦA ÔNG)
      if (outTypeStr.contains('int')) {
        int rawVal = clsOut[0][i];
        conf = (rawVal - outZeroPoint) * outScale; 
      } else {
        conf = clsOut[0][i].toDouble();
      }
      
      print(" - ${classNames[i]}: ${(conf * 100).toStringAsFixed(2)}%");
      
      // 2. THUẬT TOÁN TÌM TOP 1 VÀ TOP 2
      if (conf > max1) {
        max2 = max1;   // Thằng hạng nhất cũ xuống hạng nhì
        max1 = conf;   // Cập nhật thằng hạng nhất mới
        maxIndex = i;
      } else if (conf > max2) {
        max2 = conf;   // Nếu không nhất nhưng lớn hơn nhì thì cập nhật nhì
      }
    }

    // 🚀 3. THUẬT TOÁN TỪ CHỐI (DIỆT ĐOÁN BỪA)
    // Tính khoảng cách giữa 2 lớp dẫn đầu
    double margin = max1 - max2;
    print("🧐 Khoảng cách tin cậy (Margin): ${(margin * 100).toStringAsFixed(2)}%");

    // Nếu khoảng cách quá hẹp (<15%) VÀ điểm cao nhất chưa đủ áp đảo (<80%)
    // Nghĩa là AI đang "lưỡng lự" giữa 2 kết quả -> Từ chối luôn cho an toàn.
    if (margin < 0.15 && max1 < 0.80) {
       print("⚠️ AI ĐANG ĐOÁN MÒ: Sự chênh lệch giữa các lớp quá thấp.");
       return {"label": "CONFUSED", "confidence": max1};
    }

    // Nếu vượt qua được vòng gửi xe thì trả về kết quả chuẩn
    return {"label": classNames[maxIndex], "confidence": max1};
  }
}