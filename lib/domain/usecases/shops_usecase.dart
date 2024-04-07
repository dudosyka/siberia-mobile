import 'package:mobile_app_slb/data/models/error_model.dart';

import '../../data/models/shop_model.dart';

class ShopsUseCase {
  final List<ShopModel>? shopModels;
  final ErrorModel? errorModel;

  ShopsUseCase({this.shopModels, this.errorModel});
}