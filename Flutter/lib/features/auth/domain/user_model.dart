class UserCreate {
  final String username;
  final String password;
  final String correo;
  final String? telefono;
  final int rolId;

  UserCreate({
    required this.username,
    required this.password,
    required this.correo,
    this.telefono,
    required this.rolId,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'correo': correo,
        'telefono': telefono,
        'rol_id': rolId,
      };
}

class UserResponse {
  final int id;
  final String username;
  final String correo;
  final String? telefono;
  final int rolId;

  UserResponse({
    required this.id,
    required this.username,
    required this.correo,
    this.telefono,
    required this.rolId,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        id: json['id'],
        username: json['username'],
        correo: json['correo'],
        telefono: json['telefono'],
        rolId: json['rol_id'],
      );
}

class TokenResponse {
  final String accessToken;
  final String tokenType;

  TokenResponse({
    required this.accessToken,
    required this.tokenType,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
        accessToken: json['access_token'],
        tokenType: json['token_type'],
      );
}
