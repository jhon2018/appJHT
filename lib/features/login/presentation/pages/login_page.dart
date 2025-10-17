// ruta: lib/features/login/presentation/pages/login_page.dart
//descripción: Página de login con diseño responsivo para web y móvil
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Importamos el clipper
import '../widgets/login_wave_clipper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

class LoginPage extends StatefulWidget {
  

  const LoginPage({super.key});

  // Colores definidos para el login, basados en el diseño web (Azul Oscuro/Blue Background).
  static const Color primaryColor = Color.fromARGB(255, 48, 51, 98);// Azul oscuro (Botón/Texto)
  static const Color webBackgroundColor = Color.fromARGB(
    255,
    70,
    130,
    180,
  ); // Fondo azul para la vista web
  static const Color accentColor = Color.fromARGB(
    255,
    34,
    35,
    90,
  ); // Azul oscuro (Texto, Íconos)
  static const Color buttonColor = primaryColor; // Color del botón

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers para capturar los datos
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

 

  @override
  Widget build(BuildContext context) {
    // Usamos MediaQuery para obtener las dimensiones y determinar la plataforma.
    final size = MediaQuery.of(context).size;
    // La lógica de responsividad se basa en el ancho
    final isWebOrTablet =
        size.width > 800; // Aumentamos el breakpoint para dos columnas

    // --- VERSIÓN WEB CON FONDO COMPLETO ---
    if (isWebOrTablet) {
      return Scaffold(
        body: Stack(
          children: [
            // FONDO COMPLETO CON LA IMAGEN
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/LoginWebFondo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // CONTENIDO PRINCIPAL CENTRADO
            Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 1200,
                  maxHeight: 800,
                ),
                padding: const EdgeInsets.all(40),
                child: Row(
                  children: [
                    // SECCIÓN DE BIENVENIDA (IZQUIERDA)
                    const Expanded(flex: 5, child: _WebWelcomeSection()),

                    const SizedBox(width: 60),

                    // FORMULARIO (DERECHA)
                    Expanded(flex: 3, child: _WebLoginFormCard(
                      usernameController: _usernameController,
                      passwordController: _passwordController,
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Si es móvil/pantalla pequeña, mantenemos el diseño vertical con la onda
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER con la onda usando ClipPath (Diseño Móvil)
            _buildMobileHeader(context, size.height),

            // 2. FORMULARIO DE LOGIN (Diseño Móvil)
            _buildMobileLoginForm(),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCCIÓN (MÓVIL) ---

  Widget _buildMobileHeader(BuildContext context, double totalHeight) {
    final double headerHeight = totalHeight * 0.45; // Altura para móvil

    return ClipPath(
      clipper: LoginWaveClipper(), // Usamos el clipper de onda
      child: Container(
        width: double.infinity,
        height: headerHeight,
        color: LoginPage.primaryColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // IMAGEN DE FONDO
            Positioned.fill(
              child: Image.asset(
                'assets/images/loginFondo.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLoginForm() {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isSuccess) {
          // Navegar a la siguiente pantalla
          print('Login exitoso! Navegando...');
          // TODO: Agregar navegación aquí
          // Navigator.pushReplacementNamed(context, '/home');
        }
        if (state.error != null) {
          // Mostrar error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ESPACIO EN LA PARTE SUPERIOR
            const SizedBox(height: 10),

            // TEXTO CENTRADO CON MEJOR ESPACIADO
            const Center(
              child: Text(
                'JHT TRANSPORT\nCOMPANY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: LoginPage.primaryColor,
                  letterSpacing: 1.5,
                  height: 1.2, // Mejor interlineado
                ),
              ),
            ),

            // ESPACIO ENTRE TEXTO Y PRIMER CAMPO
            const SizedBox(height: 45),

            _LoginFormField(
              labelText: 'Username',
              icon: FontAwesomeIcons.solidUser,
              controller: _usernameController,
            ),
            const SizedBox(height: 30),
            _LoginFormField(
              labelText: 'Password',
              icon: FontAwesomeIcons.lock,
              isPassword: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 50),
            _LoginButton(
              color: LoginPage.buttonColor,
              usernameController: _usernameController,
              passwordController: _passwordController,
            ),

            // Agregar espacio antes del copyright
            const SizedBox(height: 40),
            // Llamar al widget de derechos de autor
            CopyrightFooter(),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS REUTILIZABLES ---

class _LoginFormField extends StatelessWidget {
  final String labelText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;

  const _LoginFormField({
    required this.labelText,
    required this.icon,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, size: 18, color: LoginPage.accentColor),
        suffixIcon: isPassword
            ? Icon(FontAwesomeIcons.eye, size: 18, color: LoginPage.accentColor)
            : null,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: LoginPage.accentColor, width: 2),
        ),
      ),
    );
  }
}

class CopyrightFooter extends StatelessWidget {
  final String companyName;

  const CopyrightFooter({
    super.key,
    this.companyName = 'JHT Transport Company \n',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '© ${DateTime.now().year} $companyName. All rights reserved.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final Color color;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const _LoginButton({
    required this.color,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state.isLoading 
              ? null 
              : () {
                  context.read<LoginBloc>().add(LoginButtonPressed(
                    username: usernameController.text,
                    password: passwordController.text,
                  ));
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: state.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        );
      },
    );
  }
}

// --- WIDGETS ESPECÍFICOS SOLO WEB (CON ANIMACIONES) ---

class _WebWelcomeSection extends StatefulWidget {
  const _WebWelcomeSection();

  @override
  State<_WebWelcomeSection> createState() => _WebWelcomeSectionState();
}

class _WebWelcomeSectionState extends State<_WebWelcomeSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // WELCOME a la izquierda
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(_slideAnimation.value, 0),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: const Text(
                      'INCIA SESIÓN',
                      textAlign: TextAlign.left, // Alineado a la izquierda
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            blurRadius: 15.0,
                            color: Colors.black87,
                            offset: Offset(3, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Descripción alineada a la izquierda
              Transform.translate(
                offset: Offset(_slideAnimation.value * 0.8, 0),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: const Text(
                    'Soluciones logísticas confiables y eficientes para un transporte sin interrupciones. Inicia sesión y descubre cómo podemos optimizar tus operaciones de transporte.',
                    textAlign: TextAlign.left, // Alineado a la izquierda
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.5,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black87,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- TARJETA DE FORMULARIO SOLO WEB ---
class _WebLoginFormCard extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const _WebLoginFormCard({
    required this.usernameController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isSuccess) {
          // Navegar a la siguiente pantalla
          print('Login exitoso! Navegando...');
          // TODO: Agregar navegación aquí
          // Navigator.pushReplacementNamed(context, '/home');
        }
        if (state.error != null) {
          // Mostrar error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Card(
        elevation: 25,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white.withOpacity(0.95),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TEXTO CENTRADO
              const Center(
                child: Text(
                  'JHT TRANSPORT COMPANY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: LoginPage.primaryColor,
                  ),
                ),
              ),
              const Divider(
                color: Colors.grey,
                thickness: 1,
                height: 15,
                indent: 70,
                endIndent: 70,
              ),
              const SizedBox(height: 40),

              // Campos del formulario
              _LoginFormField(
                labelText: 'User Name',
                icon: FontAwesomeIcons.solidUser,
                controller: usernameController,
              ),
              const SizedBox(height: 30),
              _LoginFormField(
                labelText: 'Password',
                icon: FontAwesomeIcons.lock,
                isPassword: true,
                controller: passwordController,
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 50),

              // Botón de Login
              _LoginButton(
                color: LoginPage.buttonColor,
                usernameController: usernameController,
                passwordController: passwordController,
              ),

              const SizedBox(height: 40),

              // Derechos de autor
              const Text(
                '© 2025 JHT Transport Company. All rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}