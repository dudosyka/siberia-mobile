import '../../data/models/cart_model.dart';
import '../usecases/arrivalproducts_usecase.dart';

abstract class NewArrivalRepositoryImpl {
  Future<ArrivalProductsUseCase> getProductBarcodes(String barcode);

  Future<ArrivalProductsUseCase> setTransactionIncome(
      int storeId, List<CartModel> models);
}
