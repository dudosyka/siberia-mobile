import '../../data/models/cart_model.dart';
import '../../data/models/error_model.dart';

class BulkListUseCase {
  final List<CartModel>? cartModels;
  final ErrorModel? errorModel;

  BulkListUseCase({this.cartModels, this.errorModel});
}