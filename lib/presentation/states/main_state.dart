import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/domain/usecases/stock_usecase.dart';

import '../../data/repository/auth_repository.dart';

final localeChangeProvider =
    ChangeNotifierProvider((ref) => LocaleChangeNotifier());

class LocaleChangeNotifier extends ChangeNotifier {
  Locale locale = const Locale("en");

  void changeLocale(String code) {
    locale = Locale(code);
    notifyListeners();
  }

  Future<StockUseCase> getCurrentStock() async {
    final data = await AuthRepository().getStock();
    return data;
  }
}
