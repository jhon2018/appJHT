
//Ruta: lib/features/feature_a/presentation/bloc/auth_bloc/auth_event.dart
//Objetivo: Definir los eventos para el BLoC de autenticación utilizando Freezed.

part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.login({
    required String username,
    required String password,
  }) = _Login;

  const factory AuthEvent.logout() = _Logout;

  const factory AuthEvent.refreshToken() = _RefreshToken;
}
