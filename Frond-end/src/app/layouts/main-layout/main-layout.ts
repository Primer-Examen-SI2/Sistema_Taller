import { Component, inject, computed } from '@angular/core';
import { RouterOutlet, RouterLink, RouterLinkActive, Router } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-main-layout',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  templateUrl: './main-layout.html',
  styleUrl: './main-layout.css',
})
export class MainLayoutComponent {
  private auth = inject(AuthService);
  private router = inject(Router);

  workshop = computed(() => this.auth.currentUser());
  sidebarOpen = true;

  navItems = [
    { path: '/dashboard/home', label: 'Inicio', icon: 'home' },
    { path: '/dashboard/solicitudes', label: 'Solicitudes', icon: 'inbox' },
    { path: '/dashboard/operacion', label: 'Operación', icon: 'settings' },
    { path: '/dashboard/mecanicos', label: 'Mecánicos', icon: 'users' },
    { path: '/dashboard/historial', label: 'Historial', icon: 'clock' },
  ];

  toggleSidebar(): void {
    this.sidebarOpen = !this.sidebarOpen;
  }

  logout(): void {
    this.auth.logout();
    this.router.navigate(['/login']);
  }
}
