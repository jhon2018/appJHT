// lib/features/shared/presentation/mixins/navigation_helper_mixin.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_jht_front/core/network/http_client.dart';
import 'package:app_jht_front/core/widgets/app_notification.dart';

import 'package:app_jht_front/features/accessory/presentation/pages/accessory_page.dart';
import 'package:app_jht_front/features/accessory/presentation/bloc/accessory_bloc.dart';
import 'package:app_jht_front/features/accessory/domain/repositories/accessory_repository_impl.dart';
import 'package:app_jht_front/features/accessory/data/datasources/accessory_remote_data_source.dart';

import 'package:app_jht_front/features/conductor/presentation/pages/conductor_page.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_bloc.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_event.dart';
import 'package:app_jht_front/features/conductor/data/datasources/conductor_remote_data_source.dart';
import 'package:app_jht_front/features/conductor/data/repositories/conductor_repository_impl.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/actualizar_persona_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/listar_personas_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/obtener_persona_detalle_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/registrar_conductor_usecase.dart';

import 'package:app_jht_front/features/mantenimiento/presentation/pages/mantenimiento_page.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:app_jht_front/features/mantenimiento/data/repositories/mantenimiento_repository.dart';

import 'package:app_jht_front/features/supplier/presentation/pages/supplier_page.dart';

import 'package:app_jht_front/features/vehicle/presentation/pages/vehicle_page.dart';
import 'package:app_jht_front/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:app_jht_front/features/vehicle/data/datasources/vehicle_remote_data_source.dart';
import 'package:app_jht_front/features/vehicle/data/repositories/vehicle_repository_impl.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/actualizar_vehiculo_usecase.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/listar_vehiculos_usecase.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/registrar_vehiculo_usecase.dart';

import 'package:app_jht_front/features/admin/presentation/pages/admin_dashboard.dart';
import 'package:app_jht_front/features/conductor/presentation/pages/conductor_dashboard.dart';
import 'package:app_jht_front/features/shared/presentation/pages/help_page.dart';
import 'package:flutter/foundation.dart';

mixin NavigationHelperMixin<T extends StatefulWidget> on State<T> {
  void navigateToMenuPage(BuildContext context, String pageName, String userName, String userRole) {
    if (pageName == 'Panel') {
      context.go('/dashboard');
    } else if (pageName == 'Vehículo') {
      context.go('/vehiculos');
    } else if (pageName == 'Mantenimiento') {
      context.go('/mantenimiento');
    } else if (pageName == 'Proveedor') {
      context.go('/proveedores');
    } else if (pageName == 'Colaboradores') {
      context.go('/colaboradores');
    } else if (pageName == 'Accesorios') {
      context.go('/accesorios');
    } else if (pageName == 'Ayuda') {
      context.go('/ayuda');
    } else {
      AppNotification.warning(context, '$pageName — Página en desarrollo.');
      debugPrint('Navegación a $pageName no implementada.');
    }
  }
}
