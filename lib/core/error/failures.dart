/// Definición: Maneja los diferentes tipos de fallos que pueden ocurrir en la aplicación
/// Objetivo: Centralizar y tipificar los errores para un manejo consistente

class Failure {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

class ServerFailure extends Failure {
  ServerFailure({String message = 'Error del servidor', int? code})
      : super(message: message, code: code);
}

class NetworkFailure extends Failure {
  NetworkFailure({String message = 'Error de conexión'})
      : super(message: message);
}

class ValidationFailure extends Failure {
  ValidationFailure({String message = 'Error de validación'})
      : super(message: message);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure({String message = 'No autorizado'})
      : super(message: message);
}