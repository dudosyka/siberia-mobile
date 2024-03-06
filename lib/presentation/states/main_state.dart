import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeChangeProvider = ChangeNotifierProvider((ref) => LocaleChangeNotifier());

class LocaleChangeNotifier extends ChangeNotifier {
  Locale locale = const Locale("en");

  void changeLocale(String code) {
    locale = Locale(code);
    notifyListeners();
  }
}