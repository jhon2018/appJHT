// ruta: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_jht_front/features/welcome/presentation/pages/welcome_page.dart';
import 'package:app_jht_front/features/login/presentation/bloc/login_bloc.dart';
import 'package:app_jht_front/features/login/presentation/pages/login_page.dart';
import 'package:app_jht_front/features/home/presentation/pages/home_page.dart';
import 'package:app_jht_front/core/network/http_client.dart';

// Vehicle imports
import 'package:app_jht_front/features/vehicle/data/datasources/vehicle_remote_data_source.dart';
import 'package:app_jht_front/features/vehicle/data/repositories/vehicle_repository_impl.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/registrar_vehiculo_usecase.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/listar_vehiculos_usecase.dart';
import 'package:app_jht_front/features/vehicle/presentation/bloc/vehicle_bloc.dart';

// Accessory imports
import 'package:app_jht_front/features/accessory/presentation/bloc/accessory_bloc.dart';
import 'package:app_jht_front/features/accessory/data/datasources/accessory_remote_data_source.dart';
import 'package:app_jht_front/features/accessory/domain/repositories/accessory_repository_impl.dart';

// Conductor imports
import 'package:app_jht_front/features/conductor/data/datasources/conductor_remote_data_source.dart';
import 'package:app_jht_front/features/conductor/data/repositories/conductor_repository_impl.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/registrar_conductor_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/listar_personas_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/obtener_persona_detalle_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/actualizar_persona_usecase.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_bloc.dart';

// Mantenimiento imports
import 'package:app_jht_front/features/mantenimiento/data/repositories/mantenimiento_repository.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginBloc()),
        
        // VehicleBloc
// VehicleBloc
// VehicleBloc
BlocProvider(
  create: (context) {
    final vehicleDataSource = VehicleRemoteDataSourceImpl(
      httpClient: HttpClient(),
    );
    
    final vehicleRepository = VehicleRepositoryImpl(
      remoteDataSource: vehicleDataSource,
    );
    
    return VehicleBloc(
      registrarVehiculoUseCase: RegistrarVehiculoUseCase(vehicleRepository),
      listarVehiculosUseCase: ListarVehiculosUseCase(vehicleRepository),
    );
  },
),
        
        // AccessoryBloc
        BlocProvider(
          create: (context) => AccessoryBloc(
            repository: AccessoryRepositoryImpl(
              remoteDataSource: AccessoryRemoteDataSourceImpl(
                httpClient: HttpClient(),
              ),
            ),
          ),
        ),

        // ConductorBloc
        BlocProvider(
          create: (context) {
            final repository = ConductorRepositoryImpl(
              remoteDataSource: ConductorRemoteDataSourceImpl(),
            );

            return ConductorBloc(
              registrarConductorUseCase: RegistrarConductorUseCase(
                repository: repository,
              ),
              listarPersonasUseCase: ListarPersonasUseCase(
                repository: repository,
              ),
              obtenerPersonaDetalleUseCase: ObtenerPersonaDetalleUseCase(
                repository: repository,
              ),
              actualizarPersonaUseCase: ActualizarPersonaUseCase(
                repository: repository,
              ),
              conductorRepository: repository,
            );
          },
        ),
        
        // MantenimientoBloc
        BlocProvider(
          create: (context) => MantenimientoBloc(
            repository: MantenimientoRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'JHT Transport',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: WelcomePage.primaryColor,
          ),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          '/welcome': (context) => const WelcomePage(),
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage(),
        },
        initialRoute: '/welcome',
      ),
    );
  }
}