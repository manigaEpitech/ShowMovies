import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_local_data_sorce.dart';
import '../datasources/movie_remote_data_sorce.dart';
import '../models/movie_model.dart';
import '../../../../core/utils/connection_checker.dart';
import '../../../../core/errors/exceptions.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;
  final NetWorkInfo netWorkInfo;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.netWorkInfo,
  });

  @override
  Future<List<MovieModel>> getPopularMovies() async {
    // Verifier si l'appareil dispose de connection
    if (await netWorkInfo.isConnected) {
      try {
        // si ok on recupere les films depuis API
        final remoteMovies = await remoteDataSource.getPopularMovies();

        // puis mettre a jour le cach local
        await localDataSource.cacheMovies(remoteMovies);

        return remoteMovies;
      } on ServerException {
        // En cas de panne serveur inattendue (ex: erreur 500), on tente quand même de lire le cache
        return await _loadLocalCacheOrThrow();
      }
    } else {
      //Mode Hors ligne : Charger immédiatement les données locales mis en cache
      return _loadLocalCacheOrThrow();
    }
  }

  Future<List<MovieModel>> _loadLocalCacheOrThrow() async {
    try {
      final localMovies = await localDataSource.getLastMovies();
      return localMovies;
    } on CacheException {
      // Échec si le cache local est totalement vide et qu'il n'y a pas de réseau
      throw Exception(
        "Vous êtes hors ligne et aucune donnée locale n'est disponible. Veuillez vous connecter.",
      );
    }
  }
}
