import 'package:mobile_app_slb/data/models/cart_model.dart';

import '../../data/models/error_model.dart';

class CartUseCase {
  final List<CartModel>? cartModels;
  final ErrorModel? errorModel;

  CartUseCase({this.cartModels, this.errorModel});
}