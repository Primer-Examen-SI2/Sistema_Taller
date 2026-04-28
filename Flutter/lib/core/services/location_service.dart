import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

class LocationService {
  Future<LocationData> getCurrentLocation() async {
    // Verificar si los servicios de ubicación están habilitados
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de ubicación están deshabilitados. Activa tu GPS.');
    }

    // Verificar permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Los permisos de ubicación fueron denegados.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Los permisos de ubicación están denegados permanentes. Actívalos en configuración.');
    }

    // Obtener ubicación actual con alta precisión
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// Stream de ubicación en tiempo real para seguimiento
  Stream<LocationData> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).map((position) => LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
    ));
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final currentLocationProvider = FutureProvider<LocationData>((ref) async {
  return ref.read(locationServiceProvider).getCurrentLocation();
});
