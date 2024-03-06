import 'package:mobile_app_slb/data/models/assortment_model.dart';
import '../../data/models/error_model.dart';

class AssortmentUseCase {
  final List<AssortmentModel>? assortmentModel;
  final ErrorModel? errorModel;

  AssortmentUseCase({this.assortmentModel, this.errorModel});
}
