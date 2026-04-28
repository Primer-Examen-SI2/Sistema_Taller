import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_cliente/core/network/api_client.dart';
import 'package:app_cliente/features/auth/domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<TokenResponse> login(String username, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: FormData.fromMap({
        'username': username,
        'password': password,
      }),
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );
    return TokenResponse.fromJson(response.data);
  }

  Future<UserResponse> register(UserCreate user) async {
    final response = await _dio.post(
      '/users/',
      data: user.toJson(),
    );
    return UserResponse.fromJson(response.data);
  }
}
