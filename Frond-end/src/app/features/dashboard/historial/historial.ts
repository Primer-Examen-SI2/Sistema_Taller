import { Component, inject, computed, signal } from '@angular/core';
import { AuthService } from '../../../core/services/auth.service';
import { DataService } from '../../../core/services/data.service';

@Component({
  selector: 'app-historial',
  standalone: true,
  imports: [],
  templateUrl: './historial.html',
  styleUrl: './historial.css',
})
export class HistorialComponent {
  private auth = inject(AuthService);
  private dataService = inject(DataService);

  workshop = computed(() => this.auth.currentUser());
  history = computed(() => {
    const ws = this.workshop();
    return ws ? this.dataService.getHistoryForWorkshop(ws.id) : [];
  });

  filterType = signal<string>('all');

  filteredHistory = computed(() => {
    const filter = this.filterType();
    const h = this.history();
    if (filter === 'all') return h;
    return h.filter(item => item.incidentType === filter);
  });

  totalRevenue = computed(() => this.history().reduce((sum, h) => sum + h.cost, 0));
  totalCommission = computed(() => this.history().reduce((sum, h) => sum + h.commission, 0));
  totalServices = computed(() => this.history().length);

  setFilter(type: string): void {
    this.filterType.set(type);
  }

  getTypeLabel(type: string): string {
    const labels: Record<string, string> = {
      mechanical: 'Mecánica', tire: 'Llanta', battery: 'Batería',
      overheating: 'Sobrecalentamiento', accident: 'Accidente',
      lockout: 'Llaves', other: 'Otro',
    };
    return labels[type] || type;
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

  formatDate(date: Date): string {
    return new Date(date).toLocaleDateString('es-PE', { day: '2-digit', month: 'short', year: 'numeric' });
  }
}
