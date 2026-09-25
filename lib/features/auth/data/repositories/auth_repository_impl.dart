import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  Future<UserEntity> login(String email, String password) async {
    try {
      return await remoteDataSource.login(email, password);
    } on ServerException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<UserEntity> register(String email, String password) async {
    try {
      return await remoteDataSource.register(email, password);
    } on ServerException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } on ServerException catch (e) {
      throw Exception(e.message);
    }
  }
}
