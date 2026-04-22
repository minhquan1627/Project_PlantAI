import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkManager {
  // Tạo Singleton (Chỉ có 1 instance duy nhất trong toàn app)
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;
  NetworkManager._internal();

  // Biến Stream để các màn hình lắng nghe sự thay đổi
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  Stream<bool> get onStatusChange => _controller.stream;

  // Hàm kiểm tra mạng hiện tại (trả về true nếu Offline)
  Future<bool> isOffline() async {
    final result = await _connectivity.checkConnectivity();
    // Logic mới của bản 6.0: result là List
    return result.contains(ConnectivityResult.none);
  }

  // Bắt đầu lắng nghe mạng (Gọi hàm này ở main.dart)
  void initialize() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isOffline = result.contains(ConnectivityResult.none);
      _controller.add(isOffline); // Báo tin cho toàn app biết
      print("📡 Trạng thái mạng thay đổi: ${isOffline ? 'Mất mạng' : 'Có mạng'}");
    });
  }
}