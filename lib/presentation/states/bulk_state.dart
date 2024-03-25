import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/models/bulksorted_model.dart';
import 'package:mobile_app_slb/data/models/cart_model.dart';
import 'package:mobile_app_slb/data/repository/bulk_repository.dart';
import 'package:mobile_app_slb/domain/usecases/bulksort_usecase.dart';
import '../../data/models/assembly_model.dart';

final getBulkProvider = FutureProvider((ref) async {
  final data = await BulkRepository().getBulkAssembly();
  return data;
});

final bulkProvider = ChangeNotifierProvider((ref) => BulkNotifier());

class BulkNotifier extends ChangeNotifier {
  List<AssemblyModel> selectedAssemblies = [];

  void addToList(AssemblyModel model) {
    selectedAssemblies.add(model);
    notifyListeners();
  }

  void removeFromList(AssemblyModel model) {
    selectedAssemblies.removeWhere((element) => element.id == model.id);
    notifyListeners();
  }

  void deleteAssemblies() {
    for (var element in selectedAssemblies) {
      element.isSelected = false;
    }
    selectedAssemblies = [];
    notifyListeners();
  }

  Future<List<CartModel>> getBulkList() async {
    final data = await BulkRepository()
        .getBulkList(selectedAssemblies.map((e) => e.id).toList());
    if (data.cartModels != null) {
      deleteAssemblies();
      return data.cartModels!;
    } else {
      return [];
    }
  }

  Future<List<BulkSortedModel>> getBulkSort(List<int> ids) async {
    final data = await BulkRepository().getBulkSort(ids);
    if (data.sortedModels != null) {
      return data.sortedModels!;
    } else {
      return [];
    }
  }

  Future<BulkSortUseCase> approveAssembly(id) async {
    final data = await BulkRepository().approveAssembly(id);
    return data;
  }
}
