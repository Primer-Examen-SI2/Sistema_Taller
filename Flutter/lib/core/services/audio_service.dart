import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioService {
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  // TODO: Implementar con record/flutter_sound cuando se conecte al backend
  Future<void> startRecording() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isRecording = true;
  }

  Future<String?> stopRecording() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isRecording = false;
    return 'audio_simulado_${DateTime.now().millisecondsSinceEpoch}.mp3';
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});
