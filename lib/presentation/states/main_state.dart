import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/domain/usecases/stock_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repository/auth_repository.dart';

final localeChangeProvider =
    ChangeNotifierProvider((ref) => LocaleChangeNotifier());

class LocaleChangeNotifier extends ChangeNotifier {
  Locale locale = const Locale("en");

  Future<void> changeLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    locale = Locale(code);
    prefs.setString('lang', code);
    notifyListeners();
  }

  Future<void> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? language = prefs.getString('lang');
    if(language != null) {
      locale = Locale(language);
      notifyListeners();
    } else {
      prefs.setString('lang', 'en');
    }
  }

  Future<StockUseCase> getCurrentStock() async {
    final data = await AuthRepository().getStock();
    return data;
  }
}
