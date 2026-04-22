import 'package:mongo_dart/mongo_dart.dart';
class ScanRecord {
  final String? id;
  final String userId;
  final String plantName;
  final String diseaseVi;
  final String diseaseEn;
  final double confidence;
  final String imagePath;
  final DateTime createdAt;
  final String? gardenId;
  String? gardenName;

  ScanRecord({
    this.id,
    required this.userId,
    required this.plantName,
    required this.diseaseVi,
    required this.diseaseEn,
    required this.confidence,
    required this.imagePath,
    required this.createdAt,
    this.gardenId,
    this.gardenName,
  });

  // Chuyển Object thành Map để MongoDB hiểu
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'plant_name': plantName,
      'disease_vi': diseaseVi,
      'disease_en': diseaseEn,
      'confidence': confidence,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'garden_id': gardenId,
      'garden_name': gardenName,
    };
  }

  // Chuyển từ dữ liệu MongoDB ngược lại thành Object
  factory ScanRecord.fromMap(Map<String, dynamic> map) {
    return ScanRecord(
      id: map['_id'] != null ? (map['_id'] as ObjectId).toHexString() : null,
      userId: map['user_id'] ?? '',
      plantName: map['plant_name'] ?? '',
      diseaseVi: map['disease_vi'] ?? '',
      diseaseEn: map['disease_en'] ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      imagePath: map['image_path'] ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      gardenId: map['garden_id']?.toString(),
      gardenName: map['gardenName'],
    );
  }
}