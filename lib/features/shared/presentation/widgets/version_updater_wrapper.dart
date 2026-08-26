import 'package:flutter/material.dart';
import 'package:app_jht_front/core/services/version_checker_service.dart';
import 'package:app_jht_front/core/theme/maintenance_colors.dart';

class VersionUpdaterWrapper extends StatefulWidget {
  final Widget child;

  const VersionUpdaterWrapper({super.key, required this.child});

  @override
  State<VersionUpdaterWrapper> createState() => _VersionUpdaterWrapperState();
}

class _VersionUpdaterWrapperState extends State<VersionUpdaterWrapper> with WidgetsBindingObserver {
  final VersionCheckerService _checkerService = VersionCheckerService();
  bool _dialogIsShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Configurar listener
    _checkerService.onUpdateAvailable = _showUpdateDialog;
    
    // Verificar al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkerService.checkVersion();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkerService.checkVersion();
    }
  }

  void _showUpdateDialog(UpdateState state, VersionInfo remoteInfo, String localVersion) {
    if (_dialogIsShowing) return;

    final isMandatory = state == UpdateState.mandatory;

    _dialogIsShowing = true;

    showDialog(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (context) {
        return PopScope(
          canPop: !isMandatory,
          child: AlertDialog(
            title: Row(
              children: [
                Icon(
                  isMandatory ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                  color: isMandatory ? MaintenanceColors.error : MaintenanceColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isMandatory ? 'Actualización requerida' : 'Nueva versión disponible',
                    style: TextStyle(
                      color: isMandatory ? MaintenanceColors.error : MaintenanceColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMandatory
                      ? 'Esta versión de JHT ya no es compatible.'
                      : 'JHT Transporte Logístico tiene una nueva versión.',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text('Versión actual: $localVersion', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(isMandatory ? 'Versión requerida: ${remoteInfo.version}' : 'Nueva versión: ${remoteInfo.version}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              if (!isMandatory)
                TextButton(
                  onPressed: () {
                    _dialogIsShowing = false;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Más tarde', style: TextStyle(color: MaintenanceColors.textSecondary)),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMandatory ? MaintenanceColors.error : MaintenanceColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _checkerService.performUpdate();
                },
                child: const Text('Actualizar ahora'),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      _dialogIsShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
