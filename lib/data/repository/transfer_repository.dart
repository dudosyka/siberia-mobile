import 'package:mobile_app_slb/data/models/cart_model.dart';

import 'package:mobile_app_slb/domain/usecases/outcome_usecase.dart';

import '../../domain/repository/transfer_repository_impl.dart';
import '../data_sources/local_data.dart';
import '../data_sources/remote_data.dart';
import '../models/error_model.dart';

class TransferRepository extends TransferRepositoryImpl {
  final RemoteData remoteData = RemoteData();
  final LocalData localData = LocalData();

  @override
  Future<OutcomeUseCase> createTransfer(List<CartModel> products, int storeId) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data =
      await remoteData.createTransfer(authData.token, products, storeId);

      if (data is bool) {
        return OutcomeUseCase();
      }
      if ((data as ErrorModel).type != "auth error") {
        await remoteData.bugReport(authData.token,
            "Endpoint: transaction/outcome/hidden, Code: ${data
                .statusCode}, description: ${data.statusText}");
      }
      return OutcomeUseCase(errorModel: data);
    }
    return OutcomeUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

}