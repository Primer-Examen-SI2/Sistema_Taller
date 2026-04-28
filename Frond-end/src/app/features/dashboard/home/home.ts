import { Component, inject, computed } from '@angular/core';
import { AuthService } from '../../../core/services/auth.service';
import { DataService } from '../../../core/services/data.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [],
  templateUrl: './home.html',
  styleUrl: './home.css',
})
export class HomeComponent {
  private auth = inject(AuthService);
  private dataService = inject(DataService);
  private router = inject(Router);

  workshop = computed(() => this.auth.currentUser());
  availableIncidents = computed(() => this.dataService.getAvailableIncidents());
  acceptedIncidents = computed(() => {
    const ws = this.workshop();
    return ws ? this.dataService.getAcceptedIncidents(ws.id) : [];
  });
  technicians = computed(() => {
    const ws = this.workshop();
    return ws ? ws.technicians : [];
  });
  availableTechnicians = computed(() => this.technicians().filter(t => t.isAvailable));

  criticalCount = computed(() => this.availableIncidents().filter(i => i.priority === 'critical').length);
  highCount = computed(() => this.availableIncidents().filter(i => i.priority === 'high').length);

  goToSolicitudes(): void {
    this.router.navigate(['/dashboard/solicitudes']);
  }

  getPriorityBg(priority: string): string {
    switch (priority) {
      case 'critical': return 'bg-red-500';
      case 'high': return 'bg-orange-500';
      case 'medium': return 'bg-yellow-500';
      case 'low': return 'bg-green-500';
      default: return 'bg-slate-500';
    }
  }

  getPriorityText(priority: string): string {
    switch (priority) {
      case 'critical': return 'text-red-400';
      case 'high': return 'text-orange-400';
      case 'medium': return 'text-yellow-400';
      case 'low': return 'text-green-400';
      default: return 'text-slate-400';
    }
  }
}
