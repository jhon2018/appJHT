// ruta: lib/features/login/presentation/pages/login_page.dart
//descripción: Página de login con diseño responsivo para web y móvil logrando una experiencia de usuario óptima en ambas plataformas.
import 'package:flutter/material.dart';
import 'package:app_jht_front/core/widgets/app_notification.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Importamos el clipper
import '../widgets/login_wave_clipper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../../../admin/presentation/pages/admin_dashboard.dart';
import '../../../conductor/presentation/pages/conductor_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  // Colores definidos para el login, basados en el diseño web (Azul Oscuro/Blue Background).
  static const Color primaryColor = Color.fromARGB(
    255,
    48,
    51,
    98,
  ); // Azul oscuro (Botón/Texto)
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

  // MÉTODO DE NAVEGACIÓN COMÚN PARA WEB Y MÓVIL - ACTUALIZADO
  void _handleLoginSuccess(BuildContext context, LoginState state) {
    print('✅ Login exitoso! Navegando...');
    print('Estado actual: $state');
    print('cargo: ${state.cargo}');
    print('usuario: ${state.usuario}');

    // Validar que tengamos los datos necesarios
    if (state.cargo == null || state.usuario == null) {
      AppNotification.error(
        context,
        'Error: Datos de usuario incompletos. Contacte al administrador.',
      );
      return;
    }

    // Usar WidgetsBinding para asegurar que el contexto esté disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Navegación por rol
      if (state.cargo == 'Root' || state.cargo == 'Administrador') {
        // Admin - ✅ CORREGIDO: Usamos el operador ! porque ya validamos que no es null
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdminDashboard(
              userName: state.usuario!,
              userRole: state.cargo!,
            ),
          ),
        );
      } else if (state.cargo == 'Conductor') {
        // Conductor - ✅ CORREGIDO: Usamos el operador ! porque ya validamos que no es null
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ConductorDashboard(
              userName: state.usuario!,
              userRole: state.cargo!,
            ),
          ),
        );
      } else {
        // Rol no reconocido
        AppNotification.warning(
          context,
          'Tu usuario no tiene un rol asignado. Comunícate con el administrador de JHT Transport.',
        );
      }

      // Limpiar campos después del login exitoso
      _usernameController.clear();
      _passwordController.clear();
    });
  }

  void _handleLoginError(BuildContext context, String error) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final errorLower = error.toLowerCase();

      // Si el mensaje es sobre intentos o cuenta bloqueada, mostramos un Dialog
      if (errorLower.contains('intento') ||
          errorLower.contains('bloquead') ||
          errorLower.contains('bloqueo') ||
          errorLower.contains('bloquear')) {
        final isBlocked = errorLower.contains('bloquead');
        
        String dialogContent = error;
        if (isBlocked) {
          dialogContent = '$error\n\nSu cuenta ha sido bloqueada. Por favor, comuníquese con el equipo TI ColdSolutions para restaurar su acceso.';
        } else {
          dialogContent = '$error\n\n⚠️ ¡Atención! Le advertimos que puede consultar al equipo TI ColdSolutions para la actualización de su password. De lo contrario, puede realizar un último intento, pero si falla, su cuenta será bloqueada.';
        }
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  isBlocked ? Icons.error_outline : Icons.warning_amber_rounded,
                  color: isBlocked ? Colors.red : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Advertencia de Seguridad',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(dialogContent, style: const TextStyle(fontSize: 15, height: 1.4)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Entendido',
                  style: TextStyle(
                    color: LoginPage.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        // Para errores comunes (ej. "Contraseña incorrecta", "Usuario no existe") usamos la notificación
        AppNotification.error(context, error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        print(' 2 Estado actual: $state');
        print('Cargo: ${state.cargo}');
        print('usuario: ${state.usuario}');
        print('error: ${state.error}');
        if (state.isSuccess) {
          _handleLoginSuccess(context, state);
        }
        if (state.error != null && state.error!.isNotEmpty) {
          _handleLoginError(context, state.error!);
        }
      },
      child: _buildResponsiveLayout(context),
    );
  }

  Widget _buildResponsiveLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWebOrTablet = size.width > 800;

    if (isWebOrTablet) {
      return _buildWebLayout();
    } else {
      return _buildMobileLayout(context, size.height);
    }
  }

  // --- VERSIÓN WEB ---
  Widget _buildWebLayout() {
    return Scaffold(
      body: Stack(
        children: [
          // FONDO COMPLETO CON LA IMAGEN Y OVERLAY
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/LoginWebFondo.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(
                0.3,
              ), // Un ligero oscurecimiento para resaltar el contenido
            ),
          ),

          // CONTENIDO PRINCIPAL CENTRADO
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 800),
              padding: const EdgeInsets.all(40),
              child: Row(
                children: [
                  // SECCIÓN DE BIENVENIDA (IZQUIERDA)
                  const Expanded(flex: 5, child: _WebWelcomeSection()),
                  const SizedBox(width: 60),
                  // FORMULARIO (DERECHA)
                  Expanded(
                    flex: 3,
                    child: FadeSlideAnimation(
                      delay: 0.6, // Se anima un poco después de la bienvenida
                      child: _WebLoginFormCard(
                        usernameController: _usernameController,
                        passwordController: _passwordController,
                        onLoginSuccess: () {
                          _usernameController.clear();
                          _passwordController.clear();
                          print('✅ Login web exitoso - Campos limpiados');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- VERSIÓN MÓVIL ---
  Widget _buildMobileLayout(BuildContext context, double totalHeight) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER con la onda usando ClipPath
            _buildMobileHeader(totalHeight),
            // 2. FORMULARIO DE LOGIN
            _buildMobileLoginForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader(double totalHeight) {
    final double headerHeight = totalHeight * 0.45;

    return SizedBox(
      height: headerHeight,
      child: Stack(
        children: [
          // 1. CAPA SECUNDARIA (Efecto de sombra/onda superpuesta translúcida)
          ClipPath(
            clipper: LoginWaveClipperSecondary(),
            child: Container(
              width: double.infinity,
              height: headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    LoginPage.primaryColor.withValues(alpha: 0.5),
                    const Color(0xFF4834D4).withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // 2. CAPA PRINCIPAL (Con la imagen y gradiente overlay)
          ClipPath(
            clipper: LoginWaveClipper(),
            child: FadeSlideAnimation(
              delay: 0.1,
              direction: AxisDirection.down, // Viene desde arriba
              child: Container(
                width: double.infinity,
                height: headerHeight,
                color: LoginPage.primaryColor,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Imagen de fondo
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/loginFondo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // OVERLAY GRADIENTE SOBRE LA IMAGEN PARA TOQUE PREMIUM
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            LoginPage.primaryColor.withValues(alpha: 0.7),
                            Colors.transparent,
                            const Color(0xFF4834D4).withValues(alpha: 0.4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLoginForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const FadeSlideAnimation(
            delay: 0.2,
            child: Center(
              child: Text(
                'JHT TRANSPORT\nCOMPANY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: LoginPage.primaryColor,
                  letterSpacing: 1.5,
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 45),
          FadeSlideAnimation(
            delay: 0.3,
            child: _LoginFormField(
              labelText: 'Username',
              icon: FontAwesomeIcons.solidUser,
              controller: _usernameController,
            ),
          ),
          const SizedBox(height: 30),
          FadeSlideAnimation(
            delay: 0.4,
            child: _LoginFormField(
              labelText: 'Password',
              icon: FontAwesomeIcons.lock,
              isPassword: true,
              controller: _passwordController,
            ),
          ),
          // MOSTRAR ERRORES DE FORMA VISIBLE
          BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              if (state.error != null && state.error!.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                  child: Text(
                    state.error!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox(height: 30);
            },
          ),
          FadeSlideAnimation(
            delay: 0.5,
            child: _LoginButton(
              color: LoginPage.buttonColor,
              usernameController: _usernameController,
              passwordController: _passwordController,
            ),
          ),
          const SizedBox(height: 40),
          const FadeSlideAnimation(delay: 0.6, child: CopyrightFooter()),
        ],
      ),
    );
  }
}

// --- WIDGETS REUTILIZABLES ---
class _LoginFormField extends StatefulWidget {
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
  State<_LoginFormField> createState() => _LoginFormFieldState();
}

class _LoginFormFieldState extends State<_LoginFormField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: Icon(widget.icon, size: 20, color: LoginPage.accentColor),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? FontAwesomeIcons.eyeSlash
                      : FontAwesomeIcons.eye,
                  size: 18,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LoginPage.accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}

class CopyrightFooter extends StatelessWidget {
  final String companyName;

  const CopyrightFooter({
    super.key,
    this.companyName = 'JHT Transport Company',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '© ${DateTime.now().year} $companyName. All rights reserved.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                  context.read<LoginBloc>().add(
                    LoginButtonPressed(
                      username: usernameController.text,
                      password: passwordController.text,
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: 8,
            shadowColor: color.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: state.isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(_slideAnimation.value, 0),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: const Text(
                      'INICIA SESIÓN',
                      textAlign: TextAlign.left,
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
              Transform.translate(
                offset: Offset(_slideAnimation.value * 0.8, 0),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: const Text(
                    'Soluciones logísticas confiables y eficientes para un transporte sin interrupciones. Inicia sesión y descubre cómo podemos optimizar tus operaciones de transporte.',
                    textAlign: TextAlign.left,
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
  final VoidCallback onLoginSuccess;

  const _WebLoginFormCard({
    required this.usernameController,
    required this.passwordController,
    required this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isSuccess) {
          print('Login exitoso en formulario web!');
          onLoginSuccess();
        }
        if (state.error != null) {
          AppNotification.error(context, state.error!);
        }
      },
      child: Card(
        elevation: 15,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Colors.white.withOpacity(0.97),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              _LoginButton(
                color: LoginPage.buttonColor,
                usernameController: usernameController,
                passwordController: passwordController,
              ),
              const SizedBox(height: 40),
              const Text(
                '© 2026 JHT Transport Company. All rights reserved.',
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

// --- WIDGET PARA ANIMACIONES DE ENTRADA ELEGANTES ---
class FadeSlideAnimation extends StatefulWidget {
  final Widget child;
  final double delay;
  final AxisDirection direction;

  const FadeSlideAnimation({
    super.key,
    required this.child,
    this.delay = 0.0,
    this.direction = AxisDirection.up,
  });

  @override
  State<FadeSlideAnimation> createState() => _FadeSlideAnimationState();
}

class _FadeSlideAnimationState extends State<FadeSlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Offset beginOffset;
    switch (widget.direction) {
      case AxisDirection.up:
        beginOffset = const Offset(0, 0.3);
        break;
      case AxisDirection.down:
        beginOffset = const Offset(0, -0.3);
        break;
      case AxisDirection.left:
        beginOffset = const Offset(0.3, 0);
        break;
      case AxisDirection.right:
        beginOffset = const Offset(-0.3, 0);
        break;
    }

    _offset = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
