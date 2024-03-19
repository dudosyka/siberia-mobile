import 'package:mobile_app_slb/data/models/currentstock_model.dart';

import '../../data/models/error_model.dart';

class CurrentStockUseCase {
  final CurrentStockModel? currentStock;
  final ErrorModel? errorModel;

  CurrentStockUseCase({this.currentStock, this.errorModel});
}