import 'package:mobile_app_slb/data/models/outcome_model.dart';

import '../../data/models/error_model.dart';

class OutcomeUseCase {
  final OutcomeModel? outcomeModel;
  final ErrorModel? errorModel;

  OutcomeUseCase({this.outcomeModel, this.errorModel});
}