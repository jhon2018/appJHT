// Ruta: lib/features/login/presentation/bloc/login_bloc.dart
// Objetivo: Implementar el BLoC de inicio de sesión para manejar eventos y estados relacionados con el login y la autenticación.

import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/config/environment_config.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../feature_a/data/models/login_request_model.dart';
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

    try {
      print('🔵 Iniciando login_bloc.dart para usuario: ${event.username}');
      
      // ✅ USANDO LA CONFIGURACIÓN GLOBAL
      // Esto elimina el error de SocketException en el móvil al no usar la IP local
      final url = Uri.parse('${EnvironmentConfig.baseUrl}/api/Auth/login');
      
      print('📡 Conectando a: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
        body: json.encode(
          LoginRequestModel(
            usuario: event.username,
            contrasena: event.password,
          ).toJson(),
        ),
      );

      print('🟡 Response status: ${response.statusCode}');
      print('🟡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String token = responseData['token']; 
        await TokenService.saveToken(token); 
        await TokenService.saveUserData(
          responseData['usuario'], 
          responseData['cargo']
        );

        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            error: null, 
            cargo: responseData['cargo'], 
            usuario: responseData['usuario'],
          ),
        );

        print('✅ Mensaje Api: ${responseData['mensaje']}');
        print('✅ Cargo: ${responseData['cargo']}');  
        print('✅ Usuario: ${responseData['usuario']}');
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = _getErrorMessage(errorData);
        emit(state.copyWith(isLoading: false, error: errorMessage));
      }
    } catch (e) {
      print('❌ ERROR COMPLETO login_bloc.dart : $e');
      print('❌ TIPO DE ERROR login_bloc.dart: ${e.runtimeType}');

      String errorMsg = 'Error de conexión';
      if (e.toString().contains('SocketException')) {
        errorMsg = 'No hay conexión a internet o el servidor no responde';
      } else if (e.toString().contains('Failed host lookup')) {
        errorMsg = 'No se puede encontrar el servidor. Verifica tu conexión';
      }

      emit(state.copyWith(isLoading: false, error: errorMsg));
    }
  }

  String _getErrorMessage(Map<String, dynamic> errorData) {
    print('🔍 Error data: $errorData');

    if (errorData['mensaje'] != null) {
      return errorData['mensaje'].toString();
    }

    if (errorData['errors'] != null) {
      final errors = errorData['errors'] as Map<String, dynamic>;
      if (errors.isNotEmpty) {
        final firstKey = errors.keys.first;
        final firstError = errors[firstKey];

        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        } else if (firstError is String) {
          return firstError;
        }
      }
    }

    if (errorData['title'] != null) {
      return errorData['title'].toString();
    }

    return 'Error en la solicitud';
  }
}