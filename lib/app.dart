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
import 'package:air_plane_ticketing/features/seats/data/datasources/seats_remote_data_source.dart';
import 'package:air_plane_ticketing/features/seats/data/repositories/seats_repository_impl.dart';
import 'package:air_plane_ticketing/features/seats/domain/repositories/seats_repository.dart';
import 'package:air_plane_ticketing/features/seats/presentation/providers/seats_provider.dart';
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
          update: (_, apiClient, _) => TripsRemoteDataSource(apiClient),
        ),
        ProxyProvider<TripsRemoteDataSource, TripsRepository>(
          update: (_, source, _) => TripsRepositoryImpl(source),
        ),
        ChangeNotifierProxyProvider<TripsRepository, TripsProvider>(
          create: (context) => TripsProvider(context.read<TripsRepository>()),
          update: (_, repository, previous) =>
              previous ?? TripsProvider(repository),
        ),

        ProxyProvider<ApiClient, RoutesRemoteDataSource>(
          update: (_, apiClient, _) => RoutesRemoteDataSource(apiClient),
        ),
        ProxyProvider<RoutesRemoteDataSource, RoutesRepository>(
          update: (_, source, _) => RoutesRepositoryImpl(source),
        ),
        ChangeNotifierProxyProvider<RoutesRepository, RoutesProvider>(
          create: (context) => RoutesProvider(context.read<RoutesRepository>()),
          update: (_, repository, previous) =>
              previous ?? RoutesProvider(repository),
        ),

        ProxyProvider<ApiClient, SeatsRemoteDataSource>(
          update: (_, apiClient, _) => SeatsRemoteDataSource(apiClient),
        ),
        ProxyProvider<SeatsRemoteDataSource, SeatsRepository>(
          update: (_, source, _) => SeatsRepositoryImpl(source),
        ),
        ChangeNotifierProxyProvider<SeatsRepository, SeatsProvider>(
          create: (context) => SeatsProvider(context.read<SeatsRepository>()),
          update: (_, repository, previous) =>
              previous ?? SeatsProvider(repository),
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
