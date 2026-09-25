import '../../data/models/movie_model.dart';

abstract class MovieRepository {
  Future<List<MovieModel>> getPopularMovies();
}
