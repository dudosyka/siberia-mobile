import 'package:mobile_app_slb/domain/usecases/outcome_usecase.dart';

import '../../data/models/cart_model.dart';
import '../usecases/shops_usecase.dart';

abstract class TransferRepositoryImpl {
  Future<OutcomeUseCase> createTransfer(List<CartModel> products, int storeId);
  Future<ShopsUseCase> getAddresses(String name);
  Future<ShopsUseCase> selectAddress(int transactionId, int stockId);
  Future<ShopsUseCase> completeTransferAssembly(int transactionId, int stockId);
  Future<ShopsUseCase> getTransfer(int transactionId, List<int> objects, String type);
}