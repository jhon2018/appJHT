/// Definición: Maneja los diferentes tipos de fallos que pueden ocurrir en la aplicación
/// Objetivo: Centralizar y tipificar los errores para un manejo consistente
library;

class Failure {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

class ServerFailure extends Failure {
  ServerFailure({super.message = 'Error del servidor', super.code});
}

class NetworkFailure extends Failure {
  NetworkFailure({super.message = 'Error de conexión'});
}

class ValidationFailure extends Failure {
  ValidationFailure({super.message = 'Error de validación'});
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure({super.message = 'No autorizado'});
}