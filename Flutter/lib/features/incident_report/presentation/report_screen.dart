// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_cliente/core/services/location_service.dart';
import 'package:app_cliente/core/services/camera_service.dart';
import 'package:app_cliente/core/services/audio_service.dart';
import 'package:app_cliente/features/incident_report/domain/incident_model.dart';
import 'package:app_cliente/features/incident_report/application/incident_provider.dart';
import 'package:app_cliente/features/vehicles/application/vehicle_provider.dart';
import 'package:app_cliente/shared/widgets/custom_button.dart';
import 'package:app_cliente/shared/widgets/custom_text_field.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _textoCtrl = TextEditingController();
  LocationData? _location;
  String? _photoUrl;
  String? _audioUrl;
  bool _isRecording = false;
  bool _isSending = false;
  int? _selectedVehicleId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _textoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await ref.read(vehiclesProvider.notifier).loadVehicles();
  }

  Future<void> _pickPhoto() async {
    final photo = await ref.read(cameraServiceProvider).pickImage();
    
    if (!context.mounted) return;
    
    if (photo != null) {
      setState(() => _photoUrl = photo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto adjuntada (simulado)'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _takePhoto() async {
    final photo = await ref.read(cameraServiceProvider).takePhoto();
    
    if (!context.mounted) return;
    
    if (photo != null) {
      setState(() => _photoUrl = photo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto capturada (simulado)'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _toggleRecording() async {
    final audioService = ref.read(audioServiceProvider);
    if (_isRecording) {
      final audioPath = await audioService.stopRecording();
      
      if (!context.mounted) return;

      setState(() {
        _isRecording = false;
        _audioUrl = audioPath;
      });
      if (audioPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio grabado (simulado)'), behavior: SnackBarBehavior.floating),
        );
      }
    } else {
      await audioService.startRecording();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _submitReport() async {
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un vehículo'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    // Obtener ubicación en tiempo real al momento de enviar
    setState(() => _isSending = true);
    final loc = await ref.read(locationServiceProvider).getCurrentLocation();
    _location = loc;

    final incident = IncidentCreate(
      latitude: _location!.latitude,
      longitude: _location!.longitude,
      photoUrl: _photoUrl,
      audioUrl: _audioUrl,
      textoAdicional: _textoCtrl.text.trim().isEmpty ? null : _textoCtrl.text.trim(),
      vehicleId: _selectedVehicleId!,
      userId: 1, // TODO: obtener del auth
    );

    final success = await ref.read(incidentProvider.notifier).createIncident(incident);

    if (!context.mounted) return;

    setState(() => _isSending = false);
    if (success) {
      final createdIncident = ref.read(incidentProvider).incidents.first;
      context.go('/emergency-waiting/${createdIncident.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(vehiclesProvider).vehicles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Emergencia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de emergencia
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD32F2F).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reporta tu emergencia vehicular. Adjunta la información necesaria para una atención rápida.',
                      style: TextStyle(fontSize: 14, color: Color(0xFFB71C1C)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Vehículo
            const Text('Vehículo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              initialValue: _selectedVehicleId,
              decoration: const InputDecoration(
                hintText: 'Selecciona tu vehículo',
                prefixIcon: Icon(Icons.directions_car_outlined),
              ),
              items: vehicles.map((v) {
                return DropdownMenuItem(
                  value: v.id,
                  child: Text('${v.marca} ${v.modelo} - ${v.placa}'),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedVehicleId = v),
            ),
            const SizedBox(height: 20),

            // Ubicación automática
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF388E3C).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.gps_fixed, color: Color(0xFF388E3C)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ubicación automática', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF388E3C))),
                        SizedBox(height: 2),
                        Text('Se enviará tu ubicación en tiempo real al reportar', style: TextStyle(fontSize: 12, color: Color(0xFF66BB6A))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Foto
            const Text('Foto del vehículo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galería'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Cámara'),
                  ),
                ),
              ],
            ),
            if (_photoUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Chip(
                  avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  label: Text(_photoUrl!, style: const TextStyle(fontSize: 12)),
                  onDeleted: () => setState(() => _photoUrl = null),
                ),
              ),
            const SizedBox(height: 20),

            // Audio
            const Text('Audio describiendo el problema', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _toggleRecording,
                icon: Icon(_isRecording ? Icons.stop : Icons.mic_outlined,
                    color: _isRecording ? Colors.red : null),
                label: Text(
                  _isRecording ? 'Detener grabación' : (_audioUrl != null ? 'Grabar de nuevo' : 'Grabar audio'),
                ),
                style: _isRecording
                    ? OutlinedButton.styleFrom(foregroundColor: Colors.red)
                    : null,
              ),
            ),
            if (_audioUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Chip(
                  avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  label: Text(_audioUrl!, style: const TextStyle(fontSize: 12)),
                  onDeleted: () => setState(() => _audioUrl = null),
                ),
              ),
            if (_isRecording)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('Grabando...', style: TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Texto adicional
            CustomTextField(
              label: 'Texto adicional (opcional)',
              hint: 'Describe tu problema con más detalle...',
              controller: _textoCtrl,
              maxLines: 3,
            ),
            const SizedBox(height: 28),

            // Enviar
            CustomButton(
              text: 'ENVIAR EMERGENCIA',
              onPressed: _submitReport,
              isLoading: _isSending,
              color: const Color(0xFFD32F2F),
            ),
          ],
        ),
      ),
    );
  }
}