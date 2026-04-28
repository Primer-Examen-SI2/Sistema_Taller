import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: 'login', loadComponent: () => import('./features/auth/login/login').then(m => m.LoginComponent) },
  { path: 'register', loadComponent: () => import('./features/auth/register/register').then(m => m.RegisterComponent) },
  {
    path: 'dashboard',
    canActivate: [authGuard],
    loadComponent: () => import('./layouts/main-layout/main-layout').then(m => m.MainLayoutComponent),
    children: [
      { path: '', redirectTo: 'home', pathMatch: 'full' },
      { path: 'home', loadComponent: () => import('./features/dashboard/home/home').then(m => m.HomeComponent) },
      { path: 'solicitudes', loadComponent: () => import('./features/dashboard/solicitudes/solicitudes').then(m => m.SolicitudesComponent) },
      { path: 'solicitudes/:id', loadComponent: () => import('./features/dashboard/incident-detail/incident-detail').then(m => m.IncidentDetailComponent) },
      { path: 'operacion', loadComponent: () => import('./features/dashboard/operacion/operacion').then(m => m.OperacionComponent) },
      { path: 'mecanicos', loadComponent: () => import('./features/dashboard/mecanicos/mecanicos').then(m => m.MecanicosComponent) },
      { path: 'historial', loadComponent: () => import('./features/dashboard/historial/historial').then(m => m.HistorialComponent) },
    ],
  },
  { path: '**', redirectTo: '/login' },
];
