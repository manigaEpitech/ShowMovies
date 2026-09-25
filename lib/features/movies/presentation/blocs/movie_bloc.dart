import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showmovies/core/utils/connection_checker.dart';

import '../../domain/repositories/movie_repository.dart';
import 'movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository movieRepository;
  final NetWorkInfo netWorkInfo;

  MovieBloc({required this.movieRepository, required this.netWorkInfo})
    : super(MovieInitial()) {
    on<FetchPopularMovies>((event, emit) async {
      emit(MovieLoading());

      try {
        // Le depot initial
        final movies = await movieRepository.getPopularMovies();

        //Verification du reseau
        final isConnected = await netWorkInfo.isConnected;

        emit(MovieLoaded(movies: movies, isOffline: !isConnected));
      } catch (e) {
        emit(MovieError(message: e.toString().replaceAll('Exeception: ', '')));
      }
    });
  }
}
