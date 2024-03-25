import 'package:mobile_app_slb/data/models/bulksorted_model.dart';

import '../../data/models/error_model.dart';

class BulkSortUseCase {
  final List<BulkSortedModel>? sortedModels;
  final ErrorModel? errorModel;

  BulkSortUseCase({this.sortedModels, this.errorModel});
}