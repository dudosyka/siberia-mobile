import 'package:mobile_app_slb/data/data_sources/local_data.dart';
import 'package:mobile_app_slb/data/data_sources/remote_data.dart';
import 'package:mobile_app_slb/data/models/auth_model.dart';
import 'package:mobile_app_slb/domain/repository/auth_repository_impl.dart';
import 'package:mobile_app_slb/domain/usecases/auth_usecase.dart';

class AuthRepository extends AuthRepositoryImpl {
  final RemoteData remoteData = RemoteData();
  final LocalData localData = LocalData();

  @override
  Future<AuthUseCase> loginUser(String qrToken) async {
    final data = await remoteData.loginUser(qrToken);

    if(data is AuthModel) {
      localData.saveAuthData(data);
      return AuthUseCase(authModel: data);
    } else {
      return AuthUseCase(errorModel: data);
    }
  }

  @override
  Future<AuthUseCase> getAuthData() async {
    final data = await localData.getAuthData();
    return AuthUseCase(authModel: data);
  }

  @override
  Future<bool> deleteAuthData() async {
    final data = await localData.deleteAuthData();
    return data;
  }
}