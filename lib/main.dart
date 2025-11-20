//ruta: lib/main.dart
//descripción: Punto de entrada principal de la aplicación Flutter, configurando el tema y la pantalla inicial.

// import 'package:app_jht_front/core/network/http_client.dart';
import 'package:app_jht_front/features/accessory/domain/repositories/accessory_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/welcome/presentation/pages/welcome_page.dart';
import 'features/login/presentation/bloc/login_bloc.dart';
import 'features/login/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';
// En tu main.dart
// main.dart
import 'package:app_jht_front/core/network/http_client.dart';
import 'package:app_jht_front/features/vehicle/data/datasources/vehicle_remote_data_source.dart';
import 'package:app_jht_front/features/vehicle/data/repositories/vehicle_repository_impl.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/registrar_vehiculo_usecase.dart';
import 'package:app_jht_front/features/vehicle/presentation/bloc/vehicle_bloc.dart';

import 'package:app_jht_front/features/accessory/presentation/bloc/accessory_bloc.dart';
import 'package:app_jht_front/features/accessory/domain/repositories/accessory_repository_impl.dart';
import 'package:app_jht_front/features/accessory/data/datasources/accessory_remote_data_source.dart';

void main() {
  // DevHttpClient.ignoreSslErrors(); // Ignorar errores SSL en desarrollo temporalmente

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginBloc()),
        // Agrega el VehicleBloc y su configuración aquí
        BlocProvider(
          create: (context) => VehicleBloc(
            registrarVehiculoUseCase: RegistrarVehiculoUseCase(
              repository: VehicleRepositoryImpl(
                remoteDataSource: VehicleRemoteDataSourceImpl(
                  httpClient: DevHttpClient(), // ← Agregado aquí
                ),
              ),
            ),
          ),
        ),
        // AGREGAR ESTE PROVIDER PARA ACCESSORY_BLOC
        BlocProvider(create: (context) => AccessoryBloc(
          repository: AccessoryRepositoryImpl(
            remoteDataSource: AccessoryRemoteDataSourceImpl(
              httpClient: DevHttpClient(),
            ),
          ),
        )),
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
