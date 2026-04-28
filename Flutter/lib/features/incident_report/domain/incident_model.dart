import 'package:flutter/material.dart';

enum IncidentPriority { baja, media, alta, critica }

enum IncidentStatus { pendiente, enProceso, atendido }

class IncidentCreate {
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final String? audioUrl;
  final String? textoAdicional;
  final int vehicleId;
  final int userId;

  IncidentCreate({
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    this.audioUrl,
    this.textoAdicional,
    required this.vehicleId,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'photo_url': photoUrl,
        'audio_url': audioUrl,
        'texto_adicional': textoAdicional,
        'vehicle_id': vehicleId,
        'user_id': userId,
      };
}

class IncidentResponse {
  final int id;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final String? audioUrl;
  final String? textoAdicional;
  final IncidentPriority priority;
  final IncidentStatus status;
  final int vehicleId;
  final int userId;
  final String? tallerNombre;
  final int? tallerId;
  final String? tiempoEstimado;
  final DateTime createdAt;

  IncidentResponse({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    this.audioUrl,
    this.textoAdicional,
    this.priority = IncidentPriority.media,
    this.status = IncidentStatus.pendiente,
    required this.vehicleId,
    required this.userId,
    this.tallerNombre,
    this.tallerId,
    this.tiempoEstimado,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get statusLabel {
    switch (status) {
      case IncidentStatus.pendiente: return 'Pendiente';
      case IncidentStatus.enProceso: return 'En Proceso';
      case IncidentStatus.atendido: return 'Atendido';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case IncidentPriority.baja: return 'Baja';
      case IncidentPriority.media: return 'Media';
      case IncidentPriority.alta: return 'Alta';
      case IncidentPriority.critica: return 'Crítica';
    }
  }

  Color get statusColor {
    switch (status) {
      case IncidentStatus.pendiente: return const Color(0xFFFFA000);
      case IncidentStatus.enProceso: return const Color(0xFF1976D2);
      case IncidentStatus.atendido: return const Color(0xFF388E3C);
    }
  }

  Color get priorityColor {
    switch (priority) {
      case IncidentPriority.baja: return const Color(0xFF4CAF50);
      case IncidentPriority.media: return const Color(0xFFFFA000);
      case IncidentPriority.alta: return const Color(0xFFFF5722);
      case IncidentPriority.critica: return const Color(0xFFD32F2F);
    }
  }
}
