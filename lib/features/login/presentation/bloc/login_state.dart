// Ruta: lib/features/login/presentation/bloc/login_state.dart
// Objetivo: Definir los estados para el BLoC de login ayudando a manejar la UI en función del estado actual.

class LoginState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  LoginState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}