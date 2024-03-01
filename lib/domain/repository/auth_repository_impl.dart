import '../usecases/auth_usecase.dart';

abstract class AuthRepositoryImpl {
  Future<AuthUseCase> loginUser(String qrToken);
  Future<AuthUseCase> getAuthData();
  Future<bool> deleteAuthData();
}
