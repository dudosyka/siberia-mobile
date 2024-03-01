import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/repository/auth_repository.dart';
import '../../domain/usecases/auth_usecase.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

final scanProvider = FutureProvider((ref) async {
  String code = "";
  String barcodeScanRes;

  try {
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR);
  } on PlatformException {
    barcodeScanRes = 'Something went wrong. Try to re-scan again';
  }
  code = barcodeScanRes;
  return code;
});

final authProvider = FutureProvider.family<AuthUseCase, String>((ref, qrToken) async {
  String token = qrToken.replaceFirst('QR_CODE\n', '');
  token = token.split('\n')[0];
  final data = await AuthRepository().loginUser(token);
  return data;
});

final loadAuthProvider = FutureProvider((ref) async {
   final data = await AuthRepository().getAuthData();
   return data;
});
