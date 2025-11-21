// Ruta: lib/features/login/presentation/bloc/login_event.dart
// Objetivo: Definir los eventos para el BLoC de login ayudando a manejar las acciones del usuario relacionadas con el login.

abstract class LoginEvent {}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  LoginButtonPressed({required this.username, required this.password});
  
}

class ClearLoginForm extends LoginEvent {
   ClearLoginForm();
}
