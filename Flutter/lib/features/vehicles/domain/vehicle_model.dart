class VehicleCreate {
  final String placa;
  final String marca;
  final String modelo;
  final String color;
  final int anio;
  final int userId;

  VehicleCreate({
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.color,
    required this.anio,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'placa': placa,
        'marca': marca,
        'modelo': modelo,
        'color': color,
        'anio': anio,
        'user_id': userId,
      };
}

class VehicleResponse {
  final int id;
  final String placa;
  final String marca;
  final String modelo;
  final String color;
  final int anio;
  final int userId;

  VehicleResponse({
    required this.id,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.color,
    required this.anio,
    required this.userId,
  });

  factory VehicleResponse.fromJson(Map<String, dynamic> json) => VehicleResponse(
        id: json['id'],
        placa: json['placa'],
        marca: json['marca'],
        modelo: json['modelo'],
        color: json['color'],
        anio: json['anio'],
        userId: json['user_id'],
      );
}
