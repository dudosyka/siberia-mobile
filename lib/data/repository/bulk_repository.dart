import 'package:mobile_app_slb/data/models/assembly_model.dart';
import 'package:mobile_app_slb/data/models/bulksorted_model.dart';
import 'package:mobile_app_slb/data/models/cart_model.dart';
import 'package:mobile_app_slb/domain/repository/bulk_repository_impl.dart';
import 'package:mobile_app_slb/domain/usecases/assembly_usecase.dart';
import 'package:mobile_app_slb/domain/usecases/bulklist_usecase.dart';
import 'package:mobile_app_slb/domain/usecases/bulksort_usecase.dart';

import '../data_sources/local_data.dart';
import '../data_sources/remote_data.dart';
import '../models/error_model.dart';

class BulkRepository extends BulkRepositoryImpl {
  final RemoteData remoteData = RemoteData();
  final LocalData localData = LocalData();

  @override
  Future<AssemblyUseCase> getBulkAssembly() async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data = await remoteData.getBulkAssembly(authData.token);

      if (data is List<AssemblyModel>) {
        return AssemblyUseCase(assemblyModels: data);
      }
      if ((data as ErrorModel).type != "auth error") {
        await remoteData.bugReport(authData.token,
            "Endpoint: transaction/assembly, Code: ${data
                .statusCode}, description: ${data.statusText}");
      }
      return AssemblyUseCase(errorModel: data);
    }
    return AssemblyUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<BulkListUseCase> getBulkList(List<int> ids) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data = await remoteData.getBulkList(authData.token, ids);

      if (data is List<CartModel>) {
        return BulkListUseCase(cartModels: data);
      }
      if ((data as ErrorModel).type != "auth error") {
        await remoteData.bugReport(authData.token,
            "Endpoint: transaction/assembly/products/list, Code: ${data
                .statusCode}, description: ${data.statusText}");
      }
      return BulkListUseCase(errorModel: data);
    }
    return BulkListUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<BulkSortUseCase> getBulkSort(List<int> ids) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data = await remoteData.getBulkSorted(authData.token, ids);

      if (data is List<BulkSortedModel>) {
        return BulkSortUseCase(sortedModels: data);
      }
      if ((data as ErrorModel).type != "auth error") {
        await remoteData.bugReport(authData.token,
            "Endpoint: transaction/assembly/products/sorted, Code: ${data
                .statusCode}, description: ${data.statusText}");
      }
      return BulkSortUseCase(errorModel: data);
    }
    return BulkSortUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<BulkSortUseCase> approveAssembly(int id) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data = await remoteData.approveAssembly(authData.token, id);

      if (data is bool) {
        return BulkSortUseCase();
      }
      if ((data as ErrorModel).type != "auth error") {
        await remoteData.bugReport(authData.token,
            "Endpoint: transaction/outcome/$id/approve, Code: ${data
                .statusCode}, description: ${data.statusText}");
      }
      return BulkSortUseCase(errorModel: data);
    }
    return BulkSortUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }
}
