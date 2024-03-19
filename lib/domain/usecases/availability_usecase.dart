import 'package:mobile_app_slb/data/models/availability_model.dart';
import '../../data/models/error_model.dart';

class AvailabilityUseCase {
  final List<AvailabilityModel>? availabilityModel;
  final ErrorModel? errorModel;

  AvailabilityUseCase({this.availabilityModel, this.errorModel});
}
