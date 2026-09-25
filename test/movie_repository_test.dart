import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:showmovies/core/utils/connection_checker.dart';
import 'package:showmovies/core/errors/exceptions.dart';
import 'package:showmovies/features/movies/data/datasources/movie_local_data_sorce.dart';
import 'package:showmovies/features/movies/data/datasources/movie_remote_data_sorce.dart';
import 'package:showmovies/features/movies/data/models/movie_model.dart';
import 'package:showmovies/features/movies/data/repositories/movie_repository_impl.dart';

class MockMovieRemoteDataSource extends Mock implements MovieRemoteDataSourceImpl {}
class MockMovieLocalDataSource extends Mock implements MovieLocalDataSource {}
class MockNetworkInfo extends Mock implements NetWorkInfo {}

void main() {
  late MovieRepositoryImpl repository;
  late MockMovieRemoteDataSource mockRemoteDataSource;
  late MockMovieLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  final tMovieModel = MovieModel(id: 1, title: 'Test Movie', overview: 'Synopsis', posterPath: '/path', voteAverage: 8.5);
  final List<MovieModel> tMovieList = [tMovieModel];

  setUp(() {
    mockRemoteDataSource = MockMovieRemoteDataSource();
    mockLocalDataSource = MockMovieLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = MovieRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      netWorkInfo: mockNetworkInfo,
    );
  });

  group('MovieRepository - Tests de la Couche Dépôt (Offline/Online Mode)', () {
    
    // TEST 1 : Mode En Ligne - Succès de l'API et mise en cache locale
    test('Doit retourner les données de l\'API et les mettre en cache si l\'appareil est connecté', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getPopularMovies()).thenAnswer((_) async => tMovieList);
      when(() => mockLocalDataSource.cacheMovies(any())).thenAnswer((_) async => {});

      final result = await repository.getPopularMovies();

      expect(result, equals(tMovieList));
      verify(() => mockRemoteDataSource.getPopularMovies()).called(1);
      verify(() => mockLocalDataSource.cacheMovies(tMovieList)).called(1);
    });

    // TEST 2 : Mode Hors Ligne - Bascule transparente sur le cache Isar
    test('Doit retourner les données du cache local Isar si l\'appareil n\'a pas de connexion internet', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocalDataSource.getLastMovies()).thenAnswer((_) async => tMovieList);

      final result = await repository.getPopularMovies();

      expect(result, equals(tMovieList));
      verifyZeroInteractions(mockRemoteDataSource);
      verify(() => mockLocalDataSource.getLastMovies()).called(1);
    });

    // TEST 3 : Mode Hors Ligne Critique - Cache Vide
    test('Doit lever une Exception explicite si l\'appareil est déconnecté et que le cache Isar est vide', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocalDataSource.getLastMovies()).thenThrow(CacheException());

      expect(() => repository.getPopularMovies(), throwsA(isA<Exception>()));
    });
  });
}
