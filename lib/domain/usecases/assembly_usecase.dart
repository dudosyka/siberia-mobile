import 'package:mobile_app_slb/data/models/assembly_model.dart';

import '../../data/models/error_model.dart';

class AssemblyUseCase {
  final List<AssemblyModel>? assemblyModels;
  final ErrorModel? errorModel;

  AssemblyUseCase({this.assemblyModels, this.errorModel});
}