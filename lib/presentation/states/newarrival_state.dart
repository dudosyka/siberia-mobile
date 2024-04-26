import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/repository/assortment_repository.dart';
import 'package:mobile_app_slb/data/repository/newarrival_repository.dart';
import 'package:mobile_app_slb/domain/usecases/arrivalproducts_usecase.dart';

import '../../data/models/cart_model.dart';
import '../../domain/usecases/productinfo_usecase.dart';

final newArrivalProvider =
    ChangeNotifierProvider((ref) => NewArrivalNotifier());

class NewArrivalNotifier extends ChangeNotifier {
  List<CartModel> cartData = [];

  Future<ArrivalProductsUseCase> getProductBarcode(String barcode) async {
    final data = await NewArrivalRepository().getProductBarcodes(barcode);

    return data;
  }

  Future<ProductInfoUseCase> getProductInfo(int productId) async {
    final data = await AssortmentRepository().getProductInfo(productId);

    return data;
  }

  Future<void> addToCart(CartModel newModel) async {
    bool flag = false;
    for (var element in cartData) {
      if (element.model.id == newModel.model.id) {
        element.quantity += newModel.quantity;
        flag = true;
        break;
      }
    }
    if (!flag) {
      newModel.curPrice = double.parse(newModel.curPrice.toStringAsFixed(5));
      cartData.add(newModel);
    }
    notifyListeners();
  }

  Future<void> deleteFromCart(CartModel oldModel) async {
    cartData.removeWhere((element) => element.model.id == oldModel.model.id);
    notifyListeners();
  }

  Future<void> updateCartModel(CartModel model, bool add, int? isText) async {
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
          deleteFromCart(model);
        }
      }
    }
    notifyListeners();
  }

  Future<ArrivalProductsUseCase> setTransactionIncome(int storeId) async {
    final data =
        await NewArrivalRepository().setTransactionIncome(storeId, cartData);

    return data;
  }

  Future<void> deleteCart() async {
    cartData = [];
    notifyListeners();
  }
}
