import { Component, inject, computed, signal } from '@angular/core';
import { AuthService } from '../../../core/services/auth.service';
import { DataService } from '../../../core/services/data.service';
import { ServiceStatus } from '../../../core/models/incident.model';

@Component({
  selector: 'app-operacion',
  standalone: true,
  imports: [],
  templateUrl: './operacion.html',
  styleUrl: './operacion.css',
})
export class OperacionComponent {
  private auth = inject(AuthService);
  private dataService = inject(DataService);

  workshop = computed(() => this.auth.currentUser());
  technicians = computed(() => {
    const ws = this.workshop();
    return ws ? ws.technicians : [];
  });
  acceptedIncidents = computed(() => {
    const ws = this.workshop();
    return ws ? this.dataService.getAcceptedIncidents(ws.id) : [];
  });

  activeTab = signal<'services' | 'technicians'>('services');

  toggleTechnicianAvailability(techId: string): void {
    this.dataService.toggleTechnicianAvailability(techId);
  }

  updateIncidentStatus(incidentId: string, status: ServiceStatus): void {
    this.dataService.updateIncidentStatus(incidentId, status);
  }

  getTypeLabel(type: string): string {
    const labels: Record<string, string> = {
      mechanical: 'Mecánica', tire: 'Llanta', battery: 'Batería',
      overheating: 'Sobrecalentamiento', accident: 'Accidente',
      lockout: 'Llaves', other: 'Otro',
    };
    return labels[type] || type;
  }

  getStatusLabel(status: string): string {
    const labels: Record<string, string> = {
      pending: 'Pendiente', accepted: 'Aceptada', in_progress: 'En Progreso',
      completed: 'Completada', rejected: 'Rechazada',
    };
    return labels[status] || status;
  }

  getStatusBg(status: string): string {
    switch (status) {
      case 'pending': return 'bg-yellow-500/20 text-yellow-400';
      case 'accepted': return 'bg-blue-500/20 text-blue-400';
      case 'in_progress': return 'bg-amber-500/20 text-amber-400';
      case 'completed': return 'bg-green-500/20 text-green-400';
      case 'rejected': return 'bg-red-500/20 text-red-400';
      default: return 'bg-slate-500/20 text-slate-400';
    }
  }

  getPriorityLabel(priority: string): string {
    const labels: Record<string, string> = {
      critical: 'Crítica', high: 'Alta', medium: 'Media', low: 'Baja',
    };
    return labels[priority] || priority;
  }

  getPriorityBg(priority: string): string {
    switch (priority) {
      case 'critical': return 'bg-red-500/20 text-red-400 border-red-500/30';
      case 'high': return 'bg-orange-500/20 text-orange-400 border-orange-500/30';
      case 'medium': return 'bg-yellow-500/20 text-yellow-400 border-yellow-500/30';
      case 'low': return 'bg-green-500/20 text-green-400 border-green-500/30';
      default: return 'bg-slate-500/20 text-slate-400 border-slate-500/30';
    }
  }

  getTechName(techId: string | undefined): string {
    if (!techId) return 'Sin asignar';
    const tech = this.technicians().find(t => t.id === techId);
    return tech ? tech.name : 'Desconocido';
  }
}
