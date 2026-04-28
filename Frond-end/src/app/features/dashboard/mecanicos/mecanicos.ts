import { Component, inject, computed, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../../core/services/auth.service';
import { DataService } from '../../../core/services/data.service';
import { Technician, IncidentType } from '../../../core/models/incident.model';

@Component({
  selector: 'app-mecanicos',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './mecanicos.html',
  styleUrl: './mecanicos.css',
})
export class MecanicosComponent {
  private auth = inject(AuthService);
  private dataService = inject(DataService);

  workshop = computed(() => this.auth.currentUser());
  technicians = computed(() => {
    const ws = this.workshop();
    return ws ? ws.technicians : [];
  });

  showModal = signal(false);
  modalMode = signal<'create' | 'edit' | 'view'>('create');
  selectedTech = signal<Technician | null>(null);
  showDeleteConfirm = signal(false);
  techToDelete = signal<string>('');

  // Form fields
  formName = signal('');
  formSpecialties = signal<IncidentType[]>([]);
  formAddress = signal('');
  formLat = signal(-12.0464);
  formLng = signal(-77.0428);
  formAvailable = signal(true);

  specialtyOptions: { value: IncidentType; label: string }[] = [
    { value: 'mechanical', label: 'Mecánica general' },
    { value: 'tire', label: 'Llantas' },
    { value: 'battery', label: 'Batería' },
    { value: 'overheating', label: 'Sobrecalentamiento' },
    { value: 'accident', label: 'Accidentes' },
    { value: 'lockout', label: 'Apertura de llaves' },
    { value: 'other', label: 'Otro' },
  ];

  availableCount = computed(() => this.technicians().filter(t => t.isAvailable).length);

  openCreateModal(): void {
    this.modalMode.set('create');
    this.formName.set('');
    this.formSpecialties.set([]);
    this.formAddress.set('');
    this.formLat.set(-12.0464);
    this.formLng.set(-77.0428);
    this.formAvailable.set(true);
    this.selectedTech.set(null);
    this.showModal.set(true);
  }

  openEditModal(tech: Technician): void {
    this.modalMode.set('edit');
    this.selectedTech.set(tech);
    this.formName.set(tech.name);
    this.formSpecialties.set([...tech.specialty]);
    this.formAddress.set(tech.currentLocation.address);
    this.formLat.set(tech.currentLocation.lat);
    this.formLng.set(tech.currentLocation.lng);
    this.formAvailable.set(tech.isAvailable);
    this.showModal.set(true);
  }

  openViewModal(tech: Technician): void {
    this.modalMode.set('view');
    this.selectedTech.set(tech);
    this.showModal.set(true);
  }

  closeModal(): void {
    this.showModal.set(false);
    this.selectedTech.set(null);
  }

  toggleSpecialty(specialty: IncidentType): void {
    if (this.modalMode() === 'view') return;
    const current = this.formSpecialties();
    const idx = current.indexOf(specialty);
    if (idx >= 0) {
      this.formSpecialties.set(current.filter(s => s !== specialty));
    } else {
      this.formSpecialties.set([...current, specialty]);
    }
  }

  saveTechnician(): void {
    const ws = this.workshop();
    if (!ws) return;

    if (!this.formName() || this.formSpecialties().length === 0 || !this.formAddress()) {
      return;
    }

    if (this.modalMode() === 'create') {
      const newTech: Technician = {
        id: 't' + Date.now(),
        name: this.formName(),
        specialty: this.formSpecialties(),
        isAvailable: this.formAvailable(),
        currentLocation: {
          lat: this.formLat(),
          lng: this.formLng(),
          address: this.formAddress(),
        },
        activeAssignments: 0,
      };
      this.dataService.addTechnician(ws.id, newTech);
    } else if (this.modalMode() === 'edit') {
      const existing = this.selectedTech();
      if (!existing) return;
      const updated: Technician = {
        ...existing,
        name: this.formName(),
        specialty: this.formSpecialties(),
        isAvailable: this.formAvailable(),
        currentLocation: {
          lat: this.formLat(),
          lng: this.formLng(),
          address: this.formAddress(),
        },
      };
      this.dataService.updateTechnician(ws.id, updated);
    }

    this.closeModal();
  }

  confirmDelete(techId: string): void {
    this.techToDelete.set(techId);
    this.showDeleteConfirm.set(true);
  }

  cancelDelete(): void {
    this.showDeleteConfirm.set(false);
    this.techToDelete.set('');
  }

  deleteTechnician(): void {
    const ws = this.workshop();
    if (!ws) return;
    this.dataService.deleteTechnician(ws.id, this.techToDelete());
    this.showDeleteConfirm.set(false);
    this.techToDelete.set('');
  }

  toggleAvailability(techId: string): void {
    this.dataService.toggleTechnicianAvailability(techId);
  }

  getTypeLabel(type: string): string {
    const labels: Record<string, string> = {
      mechanical: 'Mecánica', tire: 'Llanta', battery: 'Batería',
      overheating: 'Sobrecalentamiento', accident: 'Accidente',
      lockout: 'Llaves', other: 'Otro',
    };
    return labels[type] || type;
  }

  getInitials(name: string): string {
    return name.split(' ').map(n => n[0]).join('').slice(0, 2);
  }
}
