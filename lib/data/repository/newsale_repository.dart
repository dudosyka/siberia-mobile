import 'package:mobile_app_slb/data/models/cart_model.dart';
import 'package:mobile_app_slb/data/models/currentstock_model.dart';
import 'package:mobile_app_slb/data/models/outcome_model.dart';
import 'package:mobile_app_slb/domain/repository/newsale_repository_impl.dart';
import 'package:mobile_app_slb/domain/usecases/cart_usecase.dart';
import 'package:mobile_app_slb/domain/usecases/currentstock_usecase.dart';
import 'package:mobile_app_slb/domain/usecases/outcome_usecase.dart';

import '../data_sources/local_data.dart';
import '../data_sources/remote_data.dart';
import '../models/error_model.dart';

class NewSaleRepository extends NewSaleRepositoryImpl {
  final RemoteData remoteData = RemoteData();
  final LocalData localData = LocalData();

  @override
  Future<bool> deleteCartData() async {
    final data = await localData.deleteCartData();
    return data;
  }

  @override
  Future<CartUseCase> getCartData() async {
    final data = await localData.getCartData();

    if (data is List<CartModel>) {
      return CartUseCase(cartModels: data);
    }
    return CartUseCase(errorModel: data);
  }

  @override
  Future<void> saveCartData(List<CartModel> data) async {
    await localData.saveCartData(data);
  }

  @override
  Future<OutcomeUseCase> createOutcome(CartModel product, int storeId) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data =
          await remoteData.createOutcome(authData.token, product, storeId);

      if (data is OutcomeModel) {
        return OutcomeUseCase(outcomeModel: data);
      }
      return OutcomeUseCase(errorModel: data);
    }
    return OutcomeUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<OutcomeUseCase> updateOutcome(
      List<CartModel> products, int storeId, int transactionId) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data = await remoteData.updateOutcome(
          authData.token, products, storeId, transactionId);

      if (data is bool) {
        return OutcomeUseCase();
      }
      return OutcomeUseCase(errorModel: data);
    }
    return OutcomeUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<OutcomeUseCase> deleteOutCome(int transactionId) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data =
          await remoteData.deleteOutcome(authData.token, transactionId);

      if (data is bool) {
        return OutcomeUseCase();
      }
      return OutcomeUseCase(errorModel: data);
    }
    return OutcomeUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<OutcomeUseCase> startAssembly(int transactionId) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data =
      await remoteData.startAssembly(authData.token, transactionId);

      if (data is bool) {
        return OutcomeUseCase();
      }
      return OutcomeUseCase(errorModel: data);
    }
    return OutcomeUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<OutcomeUseCase> deleteAssembly(int transactionId) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data =
      await remoteData.deleteAssembly(authData.token, transactionId);

      if (data is bool) {
        return OutcomeUseCase();
      }
      return OutcomeUseCase(errorModel: data);
    }
    return OutcomeUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<OutcomeUseCase> approveAssembly(int transactionId) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data =
          await remoteData.approveAssembly(authData.token, transactionId);

      if (data is bool) {
        return OutcomeUseCase();
      }
      return OutcomeUseCase(errorModel: data);
    }
    return OutcomeUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<CurrentStockUseCase> getCurrentStock() async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data =
          await remoteData.getCurrentStock(authData.token);

      if (data is CurrentStockModel) {
        return CurrentStockUseCase(currentStock: data);
      }
      return CurrentStockUseCase(errorModel: data);
    }
    return CurrentStockUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }
}
