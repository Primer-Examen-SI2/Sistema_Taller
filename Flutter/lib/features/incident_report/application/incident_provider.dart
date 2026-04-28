import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_cliente/features/incident_report/domain/incident_model.dart';

class IncidentState {
  final List<IncidentResponse> incidents;
  final bool isLoading;
  final String? errorMessage;

  const IncidentState({
    this.incidents = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  IncidentState copyWith({
    List<IncidentResponse>? incidents,
    bool? isLoading,
    String? errorMessage,
  }) {
    return IncidentState(
      incidents: incidents ?? this.incidents,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class IncidentNotifier extends StateNotifier<IncidentState> {
  IncidentNotifier() : super(const IncidentState());

  Future<void> loadIncidents() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = IncidentState(
      incidents: [
        IncidentResponse(
          id: 1,
          latitude: -12.0464,
          longitude: -77.0428,
          photoUrl: 'foto_1.jpg',
          textoAdicional: 'Pinchazón de llanta en carretera',
          priority: IncidentPriority.alta,
          status: IncidentStatus.enProceso,
          vehicleId: 1,
          userId: 1,
          tallerNombre: 'Taller Mecánico López',
          tallerId: 1,
          tiempoEstimado: '25 min',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        IncidentResponse(
          id: 2,
          latitude: -12.0550,
          longitude: -77.0380,
          textoAdicional: 'Batería descargada',
          priority: IncidentPriority.media,
          status: IncidentStatus.pendiente,
          vehicleId: 2,
          userId: 1,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        IncidentResponse(
          id: 3,
          latitude: -12.0400,
          longitude: -77.0500,
          photoUrl: 'foto_2.jpg',
          audioUrl: 'audio_2.mp3',
          textoAdicional: 'Sobrecalentamiento del motor',
          priority: IncidentPriority.critica,
          status: IncidentStatus.atendido,
          vehicleId: 1,
          userId: 1,
          tallerNombre: 'AutoFix Express',
          tallerId: 2,
          tiempoEstimado: null,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );
  }

  Future<bool> createIncident(IncidentCreate incident) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    final newIncident = IncidentResponse(
      id: state.incidents.length + 1,
      latitude: incident.latitude,
      longitude: incident.longitude,
      photoUrl: incident.photoUrl,
      audioUrl: incident.audioUrl,
      textoAdicional: incident.textoAdicional,
      priority: IncidentPriority.media,
      status: IncidentStatus.pendiente,
      vehicleId: incident.vehicleId,
      userId: incident.userId,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      incidents: [newIncident, ...state.incidents],
      isLoading: false,
    );
    return true;
  }
}

final incidentProvider = StateNotifierProvider<IncidentNotifier, IncidentState>((ref) {
  return IncidentNotifier();
});
