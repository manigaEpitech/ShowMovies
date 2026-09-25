// lib/core/di/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:showmovies/core/utils/connection_checker.dart';

import '../network/dio_client.dart';
import '../network/auth_interceptor.dart'; // Nouvel intercepteur JWT

import 'package:showmovies/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:showmovies/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:showmovies/features/auth/presentation/blocs/auth_bloc.dart';

import 'package:showmovies/features/movies/data/datasources/movie_local_data_sorce.dart';
import 'package:showmovies/features/movies/data/datasources/movie_remote_data_sorce.dart';
import 'package:showmovies/features/movies/data/models/movie_model.dart';
import 'package:showmovies/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:showmovies/features/movies/domain/repositories/movie_repository.dart';
import 'package:showmovies/features/movies/presentation/blocs/movie_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- 1. EXTERNAL & CORE MODULES ---

  // A. Authentification Firebase
  if (!sl.isRegistered<FirebaseAuth>()) {
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }

  // B. Base de données locale Isar
  final Isar isar;
  if (kIsWeb) {
    isar =
        Isar.getInstance() ??
        await Isar.open([MovieModelSchema], directory: '');
  } else {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        Isar.getInstance() ??
        await Isar.open([MovieModelSchema], directory: dir.path);
  }
  if (!sl.isRegistered<Isar>()) sl.registerSingleton<Isar>(isar);

  // C. Outils de connectivité et vérification réseau
  if (!sl.isRegistered<InternetConnection>()) {
    sl.registerLazySingleton(() => InternetConnection());
  }
  if (!sl.isRegistered<NetWorkInfo>()) {
    sl.registerLazySingleton<NetWorkInfo>(
      () => NetworkInfoImpl(sl<InternetConnection>()),
    );
  }

  // D. Réseau : Enregistrement de l'intercepteur avec ciblage explicite de FirebaseAuth
  if (!sl.isRegistered<AuthInterceptor>()) {
    sl.registerLazySingleton(() => AuthInterceptor(sl<FirebaseAuth>()));
  }

  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton(() {
      final client = DioClient();
      client.dio.interceptors.add(sl<AuthInterceptor>());
      return client;
    });
  }

  // --- 2. FEATURE : AUTHENTICATION ---
  sl.registerFactory(() => AuthBloc(authRepository: sl<AuthRepositoryImpl>()));

  // 🔥 CORRECTION ICI : Injection explicite de FirebaseAuth pour éliminer l'erreur 'Dio cannot be assigned'
  sl.registerLazySingleton(
    () => AuthRemoteDataSource(firebaseAuth: sl<FirebaseAuth>()),
  );

  sl.registerLazySingleton(
    () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );

  // --- 3. FEATURE : MOVIES ---
  sl.registerFactory(
    () => MovieBloc(
      movieRepository: sl<MovieRepository>(),
      netWorkInfo: sl<NetWorkInfo>(),
    ),
  );

  // Enregistrement de l'interface pure MovieRepository
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(
      remoteDataSource: sl<MovieRemoteDataSourceImpl>(),
      localDataSource: sl<MovieLocalDataSource>(),
      netWorkInfo: sl<NetWorkInfo>(),
    ),
  );

  sl.registerLazySingleton(
    () => MovieRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );
  sl.registerLazySingleton(() => MovieLocalDataSource(sl<Isar>()));
}
