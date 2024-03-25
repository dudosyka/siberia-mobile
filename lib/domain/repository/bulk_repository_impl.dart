import 'package:mobile_app_slb/domain/usecases/assembly_usecase.dart';
import 'package:mobile_app_slb/domain/usecases/bulksort_usecase.dart';

import '../usecases/bulklist_usecase.dart';

abstract class BulkRepositoryImpl {
  Future<AssemblyUseCase> getBulkAssembly();
  Future<BulkListUseCase> getBulkList(List<int> ids);
  Future<BulkSortUseCase> getBulkSort(List<int> ids);
  Future<BulkSortUseCase> approveAssembly(int id);
}