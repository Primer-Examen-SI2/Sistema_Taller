import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  // TODO: Implementar con geolocator cuando se conecte al backend
  Future<LocationData> getCurrentLocation() async {
    await Future.delayed(const Duration(seconds: 1));
    return const LocationData(
      latitude: -12.0464,
      longitude: -77.0428,
      address: 'Lima, Perú (ubicación simulada)',
    );
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final currentLocationProvider = FutureProvider<LocationData>((ref) async {
  return ref.read(locationServiceProvider).getCurrentLocation();
});
