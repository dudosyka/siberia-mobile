import 'dart:convert';

import 'package:localstorage/localstorage.dart';
import 'package:mobile_app_slb/data/models/auth_model.dart';

class LocalData {
  final LocalStorage authStorage = LocalStorage('auth_storage');

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
}
