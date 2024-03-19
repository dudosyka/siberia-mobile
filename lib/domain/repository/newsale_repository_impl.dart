import 'package:mobile_app_slb/domain/usecases/cart_usecase.dart';

import '../../data/models/cart_model.dart';
import '../usecases/currentstock_usecase.dart';
import '../usecases/outcome_usecase.dart';

abstract class NewSaleRepositoryImpl {
  Future<CartUseCase> getCartData();

  Future<bool> deleteCartData();

  Future<void> saveCartData(List<CartModel> data);

  Future<OutcomeUseCase> createOutcome(CartModel product, int storeId);

  Future<OutcomeUseCase> updateOutcome(
      List<CartModel> products, int storeId, int transactionId);

  Future<OutcomeUseCase> deleteOutCome(int transactionId);

  Future<OutcomeUseCase> startAssembly(int transactionId);

  Future<OutcomeUseCase> deleteAssembly(int transactionId);

  Future<OutcomeUseCase> approveAssembly(int transactionId);

  Future<CurrentStockUseCase> getCurrentStock();
}
