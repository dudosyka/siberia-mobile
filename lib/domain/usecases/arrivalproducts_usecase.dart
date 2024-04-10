import 'package:mobile_app_slb/data/models/arrivalproduct_model.dart';

import '../../data/models/error_model.dart';

class ArrivalProductsUseCase {
  final List<ArrivalProductModel>? arrivalProductModels;
  final ErrorModel? errorModel;

  ArrivalProductsUseCase({this.arrivalProductModels, this.errorModel});
}
