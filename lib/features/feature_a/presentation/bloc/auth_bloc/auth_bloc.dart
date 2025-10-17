//Ruta: lib/features/feature_a/presentation/bloc/auth_bloc/auth_bloc.dart
// Objetivo: Implementar el BLoC de autenticación utilizando Freezed para manejar eventos y estados.
// usamos: flutter pub run build_runner build --delete-conflicting-outputs nos ayuda a generar el codigo y evitar conflictos

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState.initial()) {
    on<_Login>(_onLogin);
    on<_Logout>(_onLogout);
  }

  Future<void> _onLogin(_Login event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    
    try {
      // TODO: Aquí llamaremos al usecase de login
      await Future.delayed(const Duration(seconds: 2)); // Simulamos llamada
      
      // Simulamos respuesta exitosa
      emit(AuthState.loginSuccess(
        token: 'simulated_token',
        refreshToken: 'simulated_refresh_token', 
        usuario: event.username,
        nivelAccess: 1,
      ));
      
    } catch (e) {
      emit(AuthState.loginError(message: 'Error de conexión'));
    }
  }

  void _onLogout(_Logout event, Emitter<AuthState> emit) {
    emit(const AuthState.logoutSuccess());
  }
}
