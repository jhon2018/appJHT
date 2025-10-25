// Ruta: lib/features/login/presentation/bloc/login_bloc.dart
// Objetivo: Implementar el BLoC de inicio de sesión para manejar eventos y estados relacionados con el login y la autenticación.

import 'package:flutter/foundation.dart';
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
     
     String getBaseUrl() {
      if (kIsWeb) {
        return 'http://localhost:7030'; // Web funciona con localhost
      } else {
        // Para móvil, usar IP de la laptop
        return 'http://192.168.1.16:7030'; // ← Cambia por tu IP y agregalo en el CORS
      }
    }
     
      // LLAMADA REAL A TU API
      final response = await http.post(
       
        // Uri.parse('https://jht-backendapi.onrender.com/api/Auth/login'),  // PRODUCCION
        Uri.parse('${getBaseUrl()}/api/Auth/login'),
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
        // SOLO CAMBIA ESTA LÍNEA: mantener copyWith pero limpiar error
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            error: null, // ← LIMPIAR ERROR EXPLÍCITAMENTE
            nivelAcceso: responseData['nivelAcceso'], // ← GUARDAR NIVEL ACCESO
            usuario: responseData['usuario'],         // ← GUARDAR USUARIO
          ),
        );

            print('✅ Mensaje Api: ${responseData['mensaje']}');
            print('✅ Nivel Acceso: ${responseData['nivelAcceso']}');
            print('✅ Usuario: ${responseData['usuario']}');
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = _getErrorMessage(errorData);
        emit(state.copyWith(isLoading: false, error: errorMessage));
      }
    } catch (e) {
        print('❌ ERROR COMPLETO: $e');
        print('❌ TIPO DE ERROR: ${e.runtimeType}');

      // Mensaje más específico
      String errorMsg = 'Error de conexión';
      if (e.toString().contains('SocketException')) {
        errorMsg = 'No hay conexión a internet';
      } else if (e.toString().contains('Failed host lookup')) {
        errorMsg = 'No se puede encontrar el servidor. Verifica tu conexión';
      }

      emit(state.copyWith(isLoading: false, error: errorMsg));
    }
  }

  String _getErrorMessage(Map<String, dynamic> errorData) {
    print('🔍 Error data: $errorData');

    // PRIMERO: Intentar obtener mensaje directo
    if (errorData['mensaje'] != null) {
      return errorData['mensaje'].toString();
    }

    // SEGUNDO: Manejar errores de validación
    if (errorData['errors'] != null) {
      final errors = errorData['errors'] as Map<String, dynamic>;
      print('🔑 Error keys: ${errors.keys.toList()}');

      // EXTRAER EL PRIMER ERROR ENCONTRADO
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

    // TERCERO: Mensaje genérico
    if (errorData['title'] != null) {
      return errorData['title'].toString();
    }

    return 'Error en la solicitud';
  }
}
