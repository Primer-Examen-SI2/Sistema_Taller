import { Component, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [FormsModule, RouterLink],
  templateUrl: './login.html',
  styleUrl: './login.css',
})
export class LoginComponent {
  email = '';
  password = '';
  error = '';
  showPassword = false;

  private auth = inject(AuthService);
  private router = inject(Router);

  onSubmit(): void {
    this.error = '';
    if (!this.email || !this.password) {
      this.error = 'Por favor complete todos los campos';
      return;
    }
    const success = this.auth.login(this.email, this.password);
    if (success) {
      this.router.navigate(['/dashboard/home']);
    } else {
      this.error = 'Credenciales incorrectas';
    }
  }

  togglePassword(): void {
    this.showPassword = !this.showPassword;
  }
}
