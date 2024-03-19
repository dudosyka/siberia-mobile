import 'package:mobile_app_slb/data/models/productinfo_model.dart';

import '../../data/models/error_model.dart';

class ProductInfoUseCase {
  final ProductInfoModel? productModel;
  final ErrorModel? errorModel;

  ProductInfoUseCase({this.productModel, this.errorModel});
}