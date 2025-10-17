//Ruta: lib/features/feature_a/presentation/bloc/auth_bloc/auth_state.dart
//Objetivo: Definir los estados para el BLoC de autenticación utilizando Freezed.

part of 'auth_bloc.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  
  const factory AuthState.loading() = _Loading;
  
  const factory AuthState.loginSuccess({
    required String token,
    required String refreshToken,
    required String usuario,
    required int nivelAccess,
  }) = _LoginSuccess;
  
  const factory AuthState.loginError({
    required String message,
  }) = _LoginError;
  
  const factory AuthState.logoutSuccess() = _LogoutSuccess;
}
