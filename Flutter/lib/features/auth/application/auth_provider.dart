import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_cliente/features/auth/domain/user_model.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthState {
  final AuthStatus status;
  final UserResponse? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.idle,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserResponse? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<bool> login(String username, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    // Simulación estática - sin conexión al backend
    await Future.delayed(const Duration(seconds: 1));
    if (username.isEmpty || password.isEmpty) {
      state = const AuthState(status: AuthStatus.error, errorMessage: 'Completa todos los campos');
      return false;
    }
    state = AuthState(
      status: AuthStatus.authenticated,
      user: UserResponse(
        id: 1,
        username: username,
        correo: '$username@correo.com',
        telefono: null,
        rolId: 2,
      ),
    );
    return true;
  }

  Future<bool> register(UserCreate user) async {
    state = const AuthState(status: AuthStatus.loading);
    // Simulación estática - sin conexión al backend
    await Future.delayed(const Duration(seconds: 1));
    state = AuthState(
      status: AuthStatus.authenticated,
      user: UserResponse(
        id: 1,
        username: user.username,
        correo: user.correo,
        telefono: user.telefono,
        rolId: user.rolId,
      ),
    );
    return true;
  }

  void logout() {
    state = const AuthState(status: AuthStatus.idle);
  }

  void clearError() {
    state = state.copyWith(status: AuthStatus.idle, errorMessage: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
