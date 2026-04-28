import { Component, inject, computed, signal } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { DataService } from '../../../core/services/data.service';
import { Incident, Technician } from '../../../core/models/incident.model';

@Component({
  selector: 'app-solicitudes',
  standalone: true,
  imports: [],
  templateUrl: './solicitudes.html',
  styleUrl: './solicitudes.css',
})
export class SolicitudesComponent {
  private auth = inject(AuthService);
  private dataService = inject(DataService);
  private router = inject(Router);

  workshop = computed(() => this.auth.currentUser());
  availableIncidents = computed(() => this.dataService.getAvailableIncidents());
  acceptedIncidents = computed(() => {
    const ws = this.workshop();
    return ws ? this.dataService.getAcceptedIncidents(ws.id) : [];
  });

  selectedIncident = signal<Incident | null>(null);
  showAssignModal = signal(false);
  selectedTechnicianId = signal('');
  filterPriority = signal<string>('all');

  filteredIncidents = computed(() => {
    const filter = this.filterPriority();
    const incidents = this.availableIncidents();
    if (filter === 'all') return incidents;
    return incidents.filter(i => i.priority === filter);
  });

  availableTechnicians = computed(() => {
    const ws = this.workshop();
    if (!ws) return [];
    return ws.technicians.filter(t => t.isAvailable);
  });

  selectIncident(incident: Incident): void {
    this.selectedIncident.set(incident);
  }

  viewIncident(incidentId: string): void {
    this.router.navigate(['/dashboard/solicitudes', incidentId]);
  }

  closeDetail(): void {
    this.selectedIncident.set(null);
  }

  openAssignModal(incident: Incident): void {
    this.selectedIncident.set(incident);
    this.selectedTechnicianId.set('');
    this.showAssignModal.set(true);
  }

  closeAssignModal(): void {
    this.showAssignModal.set(false);
    this.selectedTechnicianId.set('');
  }

  selectTechnician(techId: string): void {
    this.selectedTechnicianId.set(techId);
  }

  acceptIncident(): void {
    const incident = this.selectedIncident();
    const ws = this.workshop();
    const techId = this.selectedTechnicianId();
    if (incident && ws && techId) {
      this.dataService.acceptIncident(incident.id, ws.id, techId);
      this.closeAssignModal();
      this.closeDetail();
    }
  }

  rejectIncident(incidentId: string): void {
    this.dataService.rejectIncident(incidentId);
    this.closeDetail();
  }

  setFilter(priority: string): void {
    this.filterPriority.set(priority);
  }

  getTypeLabel(type: string): string {
    const labels: Record<string, string> = {
      mechanical: 'Mecánica',
      tire: 'Llanta',
      battery: 'Batería',
      overheating: 'Sobrecalentamiento',
      accident: 'Accidente',
      lockout: 'Llaves',
      other: 'Otro',
    };
    return labels[type] || type;
  }

  getPriorityLabel(priority: string): string {
    const labels: Record<string, string> = {
      critical: 'Crítica',
      high: 'Alta',
      medium: 'Media',
      low: 'Baja',
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

  getPriorityDot(priority: string): string {
    switch (priority) {
      case 'critical': return 'bg-red-500';
      case 'high': return 'bg-orange-500';
      case 'medium': return 'bg-yellow-500';
      case 'low': return 'bg-green-500';
      default: return 'bg-slate-500';
    }
  }

  getStatusLabel(status: string): string {
    const labels: Record<string, string> = {
      pending: 'Pendiente',
      accepted: 'Aceptada',
      in_progress: 'En Progreso',
      completed: 'Completada',
      rejected: 'Rechazada',
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

  formatTime(date: Date): string {
    return new Date(date).toLocaleTimeString('es-PE', { hour: '2-digit', minute: '2-digit' });
  }
}
