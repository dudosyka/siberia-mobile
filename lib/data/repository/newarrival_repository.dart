import 'package:mobile_app_slb/data/models/arrivalproduct_model.dart';
import 'package:mobile_app_slb/data/models/cart_model.dart';
import 'package:mobile_app_slb/domain/repository/newarrival_repository_impl.dart';
import 'package:mobile_app_slb/domain/usecases/arrivalproducts_usecase.dart';
import '../data_sources/local_data.dart';
import '../data_sources/remote_data.dart';
import '../models/error_model.dart';

class NewArrivalRepository extends NewArrivalRepositoryImpl {
  final RemoteData remoteData = RemoteData();
  final LocalData localData = LocalData();

  @override
  Future<ArrivalProductsUseCase> getProductBarcodes(String barcode) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data = await remoteData.getProductBarcode(authData.token, barcode);

      if (data is List<ArrivalProductModel>) {
        return ArrivalProductsUseCase(arrivalProductModels: data);
      }
      if ((data as ErrorModel).type != "auth error") {
        await remoteData.bugReport(authData.token,
            "Endpoint: product/barcode/$barcode, Code: ${data.statusCode}, description: ${data.statusText}");
      }
      return ArrivalProductsUseCase(errorModel: data);
    }
    return ArrivalProductsUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<ArrivalProductsUseCase> setTransactionIncome(
      int storeId, List<CartModel> models) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data = await remoteData.setTransactionIncome(
          authData.token, storeId, models);

      if (data is bool) {
        return ArrivalProductsUseCase();
      }
      if ((data as ErrorModel).type != "auth error") {
        await remoteData.bugReport(authData.token,
            "Endpoint: transaction/income, Code: ${data.statusCode}, description: ${data.statusText}");
      }
      return ArrivalProductsUseCase(errorModel: data);
    }
    return ArrivalProductsUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }
}
