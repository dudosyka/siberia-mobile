import 'package:mobile_app_slb/domain/usecases/availability_usecase.dart';
import '../usecases/assortment_usecase.dart';
import '../usecases/filters_usecase.dart';

abstract class AssortmentRepositoryImpl {
  Future<AssortmentUseCase> getAssortment(Map<String, dynamic> filters);
  Future<AvailabilityUseCase> getAvailability(int productId);
  Future<FiltersUseCase> getFiltersData();
}
