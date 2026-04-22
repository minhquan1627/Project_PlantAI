class GardenModel {
  final String? id;
  final String userId;
  final String name;
  final String location;
  final double area;
  final String soilType;
  final List<String> crops; // Danh sách các loại cây trồng
  final DateTime createdAt;
  final double humidity;    
  final double temperature;
  final double? latitude;
  final double? longitude;

  GardenModel({
    this.id,
    required this.userId,
    required this.name,
    required this.location,
    required this.area,
    required this.soilType,
    required this.crops,
    required this.createdAt,
    this.humidity = 0.0,    // Mặc định nếu DB chưa có
    this.temperature = 0.0,
    this.latitude,  
    this.longitude,
  });

  // Chuyển sang Map để lưu vào MongoDB
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'location': location,
      'area': area,
      'soil_type': soilType,
      'crops': crops,
      'created_at': createdAt.toIso8601String(),
      'humidity': humidity,    
      'temperature': temperature,
      'latitude': latitude,   // Lưu xuống DB
      'longitude': longitude,
    };
  }

  // Tạo Object từ Map của MongoDB
  factory GardenModel.fromMap(Map<String, dynamic> map) {
    return GardenModel(
      id: map['_id']?.toString(),
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      area: (map['area'] as num?)?.toDouble() ?? 0.0,
      soilType: map['soil_type'] ?? '',
      crops: List<String>.from(map['crops'] ?? []),
      createdAt: DateTime.parse(map['created_at']),
      humidity: (map['humidity'] as num?)?.toDouble() ?? 0.0,
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }
}