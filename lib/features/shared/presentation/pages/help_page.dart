// lib/features/shared/presentation/pages/help_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/scaffold_with_menu.dart';
import 'package:app_jht_front/core/services/version_checker_service.dart';

class HelpPage extends StatelessWidget {
  final String userName;
  final String userRole;

  const HelpPage({super.key, required this.userName, required this.userRole});

  // Colores de marca
  final Color primaryColor = const Color(0xFF303366);
  final Color accentColor = const Color(0xFF4834D4);
  final Color cardColor = Colors.white;

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir la URL: $url');
    }
  }

  Future<void> _launchWhatsApp() async {
    const String phone = '51992609046'; // Agregamos el prefijo de Perú
    const String message =
        'Hola ColdSolutions TI, necesito soporte con JHT Transporte Logístico.';
    final String url =
        "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";
    await _launchURL(url);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Centro de Ayuda',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: isMobile
            ? IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () {
                  context
                      .findAncestorStateOfType<ScaffoldWithMenuState>()
                      ?.openMobileMenu();
                },
              )
            : null,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Sobre el Sistema'),
                  _buildAboutCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Disponibilidad Multiplataforma'),
                  _buildPlatformCard(
                    icon: Icons.android_rounded,
                    title: 'Versión Android (APK)',
                    description:
                        'Instalación segura analizada por Google Play Protect.',
                    badgeText: 'Recomendado',
                    onTap: () => _showAndroidInfo(context),
                  ),
                  const SizedBox(height: 12),
                  _buildPlatformCard(
                    icon: Icons.language_rounded,
                    title: 'Versión Web',
                    description:
                        'Acceso inmediato sin instalación desde cualquier navegador.',
                    badgeText: 'Online',
                    onTap: () =>
                        _launchURL('https://app.jhttransportelogistica.com/'),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Soporte y Acompañamiento'),
                  _buildSupportCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Equipo de Desarrollo'),
                  _buildTeamCard(),
                  const SizedBox(height: 40),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/JHTmarca-transparente.png',
              height: 80,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.directions_bus_filled_rounded,
                size: 80,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'JHT Transporte Logístico',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Text(
              'Versión ${VersionCheckerService.localVersion}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.blueGrey[700],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Qué es JHT?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Es una plataforma tecnológica integral diseñada para optimizar, controlar y digitalizar los procesos de transporte y logística vehicular. Nuestro objetivo es mejorar la trazabilidad y la eficiencia operativa de su flota en tiempo real.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blueGrey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformCard({
    required IconData icon,
    required String title,
    required String description,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey[400],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Acompañamiento en Tiempo Real',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nuestro equipo brinda soporte directo durante la instalación y uso. Reporte dudas enviando capturas o evidencias.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _launchWhatsApp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(FontAwesomeIcons.whatsapp, size: 18),
            label: const Text(
              'CONTACTAR SOPORTE',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildTeamMember(
            'Jonathan Vera Segura',
            'Desarrollador de software y devops',
          ),
          const Divider(height: 24),
          _buildTeamMember(
            'Jimy Edson Mallqui Rodriguez',
            'Arquitecto de software y Analista',
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String name, String role) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.1),
          child: Text(
            name[0],
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                role,
                style: TextStyle(fontSize: 12, color: Colors.blueGrey[400]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          '© 2026 JHT Transporte Mantenimiento',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Todos los derechos reservados. Aplicación de uso exclusivo.',
          style: TextStyle(fontSize: 11, color: Colors.blueGrey[400]),
        ),
        const SizedBox(height: 24),
        Text(
          'Desarrollado por',
          style: TextStyle(fontSize: 11, color: Colors.blueGrey[400]),
        ),
        const SizedBox(height: 4),
        const Text(
          'ColdSolutions TI',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: Color(0xFF303366),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Soluciones tecnológicas que impulsan tu negocio',
          style: TextStyle(fontSize: 10, color: Colors.blueGrey[400]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'RUC: 10477365596',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showAndroidInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.security_rounded, color: Colors.green),
            SizedBox(width: 12),
            Text('Seguridad Android'),
          ],
        ),
        content: const Text(
          'La aplicación ha sido analizada por Google Play Protect, confirmando que es confiable y segura.\n\nAl tratarse de una versión preliminar, Android puede mostrar avisos estándar de seguridad. Estos mensajes son normales y no representan ningún riesgo.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ENTENDIDO'),
          ),
        ],
      ),
    );
  }
}
