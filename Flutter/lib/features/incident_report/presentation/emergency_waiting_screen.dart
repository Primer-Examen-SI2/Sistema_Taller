import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_cliente/core/services/location_service.dart';
import 'package:app_cliente/features/incident_report/domain/incident_model.dart';
import 'package:app_cliente/features/chat/presentation/chat_screen.dart';

class EmergencyWaitingScreen extends ConsumerStatefulWidget {
  final IncidentResponse incident;

  const EmergencyWaitingScreen({super.key, required this.incident});

  @override
  ConsumerState<EmergencyWaitingScreen> createState() => _EmergencyWaitingScreenState();
}

class _EmergencyWaitingScreenState extends ConsumerState<EmergencyWaitingScreen> {
  late Timer _simTimer;
  int _elapsedSeconds = 0;
  bool _tallerAccepted = false;
  LatLng? _currentPosition;
  StreamSubscription<LocationData>? _locationSub;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(widget.incident.latitude, widget.incident.longitude);
    _startLocationStream();
    _simTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() => _elapsedSeconds++);
      if (_elapsedSeconds == 8 && !_tallerAccepted) {
        timer.cancel();
        setState(() => _tallerAccepted = true);
      }
    });
  }

  void _startLocationStream() {
    _locationSub = ref.read(locationServiceProvider).getLocationStream().listen((loc) {
      if (!mounted) return;
      setState(() {
        _currentPosition = LatLng(loc.latitude, loc.longitude);
      });
      _mapController.move(LatLng(loc.latitude, loc.longitude), 15);
    });
  }

  @override
  void dispose() {
    _simTimer.cancel();
    _locationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userLatLng = _currentPosition ?? LatLng(widget.incident.latitude, widget.incident.longitude);

    return Scaffold(
      body: Stack(
        children: [
          // Mapa real
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLatLng,
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.app_cliente',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLatLng,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Color(0xFFD32F2F), size: 40),
                  ),
                ],
              ),
            ],
          ),

          // Contenido superpuesto
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Emergencia #${widget.incident.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                        ),
                      ),
                      if (!_tallerAccepted)
                        TextButton(
                          onPressed: _cancelEmergency,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              _BottomPanel(
                incident: widget.incident,
                tallerAccepted: _tallerAccepted,
                elapsedSeconds: _elapsedSeconds,
                onCancel: _cancelEmergency,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _cancelEmergency() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar emergencia'),
        content: const Text('¿Estás seguro de cancelar tu solicitud de emergencia?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/home');
            },
            child: const Text('Sí, cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final IncidentResponse incident;
  final bool tallerAccepted;
  final int elapsedSeconds;
  final VoidCallback onCancel;

  const _BottomPanel({
    required this.incident,
    required this.tallerAccepted,
    required this.elapsedSeconds,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),

            if (!tallerAccepted) ...[
              // Buscando taller
              _SearchingIndicator(elapsedSeconds: elapsedSeconds),
              const SizedBox(height: 16),
              Text(
                'Buscando taller cercano...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800]),
              ),
              const SizedBox(height: 4),
              Text(
                'Tu ubicación está siendo compartida en tiempo real',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              if (incident.textoAdicional != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined, size: 18, color: Color(0xFFD32F2F)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(incident.textoAdicional!, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                ),
              ],
            ] else ...[
              // Taller aceptó
              const Icon(Icons.check_circle, size: 48, color: Color(0xFF388E3C)),
              const SizedBox(height: 12),
              const Text(
                '¡Taller asignado!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF388E3C)),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1976D2).withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF1976D2).withValues(alpha: 0.1),
                          child: const Icon(Icons.build, color: Color(0xFF1976D2)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Taller Mecánico López', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Mecánica general · 2.3 km', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _InfoChip(icon: Icons.access_time, label: '~25 min'),
                        const SizedBox(width: 12),
                        _InfoChip(icon: Icons.star, label: '4.8'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatScreen(tallerNombre: 'Taller Mecánico López')),
                        );
                      },
                      icon: const Icon(Icons.chat_outlined),
                      label: const Text('Chat'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.go('/tracking');
                      },
                      icon: const Icon(Icons.track_changes),
                      label: const Text('Seguimiento'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Volver al inicio'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchingIndicator extends StatefulWidget {
  final int elapsedSeconds;
  const _SearchingIndicator({required this.elapsedSeconds});

  @override
  State<_SearchingIndicator> createState() => _SearchingIndicatorState();
}

class _SearchingIndicatorState extends State<_SearchingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Anillo expandible
              Transform.scale(
                scale: 0.5 + (_controller.value * 0.5),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD32F2F).withValues(alpha: 1 - _controller.value),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Icono central
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 28),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1976D2)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
