import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_cliente/features/incident_report/domain/incident_model.dart';
import 'package:app_cliente/features/tracking/application/tracking_provider.dart';
import 'package:app_cliente/features/incident_report/application/incident_provider.dart';
import 'package:app_cliente/features/chat/presentation/chat_screen.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(incidentProvider.notifier).loadIncidents());
  }

  @override
  Widget build(BuildContext context) {
    final incidents = ref.watch(trackingListProvider);
    final isLoading = ref.watch(incidentProvider).isLoading;

    final active = incidents.where((i) => i.status != IncidentStatus.atendido).toList();
    final history = incidents.where((i) => i.status == IncidentStatus.atendido).toList();

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (incidents.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Solicitudes')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No tienes solicitudes aún', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Reporta una emergencia para hacer seguimiento', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/report'),
                icon: const Icon(Icons.warning_amber),
                label: const Text('Reportar emergencia'),
              ),
            ],
          ),
        ),
      );
    }

    if (active.isNotEmpty) {
      return _LiveTrackingView(incident: active.first);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de solicitudes')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) => _HistoryCard(incident: history[index]),
      ),
    );
  }
}

// ============================================
// SEGUIMIENTO EN VIVO (estilo Yango)
// ============================================
class _LiveTrackingView extends ConsumerStatefulWidget {
  final IncidentResponse incident;
  const _LiveTrackingView({required this.incident});

  @override
  ConsumerState<_LiveTrackingView> createState() => _LiveTrackingViewState();
}

class _LiveTrackingViewState extends ConsumerState<_LiveTrackingView> {
  late Timer _moveTimer;
  double _mechanicProgress = 0.0;
  bool _arrived = false;

  @override
  void initState() {
    super.initState();
    if (widget.incident.status == IncidentStatus.enProceso) {
      _mechanicProgress = 0.15;
      _moveTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted) { timer.cancel(); return; }
        setState(() {
          _mechanicProgress += 0.12;
          if (_mechanicProgress >= 1.0) {
            _mechanicProgress = 1.0;
            _arrived = true;
            timer.cancel();
          }
        });
      });
    } else {
      _moveTimer = Timer.periodic(const Duration(seconds: 1), (_) {});
    }
  }

  @override
  void dispose() {
    _moveTimer.cancel();
    super.dispose();
  }

  int get _etaMinutes {
    if (_arrived) return 0;
    return ((1.0 - _mechanicProgress) * 25).round();
  }

  double get _distanceKm {
    if (_arrived) return 0.0;
    return (((1.0 - _mechanicProgress) * 2.3) * 10).round() / 10;
  }

  @override
  Widget build(BuildContext context) {
    final incident = widget.incident;
    final isPending = incident.status == IncidentStatus.pendiente;

    return Scaffold(
      body: Stack(
        children: [
          _TrackingMap(mechanicProgress: _mechanicProgress, arrived: _arrived),
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPending ? Colors.orange : const Color(0xFF388E3C),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isPending ? Icons.hourglass_top : Icons.navigation, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              isPending ? 'Buscando...' : 'En camino',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('#${incident.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              _TrackingBottomPanel(
                incident: incident,
                etaMinutes: _etaMinutes,
                distanceKm: _distanceKm,
                arrived: _arrived,
                onChat: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(tallerNombre: incident.tallerNombre ?? 'Taller Mecánico'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================
// MAPA SIMULADO CON RUTA Y MECÁNICO
// ============================================
class _TrackingMap extends StatelessWidget {
  final double mechanicProgress;
  final bool arrived;
  const _TrackingMap({required this.mechanicProgress, required this.arrived});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFE8EAF6),
      child: CustomPaint(
        painter: _TrackingMapPainter(progress: mechanicProgress, arrived: arrived),
      ),
    );
  }
}

class _TrackingMapPainter extends CustomPainter {
  final double progress;
  final bool arrived;
  _TrackingMapPainter({required this.progress, required this.arrived});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = Colors.white..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    final streetPaint = Paint()..color = Colors.white.withValues(alpha: 0.8)..strokeWidth = 4;
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.25, size.height), streetPaint);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.75, size.height), streetPaint);
    canvas.drawLine(Offset(0, size.height * 0.35), Offset(size.width, size.height * 0.35), streetPaint);
    canvas.drawLine(Offset(0, size.height * 0.65), Offset(size.width, size.height * 0.65), streetPaint);

    final userPos = Offset(size.width * 0.5, size.height * 0.75);
    final startPos = Offset(size.width * 0.2, size.height * 0.15);
    final mechanicPos = Offset.lerp(startPos, userPos, progress)!;

    // Ruta
    final routePaint = Paint()..color = const Color(0xFF1976D2)..strokeWidth = 3..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(mechanicPos.dx, mechanicPos.dy);
    final midY = (mechanicPos.dy + userPos.dy) / 2;
    path.lineTo(mechanicPos.dx, midY);
    path.lineTo(userPos.dx, midY);
    path.lineTo(userPos.dx, userPos.dy);
    canvas.drawPath(path, routePaint);

    // Puntos de ruta
    final dotPaint = Paint()..color = const Color(0xFF1976D2);
    for (final dot in [Offset(mechanicPos.dx, mechanicPos.dy), Offset(mechanicPos.dx, midY), Offset(userPos.dx, midY), Offset(userPos.dx, userPos.dy)]) {
      canvas.drawCircle(dot, 4, dotPaint);
    }

    // Mecánico
    if (!arrived) {
      final mechPaint = Paint()..color = const Color(0xFF1976D2);
      canvas.drawCircle(mechanicPos, 18, mechPaint);
      final keyPaint = Paint()..color = Colors.white..strokeWidth = 2..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(mechanicPos.dx - 4, mechanicPos.dy - 4), 5, keyPaint);
      canvas.drawLine(Offset(mechanicPos.dx, mechanicPos.dy - 2), Offset(mechanicPos.dx + 8, mechanicPos.dy + 6), keyPaint);

      final pulsePaint = Paint()..color = const Color(0xFF1976D2).withValues(alpha: 0.2)..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawCircle(mechanicPos, 28, pulsePaint);

      // Label mecánico
      final mechTP = TextPainter(text: const TextSpan(text: 'MECÁNICO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
      final mechLabelRect = Rect.fromCenter(center: Offset(mechanicPos.dx, mechanicPos.dy + 28), width: mechTP.width + 12, height: mechTP.height + 6);
      canvas.drawRRect(RRect.fromRectAndRadius(mechLabelRect, const Radius.circular(8)), Paint()..color = const Color(0xFF1976D2));
      mechTP.paint(canvas, Offset(mechLabelRect.left + 6, mechLabelRect.top + 3));
    }

    // Usuario
    final userPaint = Paint()..color = const Color(0xFFD32F2F);
    if (arrived) {
      canvas.drawCircle(userPos, 22, Paint()..color = const Color(0xFF388E3C));
      final checkStroke = Paint()..color = Colors.white..strokeWidth = 3..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(userPos.dx - 7, userPos.dy), Offset(userPos.dx - 2, userPos.dy + 5), checkStroke);
      canvas.drawLine(Offset(userPos.dx - 2, userPos.dy + 5), Offset(userPos.dx + 8, userPos.dy - 5), checkStroke);
    } else {
      canvas.drawCircle(userPos, 14, userPaint);
      canvas.drawCircle(userPos, 6, Paint()..color = Colors.white);
      canvas.drawCircle(userPos, 14, userPaint..style = PaintingStyle.stroke..strokeWidth = 3);
    }

    // Label "Tú"
    final userTP = TextPainter(text: const TextSpan(text: 'TÚ', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
    final userLabelRect = Rect.fromCenter(center: Offset(userPos.dx, userPos.dy + 24), width: userTP.width + 12, height: userTP.height + 6);
    canvas.drawRRect(RRect.fromRectAndRadius(userLabelRect, const Radius.circular(8)), Paint()..color = const Color(0xFFD32F2F));
    userTP.paint(canvas, Offset(userLabelRect.left + 6, userLabelRect.top + 3));

    // Banner
    canvas.drawRect(Rect.fromLTWH(0, 50, size.width, 28), Paint()..color = Colors.black54);
    final bannerTP = TextPainter(text: const TextSpan(text: '🗺️ Mapa simulado — Integrar Google Maps aquí', style: TextStyle(color: Colors.white, fontSize: 11)), textDirection: TextDirection.ltr)..layout();
    bannerTP.paint(canvas, Offset((size.width - bannerTP.width) / 2, 56));
  }

  @override
  bool shouldRepaint(covariant _TrackingMapPainter old) => progress != old.progress || arrived != old.arrived;
}

// ============================================
// PANEL INFERIOR
// ============================================
class _TrackingBottomPanel extends StatelessWidget {
  final IncidentResponse incident;
  final int etaMinutes;
  final double distanceKm;
  final bool arrived;
  final VoidCallback onChat;

  const _TrackingBottomPanel({
    required this.incident,
    required this.etaMinutes,
    required this.distanceKm,
    required this.arrived,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = incident.status == IncidentStatus.pendiente;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),

            if (isPending) ...[
              const Row(children: [
                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange)),
                SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Buscando mecánico cercano...', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  SizedBox(height: 2),
                  Text('Tu ubicación está siendo compartida', style: TextStyle(fontSize: 13, color: Colors.grey)),
                ])),
              ]),
              const SizedBox(height: 16),
              _IncidentInfoRow(incident: incident),
            ] else if (arrived) ...[
              const Icon(Icons.check_circle, size: 40, color: Color(0xFF388E3C)),
              const SizedBox(height: 8),
              const Text('¡El mecánico ha llegado!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF388E3C))),
              const SizedBox(height: 16),
              _MechanicCard(incident: incident),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onChat,
                icon: const Icon(Icons.chat_outlined),
                label: const Text('Chat con mecánico'),
                style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ] else ...[
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF1976D2).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    Text('$etaMinutes', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
                    const Text('min', style: TextStyle(fontSize: 12, color: Color(0xFF1976D2))),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Mecánico en camino', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.navigation, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('$distanceKm km', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('~$etaMinutes min', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ]),
                ])),
              ]),
              const SizedBox(height: 16),
              _MechanicCard(incident: incident),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: FilledButton.icon(
                  onPressed: onChat,
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Chat'),
                  style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                )),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(context),
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                )),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Cancelar solicitud'),
      content: const Text('¿Estás seguro de cancelar tu solicitud de emergencia?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
        TextButton(onPressed: () { Navigator.pop(ctx); context.go('/home'); }, child: const Text('Sí, cancelar', style: TextStyle(color: Colors.red))),
      ],
    ));
  }
}

// ============================================
// TARJETA DEL MECÁNICO
// ============================================
class _MechanicCard extends StatelessWidget {
  final IncidentResponse incident;
  const _MechanicCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1976D2).withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        CircleAvatar(radius: 24, backgroundColor: const Color(0xFF1976D2).withValues(alpha: 0.15), child: const Icon(Icons.person, size: 28, color: Color(0xFF1976D2))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(incident.tallerNombre ?? 'Mecánico', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 2),
          Row(children: [
            Icon(Icons.star, size: 14, color: Colors.amber[700]),
            const SizedBox(width: 2),
            const Text('4.8', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Icon(Icons.build_outlined, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 2),
            Text('Mecánica general', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ]),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFF388E3C).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.circle, size: 8, color: Color(0xFF388E3C)),
            SizedBox(width: 4),
            Text('Activo', style: TextStyle(fontSize: 11, color: Color(0xFF388E3C), fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }
}

// ============================================
// INFO DE LA INCIDENCIA
// ============================================
class _IncidentInfoRow extends StatelessWidget {
  final IncidentResponse incident;
  const _IncidentInfoRow({required this.incident});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.location_on, size: 16, color: Color(0xFFD32F2F)),
          const SizedBox(width: 6),
          Text('${incident.latitude.toStringAsFixed(4)}, ${incident.longitude.toStringAsFixed(4)}', style: const TextStyle(fontSize: 13)),
        ]),
        if (incident.textoAdicional != null) ...[
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.description_outlined, size: 16, color: Color(0xFFD32F2F)),
            const SizedBox(width: 6),
            Expanded(child: Text(incident.textoAdicional!, style: const TextStyle(fontSize: 13))),
          ]),
        ],
      ]),
    );
  }
}

// ============================================
// HISTORIAL
// ============================================
class _HistoryCard extends StatelessWidget {
  final IncidentResponse incident;
  const _HistoryCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Solicitud #${incident.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF388E3C).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle, size: 14, color: Color(0xFF388E3C)),
                SizedBox(width: 4),
                Text('Atendido', style: TextStyle(color: Color(0xFF388E3C), fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
          const SizedBox(height: 8),
          if (incident.tallerNombre != null) Row(children: [
            const Icon(Icons.build_outlined, size: 16, color: Color(0xFF1976D2)),
            const SizedBox(width: 6),
            Text(incident.tallerNombre!, style: const TextStyle(fontSize: 14)),
          ]),
          const SizedBox(height: 4),
          Text(_formatDate(incident.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ]),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} día${diff.inDays > 1 ? "s" : ""}';
  }
}
