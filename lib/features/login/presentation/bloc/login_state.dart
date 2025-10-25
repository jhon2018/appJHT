// Ruta: lib/features/login/presentation/bloc/login_state.dart
// Objetivo: Definir el estado del BLoC de inicio de sesión, incluyendo carga, éxito y manejo de errores.

import 'package:flutter/foundation.dart';
@immutable
class LoginState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final int? nivelAcceso;
  final String? usuario;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.nivelAcceso, 
    this.usuario,      
  });

  // Método helper para verificar si hay error
  bool get hasError => error != null && error!.isNotEmpty;

  // CORRECCIÓN: Los parámetros deben ser nombrados y opcionales
  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    int? nivelAcceso,  // ← QUITA el "required"
    String? usuario,   // ← QUITA el "required"
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Permite limpiar el error con null
      isSuccess: isSuccess ?? this.isSuccess,
      nivelAcceso: nivelAcceso ?? this.nivelAcceso, 
      usuario: usuario ?? this.usuario,             
    );
  }

  @override
  String toString() {
    return 'LoginState(isLoading: $isLoading, error: $error, isSuccess: $isSuccess, nivelAcceso: $nivelAcceso, usuario: $usuario)';
  }
}