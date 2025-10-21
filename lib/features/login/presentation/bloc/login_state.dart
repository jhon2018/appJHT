// Ruta: lib/features/login/presentation/bloc/login_state.dart
// Objetivo: Definir el estado del BLoC de inicio de sesión, incluyendo carga, éxito y manejo de errores.

import 'package:flutter/foundation.dart';
@immutable
class LoginState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  // Método helper para verificar si hay error
  bool get hasError => error != null && error!.isNotEmpty;

  LoginState copyWith({
    bool? isLoading,
    String? error, // ← Si pasas null, se limpia el error
    bool? isSuccess,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // ← Esto permite limpiar el error
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  String toString() {
    return 'LoginState(isLoading: $isLoading, error: $error, isSuccess: $isSuccess)';
  }
}
