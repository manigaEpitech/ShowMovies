import 'package:isar_community/isar.dart';

import '../models/movie_model.dart';
import '../../../../core/errors/exceptions.dart';

class MovieLocalDataSource {
  final Isar isar;

  MovieLocalDataSource(this.isar);

  // Sauvegarder les films  récupérés de l'API dans le cache local
  Future<void> cacheMovies(List<MovieModel> moviesToCache) async {
    await isar.writeTxn(() async {
      await isar.movieModels.putAll(moviesToCache);
    });
  }

  // Récupérer les films du cache Isar hor réseau
  Future<List<MovieModel>> getLastMovies() async {
    final movies = await isar.movieModels.where().findAll();
    if (movies.isNotEmpty) {
      return movies;
    } else {
      throw CacheException(); // Erreur si le cache est complètement vide
    }
  }
}
