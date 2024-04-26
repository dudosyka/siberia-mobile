import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/repository/newsale_repository.dart';
import 'package:mobile_app_slb/domain/usecases/assortment_usecase.dart';
import 'package:mobile_app_slb/domain/usecases/productinfo_usecase.dart';

import '../../data/models/cart_model.dart';
import '../../data/repository/assortment_repository.dart';

final cartDataProvider = ChangeNotifierProvider((ref) => CartDataNotifier());

class CartDataNotifier extends ChangeNotifier {
  List<CartModel> cartData = [];
  double sum = 0;
  int? transactionId;
  bool isAssembly = false;

  Future<void> getCurrentStock() async {
    final data = await NewSaleRepository().getCurrentStock();
    transactionId = data.currentStock!.id;
    cartData = data.currentStock!.cartModels;
    getSum();
    notifyListeners();
  }

  Future<AssortmentUseCase> getAssortment() async {
    final data = await AssortmentRepository().getAssortment({
      "name": "",
      "availability": true,
      "color": "",
      "brand": null,
      "collection": null,
      "category": null
    });
    return data;
  }

  Future<void> addToCart(CartModel newModel, int storeId) async {
    bool flag = false;
    for (var element in cartData) {
      if (element.model.id == newModel.model.id) {
        if (element.quantity + newModel.quantity <= element.model.quantity!) {
          element.quantity += newModel.quantity;
          element.curPrice =
              element.quantity * (newModel.curPrice / newModel.quantity);
        } else {
          element.quantity = element.model.quantity!.toInt();
          element.curPrice =
              element.quantity * (newModel.curPrice / newModel.quantity);
        }
        flag = true;
        break;
      }
    }
    if (!flag) {
      newModel.curPrice = double.parse(newModel.curPrice.toStringAsFixed(2));
      cartData.add(newModel);
    }
    if (transactionId == null) {
      final data = await NewSaleRepository().createOutcome(newModel, storeId);
      if (data.outcomeModel != null && data.errorModel == null) {
        transactionId = data.outcomeModel!.id;
      }
    } else {
      await NewSaleRepository()
          .updateOutcome(cartData, storeId, transactionId!);
    }
    notifyListeners();
  }

  Future<ProductInfoUseCase> getProductInfo(int productId) async {
    final data = await AssortmentRepository().getProductInfo(productId);
    return data;
  }

  Future<void> deleteFromCart(CartModel oldModel, int storeId) async {
    cartData.removeWhere((element) => element.model.id == oldModel.model.id);
    await NewSaleRepository().updateOutcome(cartData, storeId, transactionId!);
    notifyListeners();
  }

  Future<void> updateCartModel(
      CartModel model, bool add, int? isText, int storeId) async {
    if (isText != null) {
      cartData
          .firstWhere((element) => element.model.id == model.model.id)
          .quantity = isText;
    } else {
      if (add) {
        cartData
            .firstWhere((element) => element.model.id == model.model.id)
            .quantity += 1;
      } else {
        cartData
            .firstWhere((element) => element.model.id == model.model.id)
            .quantity -= 1;
        if (model.quantity == 1) {
          deleteFromCart(model, storeId);
        }
      }
    }
    await NewSaleRepository().updateOutcome(cartData, storeId, transactionId!);
    notifyListeners();
  }

  Future<void> deleteOutcome() async {
    if (transactionId != null) {
      await NewSaleRepository().deleteOutCome(transactionId!);
    }
    transactionId = null;
    cartData = [];
    sum = 0;
    notifyListeners();
  }

  Future<void> deleteCart() async {
    if (isAssembly) {
      deleteAssembly(transactionId!);
    }
    transactionId = null;
    cartData = [];
    sum = 0;
    notifyListeners();
  }

  Future<void> startAssembly() async {
    await NewSaleRepository().startAssembly(transactionId!);
    isAssembly = true;
    notifyListeners();
  }

  Future<void> deleteAssembly(int transactionId) async {
    await NewSaleRepository().deleteAssembly(transactionId);
    isAssembly = false;
    notifyListeners();
  }

  Future<void> approveAssembly() async {
    await NewSaleRepository().approveAssembly(transactionId!);
  }

  Future<void> getSum() async {
    sum = 0;
    for (var element in cartData) {
      sum += element.curPrice;
    }
    notifyListeners();
  }
}
