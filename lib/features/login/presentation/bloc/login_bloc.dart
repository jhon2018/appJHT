// Ruta: lib/features/login/presentation/bloc/login_bloc.dart
// // Objetivo: Implementar el BLoC de login para manejar la lógica de autenticación y actualizar el estado en función de los eventos recibidos.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginState()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    // Simulamos llamada a API por 2 segundos
    await Future.delayed(const Duration(seconds: 2));
    
    // TODO: Reemplazar con llamada real a tu API
    if (event.username.isNotEmpty && event.password.isNotEmpty) {
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } else {
      emit(state.copyWith(
        isLoading: false, 
        error: 'Por favor ingresa usuario y contraseña'
      ));
    }
  }
}