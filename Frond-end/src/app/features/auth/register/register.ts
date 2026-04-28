import { Component, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { Workshop, IncidentType } from '../../../core/models/incident.model';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [FormsModule, RouterLink],
  templateUrl: './register.html',
  styleUrl: './register.css',
})
export class RegisterComponent {
  name = '';
  email = '';
  password = '';
  confirmPassword = '';
  phone = '';
  address = '';
  specialties: IncidentType[] = [];
  error = '';
  showPassword = false;

  specialtyOptions: { value: IncidentType; label: string }[] = [
    { value: 'mechanical', label: 'Mecánica general' },
    { value: 'tire', label: 'Llantas' },
    { value: 'battery', label: 'Batería' },
    { value: 'overheating', label: 'Sobrecalentamiento' },
    { value: 'accident', label: 'Accidentes' },
    { value: 'lockout', label: 'Apertura de llaves' },
    { value: 'other', label: 'Otro' },
  ];

  private auth = inject(AuthService);
  private router = inject(Router);

  toggleSpecialty(specialty: IncidentType): void {
    const idx = this.specialties.indexOf(specialty);
    if (idx >= 0) {
      this.specialties.splice(idx, 1);
    } else {
      this.specialties.push(specialty);
    }
  }

  onSubmit(): void {
    this.error = '';
    if (!this.name || !this.email || !this.password || !this.phone || !this.address) {
      this.error = 'Por favor complete todos los campos obligatorios';
      return;
    }
    if (this.password !== this.confirmPassword) {
      this.error = 'Las contraseñas no coinciden';
      return;
    }
    if (this.password.length < 6) {
      this.error = 'La contraseña debe tener al menos 6 caracteres';
      return;
    }
    if (this.specialties.length === 0) {
      this.error = 'Seleccione al menos una especialidad';
      return;
    }

    const workshop: Workshop = {
      id: 'w' + Date.now(),
      name: this.name,
      email: this.email,
      password: this.password,
      phone: this.phone,
      address: this.address,
      location: { lat: -12.0464, lng: -77.0428, address: this.address },
      specialties: [...this.specialties],
      technicians: [],
      commissionRate: 0.10,
      isActive: true,
    };

    this.auth.register(workshop);
    this.router.navigate(['/dashboard/home']);
  }

  togglePassword(): void {
    this.showPassword = !this.showPassword;
  }
}
