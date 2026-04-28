import { Component, inject, computed, signal, OnInit, OnDestroy, AfterViewInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { DataService } from '../../../core/services/data.service';
import { Incident, Technician, ServiceStatus } from '../../../core/models/incident.model';
import L from 'leaflet';

@Component({
  selector: 'app-incident-detail',
  standalone: true,
  imports: [],
  templateUrl: './incident-detail.html',
  styleUrl: './incident-detail.css',
})
export class IncidentDetailComponent implements OnInit, AfterViewInit, OnDestroy {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private auth = inject(AuthService);
  private dataService = inject(DataService);

  workshop = computed(() => this.auth.currentUser());
  incident = signal<Incident | null>(null);
  showAssignModal = signal(false);
  selectedTechnicianId = signal('');

  private map: L.Map | null = null;
  private incidentMarker: L.Marker | null = null;
  private techMarkers: L.Marker[] = [];

  specialtyOptions: { value: string; label: string }[] = [
    { value: 'mechanical', label: 'Mecánica general' },
    { value: 'tire', label: 'Llantas' },
    { value: 'battery', label: 'Batería' },
    { value: 'overheating', label: 'Sobrecalentamiento' },
    { value: 'accident', label: 'Accidentes' },
    { value: 'lockout', label: 'Apertura de llaves' },
    { value: 'other', label: 'Otro' },
  ];

  availableTechnicians = computed(() => {
    const ws = this.workshop();
    if (!ws) return [];
    return ws.technicians.filter(t => t.isAvailable);
  });

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      const inc = this.dataService.getIncidentById(id);
      if (inc) {
        this.incident.set(inc);
      } else {
        this.router.navigate(['/dashboard/solicitudes']);
      }
    }
  }

  ngAfterViewInit(): void {
    setTimeout(() => this.initMap(), 100);
  }

  ngOnDestroy(): void {
    if (this.map) {
      this.map.remove();
      this.map = null!;
    }
  }

  initMap(): void {
    const inc = this.incident();
    if (!inc) return;

    const mapEl = document.getElementById('incident-map');
    if (!mapEl) return;

    const map = L.map(mapEl, {
      center: [inc.location.lat, inc.location.lng],
      zoom: 14,
      zoomControl: true,
    });
    this.map = map;

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors',
      maxZoom: 19,
    }).addTo(map);

    const incidentIcon = L.divIcon({
      className: 'custom-div-icon',
      html: `<div style="background-color: #ef4444; width: 24px; height: 24px; border-radius: 50%; border: 3px solid white; box-shadow: 0 2px 8px rgba(0,0,0,0.4); display: flex; align-items: center; justify-content: center;">
        <svg width="12" height="12" viewBox="0 0 24 24" fill="white" stroke="none"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg>
      </div>`,
      iconSize: [24, 24],
      iconAnchor: [12, 12],
    });

    this.incidentMarker = L.marker([inc.location.lat, inc.location.lng], { icon: incidentIcon })
      .addTo(map)
      .bindPopup(`<strong>🚨 Emergencia</strong><br>${inc.location.address}<br><em>${inc.userName}</em>`);

    // Add technician markers
    const ws = this.workshop();
    if (ws) {
      ws.technicians.forEach(tech => {
        const techIcon = L.divIcon({
          className: 'custom-div-icon',
          html: `<div style="background-color: ${tech.isAvailable ? '#22c55e' : '#64748b'}; width: 20px; height: 20px; border-radius: 50%; border: 2px solid white; box-shadow: 0 2px 6px rgba(0,0,0,0.3); display: flex; align-items: center; justify-content: center;">
            <svg width="10" height="10" viewBox="0 0 24 24" fill="white" stroke="none"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
          </div>`,
          iconSize: [20, 20],
          iconAnchor: [10, 10],
        });

        const marker = L.marker([tech.currentLocation.lat, tech.currentLocation.lng], { icon: techIcon })
          .addTo(map)
          .bindPopup(`<strong>${tech.name}</strong><br>${tech.currentLocation.address}<br><em>${tech.isAvailable ? '✅ Disponible' : '❌ Ocupado'}</em>`);
        this.techMarkers.push(marker);
      });

      // Fit bounds to show all markers
      const allPoints: L.LatLngExpression[] = [
        [inc.location.lat, inc.location.lng],
        ...ws.technicians.map(t => [t.currentLocation.lat, t.currentLocation.lng] as L.LatLngExpression),
      ];
      if (allPoints.length > 1) {
        map.fitBounds(L.latLngBounds(allPoints), { padding: [50, 50] });
      }
    }
  }

  goBack(): void {
    this.router.navigate(['/dashboard/solicitudes']);
  }

  openAssignModal(): void {
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
    const inc = this.incident();
    const ws = this.workshop();
    const techId = this.selectedTechnicianId();
    if (inc && ws && techId) {
      this.dataService.acceptIncident(inc.id, ws.id, techId);
      this.incident.set({ ...inc, status: 'accepted' as ServiceStatus, workshopId: ws.id, assignedTechnician: techId });
      this.closeAssignModal();
    }
  }

  rejectIncident(): void {
    const inc = this.incident();
    if (inc) {
      this.dataService.rejectIncident(inc.id);
      this.incident.set({ ...inc, status: 'rejected' as ServiceStatus });
    }
  }

  updateStatus(status: ServiceStatus): void {
    const inc = this.incident();
    if (inc) {
      this.dataService.updateIncidentStatus(inc.id, status);
      this.incident.set({ ...inc, status });
    }
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

  getTechName(techId: string | undefined): string {
    if (!techId) return 'Sin asignar';
    const ws = this.workshop();
    const tech = ws?.technicians.find(t => t.id === techId);
    return tech ? tech.name : 'Desconocido';
  }

  formatDate(date: Date): string {
    return new Date(date).toLocaleDateString('es-PE', { day: '2-digit', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit' });
  }
}
