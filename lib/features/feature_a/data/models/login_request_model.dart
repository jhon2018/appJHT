//Ruta: lib/features/feature_a/data/models/login_request_model.dart
// Objetivo: Crear un modelo de datos para la solicitud de inicio de sesión.

class LoginRequestModel {
  final String usuario;
  final String contrasena;

  LoginRequestModel({
    required this.usuario,
    required this.contrasena,
  });

  Map<String, dynamic> toJson() => {
    'usuario': usuario,
    'contrasena': contrasena,
  };
}