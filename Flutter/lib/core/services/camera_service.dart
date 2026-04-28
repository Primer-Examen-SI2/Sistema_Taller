import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraService {
  // TODO: Implementar con image_picker cuando se conecte al backend
  Future<String?> pickImage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Retorna URL simulada de foto
    return 'foto_simulada_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  Future<String?> takePhoto() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'foto_camara_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }
}

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});
