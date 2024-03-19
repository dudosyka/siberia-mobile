import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import 'package:mobile_app_slb/data/models/auth_model.dart';
import 'package:mobile_app_slb/data/models/cart_model.dart';

import '../models/assortment_model.dart';

class LocalData {
  final LocalStorage authStorage = LocalStorage('auth_storage');
  final LocalStorage cartStorage = LocalStorage('cart_storage');

  Future<void> saveAuthData(AuthModel data) async {
    final ready = await authStorage.ready;
    if (ready) {
      await authStorage.setItem("authData", json.encode(data));
    }
  }

  Future<AuthModel?> getAuthData() async {
    final ready = await authStorage.ready;
    if (ready) {
      final data = await authStorage.getItem("authData");
      if (data != null) {
        return AuthModel.fromJson(json.decode(data));
      }
    }
    return null;
  }

  Future<bool> deleteAuthData() async {
    final ready = await authStorage.ready;
    if (ready) {
      await authStorage.deleteItem("authData");
      return true;
    }
    return false;
  }

  Future<void> saveCartData(List<CartModel> data) async {
    final ready = await cartStorage.ready;
    if (ready) {
      await cartStorage.setItem("cartData", json.encode(data));
    }
  }

  Future<List<CartModel>?> getCartData() async {
    final ready = await cartStorage.ready;
    if (ready) {
      final data = await cartStorage.getItem("cartData");
      if (data != null) {
        return (json.decode(data) as List)
            .map((e) => CartModel.fromJson(e))
            .toList();
      }
    }
    return null;
  }

  Future<bool> deleteCartData() async {
    final ready = await cartStorage.ready;
    if (ready) {
      await cartStorage.deleteItem("cartData");
      return true;
    }
    return false;
  }
}
