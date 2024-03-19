import 'package:mobile_app_slb/data/models/stock_model.dart';
import '../../data/models/error_model.dart';

class StockUseCase {
  final StockModel? stockModel;
  final ErrorModel? errorModel;

  StockUseCase({this.stockModel, this.errorModel});
}
