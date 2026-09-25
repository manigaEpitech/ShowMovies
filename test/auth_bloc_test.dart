import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:showmovies/features/auth/domain/entities/user_entity.dart';
import 'package:showmovies/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:showmovies/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:showmovies/features/auth/presentation/blocs/auth_event.dart';
import 'package:showmovies/features/auth/presentation/blocs/auth_state.dart';

// un mock pour l'authentification
class MockAuthRepository extends Mock implements AuthRepositoryImpl {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;

  // Donees de test
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = UserEntity(id: '1', email: tEmail, token: 'fake_jw_token');

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc - Tests Unitaires', () {
    // test1: Verification de l'etat initial du Bloc
    test("L'etat initial du AuthBloc doit etre [AuthInitial]", () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    // TEST 2 : Succès de la connexion (Vérification de la séquence d'états)
    blocTest<AuthBloc, AuthState>(
      'Doit émettre [AuthLoading, AuthAuthenticated] lorsque la connexion réussit',
      build: () {
        // Définir le comportement attendu du mock lors de l'appel à login()
        when(() => mockAuthRepository.login(tEmail, tPassword))
            .thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested(tEmail, tPassword)),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having((state) => state.user, 'user', tUser),
      ],
      verify: (_) {
        // S'assurer que la méthode du dépôt a bien été appelée une fois avec les bons paramètres
        verify(() => mockAuthRepository.login(tEmail, tPassword)).called(1);
      },
    );

    // TEST 3 : Échec de la connexion (Gestion des messages d'erreur réseau/API)
    blocTest<AuthBloc, AuthState>(
      'Doit émettre [AuthLoading, AuthFailure] lorsque la connexion échoue',
      build: () {
        // Simuler une exception levée par le dépôt (ex: mauvais identifiants ou panne réseau)
        when(() => mockAuthRepository.login(tEmail, tPassword))
            .thenThrow(Exception('Identifiants incorrects.'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested(tEmail, tPassword)),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
          (state) => state.message,
          'message',
          'Exception: Identifiants incorrects.',
        ),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.login(tEmail, tPassword)).called(1);
      },
    );
  });
}
