import { Injectable, signal, computed } from '@angular/core';
import { Workshop } from '../models/incident.model';
import { DataService } from './data.service';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private _currentUser = signal<Workshop | null>(null);
  private _isAuthenticated = signal(false);

  currentUser = computed(() => this._currentUser());
  isAuthenticated = computed(() => this._isAuthenticated());

  constructor(private dataService: DataService) {
    const saved = localStorage.getItem('workshop_user');
    if (saved) {
      try {
        const user = JSON.parse(saved);
        this._currentUser.set(user);
        this._isAuthenticated.set(true);
      } catch {
        localStorage.removeItem('workshop_user');
      }
    }
  }

  login(email: string, password: string): boolean {
    const workshop = this.dataService.workshops().find(w => w.email === email && w.password === password);
    if (workshop) {
      this._currentUser.set(workshop);
      this._isAuthenticated.set(true);
      localStorage.setItem('workshop_user', JSON.stringify(workshop));
      return true;
    }
    return false;
  }

  register(workshop: Workshop): void {
    this.dataService.addWorkshop(workshop);
    this._currentUser.set(workshop);
    this._isAuthenticated.set(true);
    localStorage.setItem('workshop_user', JSON.stringify(workshop));
  }

  logout(): void {
    this._currentUser.set(null);
    this._isAuthenticated.set(false);
    localStorage.removeItem('workshop_user');
  }
}
