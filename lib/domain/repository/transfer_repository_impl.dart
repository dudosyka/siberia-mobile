import 'package:mobile_app_slb/domain/usecases/outcome_usecase.dart';

import '../../data/models/cart_model.dart';

abstract class TransferRepositoryImpl {
  Future<OutcomeUseCase> createTransfer(List<CartModel> products, int storeId);
}