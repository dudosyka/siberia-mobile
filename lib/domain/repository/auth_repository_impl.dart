import '../usecases/auth_usecase.dart';
import '../usecases/stock_usecase.dart';

abstract class AuthRepositoryImpl {
  Future<AuthUseCase> loginUser(String qrToken);
  Future<AuthUseCase> getAuthData();
  Future<bool> deleteAuthData();
  Future<StockUseCase> getStock();
}
