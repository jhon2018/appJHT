// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:app_jht_front/core/network/http_client.dart';
import 'package:app_jht_front/core/utils/token_service.dart';

// Modales / Wrappers
import 'package:app_jht_front/features/shared/presentation/widgets/scaffold_with_menu.dart';

// Welcome & Login
import 'package:app_jht_front/features/welcome/presentation/pages/welcome_page.dart';
import 'package:app_jht_front/features/login/presentation/pages/login_page.dart';
import 'package:app_jht_front/features/login/presentation/bloc/login_bloc.dart';

// Dashboard
import 'package:app_jht_front/features/admin/presentation/pages/admin_dashboard.dart';
import 'package:app_jht_front/features/conductor/presentation/pages/conductor_dashboard.dart';

// Vehículos
import 'package:app_jht_front/features/vehicle/presentation/pages/vehicle_page.dart';
import 'package:app_jht_front/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:app_jht_front/features/vehicle/data/datasources/vehicle_remote_data_source.dart';
import 'package:app_jht_front/features/vehicle/data/repositories/vehicle_repository_impl.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/actualizar_vehiculo_usecase.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/listar_vehiculos_usecase.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/registrar_vehiculo_usecase.dart';

// Proveedores
import 'package:app_jht_front/features/supplier/presentation/pages/supplier_page.dart';

// Colaboradores (Conductores)
import 'package:app_jht_front/features/conductor/presentation/pages/conductor_page.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_bloc.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_event.dart';
import 'package:app_jht_front/features/conductor/data/datasources/conductor_remote_data_source.dart';
import 'package:app_jht_front/features/conductor/data/repositories/conductor_repository_impl.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/actualizar_persona_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/listar_personas_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/obtener_persona_detalle_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/registrar_conductor_usecase.dart';

// Mantenimiento
import 'package:app_jht_front/features/mantenimiento/presentation/pages/mantenimiento_page.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:app_jht_front/features/mantenimiento/data/repositories/mantenimiento_repository.dart';

// Accesorios
import 'package:app_jht_front/features/accessory/presentation/pages/accessory_page.dart';
import 'package:app_jht_front/features/accessory/presentation/bloc/accessory_bloc.dart';
import 'package:app_jht_front/features/accessory/domain/repositories/accessory_repository_impl.dart';
import 'package:app_jht_front/features/accessory/data/datasources/accessory_remote_data_source.dart';

// Ayuda
import 'package:app_jht_front/features/shared/presentation/pages/help_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/welcome',
  routes: [
    // --- RUTAS SIN SHELL (SIN MENÚ LATERAL) ---
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => BlocProvider(
        create: (context) => LoginBloc(),
        child: const LoginPage(),
      ),
    ),
    
    // --- RUTAS CON SHELL (CON MENÚ LATERAL PERSISTENTE) ---
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithMenu(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) {
            return AuthWrapper(
              builder: (context, userName, userRole) {
                if (userRole == 'Root' || userRole == 'Administrador') {
                  return AdminDashboard(userName: userName, userRole: userRole);
                } else {
                  return ConductorDashboard(userName: userName, userRole: userRole);
                }
              },
            );
          },
        ),
        GoRoute(
          path: '/vehiculos',
          builder: (context, state) {
            final vehicleDataSource = VehicleRemoteDataSourceImpl(httpClient: HttpClient());
            final vehicleRepository = VehicleRepositoryImpl(remoteDataSource: vehicleDataSource);
            return BlocProvider(
              create: (context) => VehicleBloc(
                registrarVehiculoUseCase: RegistrarVehiculoUseCase(vehicleRepository),
                listarVehiculosUseCase: ListarVehiculosUseCase(vehicleRepository),
                actualizarVehiculoUseCase: ActualizarVehiculoUseCase(vehicleRepository),
              ),
              child: AuthWrapper(
                builder: (context, userName, userRole) {
                  return VehiclePage(
                    userName: userName,
                    userRole: userRole,
                  );
                },
              ),
            );
          },
        ),
        GoRoute(
          path: '/proveedores',
          builder: (context, state) {
            return AuthWrapper(
              builder: (context, userName, userRole) {
                return SupplierPage(
                  userName: userName,
                  userRole: userRole,
                );
              },
            );
          },
        ),
        GoRoute(
          path: '/colaboradores',
          builder: (context, state) {
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
              child: AuthWrapper(
                builder: (context, userName, userRole) {
                  return ConductorPage(
                    userName: userName,
                    userRole: userRole,
                    dataSource: remoteDataSource,
                  );
                },
              ),
            );
          },
        ),
        GoRoute(
          path: '/mantenimiento',
          builder: (context, state) {
            final repository = MantenimientoRepository();
            return BlocProvider(
              create: (context) => MantenimientoBloc(repository: repository)
                ..add(LoadMantenimientosEvent()),
              child: AuthWrapper(
                builder: (context, userName, userRole) {
                  return MantenimientoPage(
                    userName: userName,
                    userRole: userRole,
                  );
                },
              ),
            );
          },
        ),
        GoRoute(
          path: '/accesorios',
          builder: (context, state) {
            final accessoryDataSource = AccessoryRemoteDataSourceImpl(httpClient: HttpClient());
            final accessoryRepository = AccessoryRepositoryImpl(remoteDataSource: accessoryDataSource);
            return BlocProvider(
              create: (context) => AccessoryBloc(repository: accessoryRepository),
              child: AuthWrapper(
                builder: (context, userName, userRole) {
                  return AccessoryPage(
                    userName: userName,
                    userRole: userRole,
                  );
                },
              ),
            );
          },
        ),
        GoRoute(
          path: '/ayuda',
          builder: (context, state) {
            return AuthWrapper(
              builder: (context, userName, userRole) {
                return HelpPage(
                  userName: userName,
                  userRole: userRole,
                );
              },
            );
          },
        ),
      ]
    ),
  ],
);

// Wrapper para evitar FutureBuilder loop en GoRouter
class AuthWrapper extends StatefulWidget {
  final Widget Function(BuildContext context, String userName, String userRole) builder;
  
  const AuthWrapper({super.key, required this.builder});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _userName;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    TokenService.getUserData().then((data) {
      if (mounted) {
        setState(() {
          _userName = data?['usuario'] ?? '';
          _userRole = data?['cargo'] ?? '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userName == null || _userRole == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return widget.builder(context, _userName!, _userRole!);
  }
}
