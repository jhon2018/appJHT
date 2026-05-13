// lib/features/shared/presentation/mixins/navigation_helper_mixin.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

mixin NavigationHelperMixin<T extends StatefulWidget> on State<T> {
  void navigateToMenuPage(BuildContext context, String pageName, String userName, String userRole) {
    switch (pageName) {
      case 'Panel':
        if (userRole == 'Root' || userRole == 'Administrador') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDashboard(userName: userName, userRole: userRole),
            ),
          );
        } else if (userRole == 'Conductor') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConductorDashboard(userName: userName, userRole: userRole),
            ),
          );
        }
        break;
      case 'Vehículo':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) {
                final vehicleDataSource = VehicleRemoteDataSourceImpl(httpClient: HttpClient());
                final vehicleRepository = VehicleRepositoryImpl(remoteDataSource: vehicleDataSource);
                return VehicleBloc(
                  registrarVehiculoUseCase: RegistrarVehiculoUseCase(vehicleRepository),
                  listarVehiculosUseCase: ListarVehiculosUseCase(vehicleRepository),
                  actualizarVehiculoUseCase: ActualizarVehiculoUseCase(vehicleRepository),
                );
              },
              child: VehiclePage(userName: userName, userRole: userRole),
            ),
          ),
        );
        break;
      case 'Mantenimiento':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => MantenimientoBloc(repository: MantenimientoRepository())
                ..add(LoadMantenimientosEvent()),
              child: MantenimientoPage(userName: userName, userRole: userRole),
            ),
          ),
        );
        break;
      case 'Proveedor':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SupplierPage(userName: userName, userRole: userRole),
          ),
        );
        break;
      case 'Colaboradores':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              final remoteDataSource = ConductorRemoteDataSourceImpl();
              final repository = ConductorRepositoryImpl(remoteDataSource: remoteDataSource);

              return BlocProvider(
                create: (context) => ConductorBloc(
                  registrarConductorUseCase: RegistrarConductorUseCase(repository: repository),
                  listarPersonasUseCase: ListarPersonasUseCase(repository: repository),
                  obtenerPersonaDetalleUseCase: ObtenerPersonaDetalleUseCase(repository: repository),
                  actualizarPersonaUseCase: ActualizarPersonaUseCase(repository: repository),
                  conductorRepository: repository,
                )..add(const ConductorEvent.listarPersonas()),
                child: ConductorPage(userName: userName, userRole: userRole, dataSource: remoteDataSource),
              );
            },
          ),
        );
        break;
      case 'Accesorios':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) {
                final accessoryDataSource = AccessoryRemoteDataSourceImpl(httpClient: HttpClient());
                final accessoryRepository = AccessoryRepositoryImpl(remoteDataSource: accessoryDataSource);
                return AccessoryBloc(repository: accessoryRepository);
              },
              child: AccessoryPage(userName: userName, userRole: userRole),
            ),
          ),
        );
        break;
      case 'Ayuda':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HelpPage(userName: userName, userRole: userRole),
          ),
        );
        break;
      default:
        AppNotification.warning(context, '$pageName — Página en desarrollo.');
        print('Navegación a $pageName no implementada.');
    }
  }
}
