// lib/core/di/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:isar_community/isar.dart'; // Maintien de votre import isar_community
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Vos autres imports restent identiques...
import 'package:showmovies/core/utils/connection_checker.dart';

import '../network/dio_client.dart';

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
  // Instanciation de la variable Isar pour la stocker ensuite
  final Isar isar;

  // 1. EXTERNAL & CORE MODULES - Initialisation multiplateforme Isar v3 (isar_community)
  if (kIsWeb) {
    // 🌐 Sur le Web (Edge) : On n'indique pas de répertoire, Isar gère IndexedDB nativement
    isar =
        Isar.getInstance() ??
        await Isar.open([MovieModelSchema], directory: '');
  } else {
    // 📱 Sur Mobile (Tecno) : On récupère obligatoirement le chemin physique
    final dir = await getApplicationDocumentsDirectory();
    isar =
        Isar.getInstance() ??
        await Isar.open(
          [MovieModelSchema],
          directory: dir.path, // Reçoit une String non-nulle garantie
        );
  }

  if (!sl.isRegistered<Isar>()) {
    sl.registerSingleton<Isar>(isar);
  }
  if (!sl.isRegistered<FirebaseAuth>()) {
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }

  // 2. RESTE DE VOS ENREGISTREMENTS (Dio, Blocs, Repositories...)
  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton(() => DioClient());
  }
  if (!sl.isRegistered<InternetConnection>()) {
    sl.registerLazySingleton(() => InternetConnection());
  }

  if (!sl.isRegistered<NetWorkInfo>()) {
    sl.registerLazySingleton<NetWorkInfo>(() => NetworkInfoImpl(sl()));
  }

  // Auth Feature
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerLazySingleton(() => AuthRemoteDataSource(firebaseAuth: sl()));
  sl.registerLazySingleton(() => AuthRepositoryImpl(remoteDataSource: sl()));

  // Movies Feature
  sl.registerFactory(() => MovieBloc(movieRepository: sl(), netWorkInfo: sl()));

  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(
      remoteDataSource: sl<MovieRemoteDataSourceImpl>(),
      localDataSource: sl<MovieLocalDataSource>(),
      netWorkInfo: sl<NetWorkInfo>(),
    ),
  );

  sl.registerLazySingleton(() => MovieRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton(() => MovieLocalDataSource(sl()));
}
