import 'package:mobile_app_slb/data/data_sources/remote_data.dart';
import 'package:mobile_app_slb/data/models/assortment_model.dart';
import 'package:mobile_app_slb/data/models/error_model.dart';
import 'package:mobile_app_slb/domain/repository/assortment_repository_impl.dart';
import 'package:mobile_app_slb/domain/usecases/assortment_usecase.dart';
import 'package:mobile_app_slb/domain/usecases/availability_usecase.dart';

import '../data_sources/local_data.dart';
import '../models/availability_model.dart';

class AssortmentRepository extends AssortmentRepositoryImpl {
  final RemoteData remoteData = RemoteData();
  final LocalData localData = LocalData();

  @override
  Future<AssortmentUseCase> getAssortment(Map<String, dynamic> filters) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data = await remoteData.getAssortment(authData.token, filters);

      if(data is List<AssortmentModel>) {
        return AssortmentUseCase(assortmentModel: data);
      }
      return AssortmentUseCase(errorModel: data);
    }
    return AssortmentUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<AvailabilityUseCase> getAvailability(int productId) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data = await remoteData.getProductAvailability(authData.token, productId);

      if(data is List<AvailabilityModel>) {
        return AvailabilityUseCase(availabilityModel: data);
      }
      return AvailabilityUseCase(errorModel: data);
    }
    return AvailabilityUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }
}
