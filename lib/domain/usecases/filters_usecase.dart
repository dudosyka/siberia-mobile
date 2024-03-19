import 'package:mobile_app_slb/data/models/brand_model.dart';
import 'package:mobile_app_slb/data/models/collection_model.dart';
import 'package:mobile_app_slb/data/models/error_model.dart';
import '../../data/models/category_model.dart';

class FiltersUseCase {
  final List<BrandModel>? brandModels;
  final List<CollectionModel>? collectionModels;
  final List<CategoryModel>? categoryModels;
  final ErrorModel? errorModel;

  FiltersUseCase(
      {this.brandModels,
      this.collectionModels,
      this.categoryModels,
      this.errorModel});
}
