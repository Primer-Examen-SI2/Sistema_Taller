import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_cliente/features/incident_report/domain/incident_model.dart';
import 'package:app_cliente/features/incident_report/application/incident_provider.dart';

final trackingListProvider = Provider<List<IncidentResponse>>((ref) {
  return ref.watch(incidentProvider).incidents;
});
