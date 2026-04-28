import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_cliente/features/vehicles/domain/vehicle_model.dart';

class VehiclesState {
  final List<VehicleResponse> vehicles;
  final bool isLoading;
  final String? errorMessage;

  const VehiclesState({
    this.vehicles = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  VehiclesState copyWith({
    List<VehicleResponse>? vehicles,
    bool? isLoading,
    String? errorMessage,
  }) {
    return VehiclesState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class VehiclesNotifier extends StateNotifier<VehiclesState> {
  VehiclesNotifier() : super(const VehiclesState());

  Future<void> loadVehicles() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    // Datos mock
    state = VehiclesState(
      vehicles: [
        VehicleResponse(id: 1, placa: 'ABC-123', marca: 'Toyota', modelo: 'Corolla', color: 'Blanco', anio: 2020, userId: 1),
        VehicleResponse(id: 2, placa: 'DEF-456', marca: 'Honda', modelo: 'Civic', color: 'Negro', anio: 2022, userId: 1),
      ],
    );
  }

  Future<bool> addVehicle(VehicleCreate vehicle) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    final newVehicle = VehicleResponse(
      id: state.vehicles.length + 1,
      placa: vehicle.placa,
      marca: vehicle.marca,
      modelo: vehicle.modelo,
      color: vehicle.color,
      anio: vehicle.anio,
      userId: vehicle.userId,
    );
    state = state.copyWith(
      vehicles: [...state.vehicles, newVehicle],
      isLoading: false,
    );
    return true;
  }

  Future<bool> deleteVehicle(int id) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      vehicles: state.vehicles.where((v) => v.id != id).toList(),
      isLoading: false,
    );
    return true;
  }
}

final vehiclesProvider = StateNotifierProvider<VehiclesNotifier, VehiclesState>((ref) {
  return VehiclesNotifier();
});
