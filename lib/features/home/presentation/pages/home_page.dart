// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import '../../../login/presentation/pages/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JHT Transport - Inicio'),
        backgroundColor: LoginPage.primaryColor,
      ),
      body: const Center(
        child: Text(
          'Bienvenido a JHT Transport',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}