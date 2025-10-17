//Ruta: lib/features/feature_a/data/models/login_request_model.dart
// Objetivo: Crear un modelo de datos para la solicitud de inicio de sesión.

class LoginRequestModel {
  final String usuario;
  final String password;

  LoginRequestModel({
    required this.usuario,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'usuario': usuario,
    'password': password,
  };
}