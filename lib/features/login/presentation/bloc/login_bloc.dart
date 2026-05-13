// lib/features/login/presentation/bloc/login_bloc.dart

import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/config/environment_config.dart';
import 'package:app_jht_front/core/utils/app_logger.dart'; // ✅ Importar Logger

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
    final stopwatch = Stopwatch()..start();

    try {
      final url = Uri.parse('${EnvironmentConfig.baseUrl}/api/Auth/login');
      
      // ✅ Log de auditoría: Intento de login
      AppLogger.httpRequest('POST /api/Auth/login', source: 'LoginBloc', extraData: {'usuario': event.username});

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

      // ✅ Log de respuesta HTTP
      AppLogger.httpResponse(
        '/api/Auth/login', 
        statusCode: response.statusCode, 
        durationMs: stopwatch.elapsedMilliseconds, 
        source: 'LoginBloc'
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String token = responseData['token']; 
        
        await TokenService.saveToken(token); 
        await TokenService.saveUserData(
          responseData['usuario'], 
          responseData['cargo']
        );

        // ✅ IMPORTANTÍSIMO: Sincronizar el logger con el nuevo usuario
        AppLogger.setUser(responseData['usuario']);
        
        AppLogger.info(
          'Login exitoso: ${responseData['usuario']} (${responseData['cargo']})', 
          source: 'LoginBloc'
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
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = _getErrorMessage(errorData);
        
        AppLogger.warning(
          'Intento de login fallido para "${event.username}": $errorMessage', 
          source: 'LoginBloc'
        );
        
        emit(state.copyWith(isLoading: false, error: errorMessage));
      }
    } catch (e, stack) {
      AppLogger.error(
        'Excepción durante el login para "${event.username}"', 
        error: e, 
        stackTrace: stack, 
        source: 'LoginBloc'
      );

      String errorMsg = 'Error de conexión';
      if (e.toString().contains('SocketException')) {
        errorMsg = 'No hay conexión a internet o el servidor no responde';
      }

      emit(state.copyWith(isLoading: false, error: errorMsg));
    }
  }

  String _getErrorMessage(Map<String, dynamic> errorData) {
    if (errorData['mensaje'] != null) return errorData['mensaje'].toString();
    if (errorData['errors'] != null) {
      final errors = errorData['errors'] as Map<String, dynamic>;
      if (errors.isNotEmpty) {
        final firstKey = errors.keys.first;
        final firstError = errors[firstKey];
        if (firstError is List && firstError.isNotEmpty) return firstError.first.toString();
        if (firstError is String) return firstError;
      }
    }
    if (errorData['title'] != null) return errorData['title'].toString();
    return 'Error en la solicitud';
  }
}