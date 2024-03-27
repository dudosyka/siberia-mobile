import 'package:mobile_app_slb/data/data_sources/remote_data.dart';
import 'package:mobile_app_slb/data/models/assortment_model.dart';
import 'package:mobile_app_slb/data/models/brand_model.dart';
import 'package:mobile_app_slb/data/models/category_model.dart';
import 'package:mobile_app_slb/data/models/collection_model.dart';
import 'package:mobile_app_slb/data/models/error_model.dart';
import 'package:mobile_app_slb/domain/repository/assortment_repository_impl.dart';
import 'package:mobile_app_slb/domain/usecases/assortment_usecase.dart';
import 'package:mobile_app_slb/domain/usecases/availability_usecase.dart';
import 'package:mobile_app_slb/domain/usecases/filters_usecase.dart';
import 'package:mobile_app_slb/domain/usecases/productinfo_usecase.dart';

import '../data_sources/local_data.dart';
import '../models/availability_model.dart';
import '../models/productinfo_model.dart';

class AssortmentRepository extends AssortmentRepositoryImpl {
  final RemoteData remoteData = RemoteData();
  final LocalData localData = LocalData();

  @override
  Future<AssortmentUseCase> getAssortment(Map<String, dynamic> filters) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data = await remoteData.getAssortment(authData.token, filters);

      if (data is List<AssortmentModel>) {
        return AssortmentUseCase(assortmentModel: data);
      }
      if ((data as ErrorModel).type != "auth error") {
        await remoteData.bugReport(authData.token,
            "Endpoint: /product/search, Code: ${data
                .statusCode}, description: ${data.statusText}");
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
      final data =
      await remoteData.getProductAvailability(authData.token, productId);

      if (data is List<AvailabilityModel>) {
        return AvailabilityUseCase(availabilityModel: data);
      }
      if ((data as ErrorModel).type != "auth error") {
        await remoteData.bugReport(authData.token,
            "Endpoint: product/$productId/availability, Code: ${data
                .statusCode}, description: ${data.statusText}");
      }
      return AvailabilityUseCase(errorModel: data);
    }
    return AvailabilityUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<FiltersUseCase> getFiltersData() async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final brands = await remoteData.getBrands(authData.token);
      final collections = await remoteData.getCollections(authData.token);
      final categories = await remoteData.getCategories(authData.token);

      if (brands is List<BrandModel> &&
          collections is List<CollectionModel> &&
          categories is List<CategoryModel>) {
        return FiltersUseCase(
            brandModels: brands,
            collectionModels: collections,
            categoryModels: categories);
      }
      return FiltersUseCase(
          errorModel: ErrorModel("auth error", 401, "Unauthorized"));
    }
    return FiltersUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<ProductInfoUseCase> getProductInfo(int productId) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data = await remoteData.getProductInfo(authData.token, productId);

      if (data is ProductInfoModel) {
        return ProductInfoUseCase(productModel: data);
      }
      if ((data as ErrorModel).type != "auth error") {
        await remoteData.bugReport(authData.token,
            "Endpoint: product/$productId, Code: ${data
                .statusCode}, description: ${data.statusText}");
      }
      return ProductInfoUseCase(errorModel: data);
    }
    return ProductInfoUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }
}
