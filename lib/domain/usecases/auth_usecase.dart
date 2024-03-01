import 'package:mobile_app_slb/data/models/auth_model.dart';

import '../../data/models/error_model.dart';

class AuthUseCase {
  final AuthModel? authModel;
  final ErrorModel? errorModel;

  AuthUseCase({this.authModel, this.errorModel});
}
