import 'package:air_plane_ticketing/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:air_plane_ticketing/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:air_plane_ticketing/features/profile/domain/repositories/profile_repository.dart';
import 'package:air_plane_ticketing/features/profile/presentation/providers/profile_provider.dart';
import 'package:air_plane_ticketing/features/routes/data/datasources/routes_remote_data_source.dart';
import 'package:air_plane_ticketing/features/routes/data/repositories/routes_repository_impl.dart';
import 'package:air_plane_ticketing/features/routes/domain/repositories/routes_repository.dart';
import 'package:air_plane_ticketing/features/routes/presentation/providers/routes_provider.dart';
import 'package:air_plane_ticketing/features/trips/data/datasources/trips_remote_data_source.dart';
import 'package:air_plane_ticketing/features/trips/data/repositories/trips_repository_impl.dart';
import 'package:air_plane_ticketing/features/trips/domain/repositories/trips_repository.dart';
import 'package:air_plane_ticketing/features/trips/presentation/providers/trips_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/secure_storage_service.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

import 'features/splash/presentation/screens/splash_screen.dart';

class AirplaneTicketingApp extends StatelessWidget {
  const AirplaneTicketingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. HTTP client
        Provider<ApiClient>(
          create: (_) => ApiClient(),
          dispose: (_, client) => client.dispose(),
        ),

        // 2. Secure storage
        Provider<SecureStorageService>(create: (_) => SecureStorageService()),

        // 3. Remote data source
        ProxyProvider2<ApiClient, SecureStorageService, AuthRemoteDataSource>(
          update: (_, apiClient, storage, _) {
            return AuthRemoteDataSource(apiClient, storage);
          },
        ),

        // 4. Repository
        ProxyProvider2<
          AuthRemoteDataSource,
          SecureStorageService,
          AuthRepository
        >(
          update: (_, remoteDataSource, storage, _) {
            return AuthRepositoryImpl(remoteDataSource, storage);
          },
        ),

        // 5. Authentication provider
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
        ),

        ProxyProvider2<
          ApiClient,
          SecureStorageService,
          ProfileRemoteDataSource
        >(
          update: (_, apiClient, storage, _) =>
              ProfileRemoteDataSource(apiClient, storage),
        ),
        ProxyProvider<ProfileRemoteDataSource, ProfileRepository>(
          update: (_, dataSource, _) => ProfileRepositoryImpl(dataSource),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (context) =>
              ProfileProvider(context.read<ProfileRepository>()),
        ),

        ProxyProvider<ApiClient, TripsRemoteDataSource>(
          update: (_, apiClient, __) => TripsRemoteDataSource(apiClient),
        ),
        ProxyProvider<TripsRemoteDataSource, TripsRepository>(
          update: (_, source, __) => TripsRepositoryImpl(source),
        ),
        ChangeNotifierProxyProvider<TripsRepository, TripsProvider>(
          create: (context) => TripsProvider(context.read<TripsRepository>()),
          update: (_, repository, previous) =>
              previous ?? TripsProvider(repository),
        ),

        ProxyProvider<ApiClient, RoutesRemoteDataSource>(
          update: (_, apiClient, __) => RoutesRemoteDataSource(apiClient),
        ),
        ProxyProvider<RoutesRemoteDataSource, RoutesRepository>(
          update: (_, source, __) => RoutesRepositoryImpl(source),
        ),
        ChangeNotifierProxyProvider<RoutesRepository, RoutesProvider>(
          create: (context) => RoutesProvider(context.read<RoutesRepository>()),
          update: (_, repository, previous) =>
              previous ?? RoutesProvider(repository),
        ),
      ],
      child: MaterialApp(
        title: 'Airplane Ticketing System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(filled: true),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
