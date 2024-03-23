import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/repository/auth_repository.dart';
import '../../domain/usecases/auth_usecase.dart';

final authProvider =
    FutureProvider.family<AuthUseCase, String>((ref, qrToken) async {
  String token = qrToken.replaceFirst('QR_CODE\n', '');
  token = token.split('\n')[0];
  final data = await AuthRepository().loginUser(token);
  return data;
});

final loadAuthProvider = FutureProvider((ref) async {
  final data = await AuthRepository().getAuthData();
  return data;
});

final deleteAuthProvider =
    ChangeNotifierProvider((ref) => DeleteAuthNotifier());

class DeleteAuthNotifier extends ChangeNotifier {
  Future<bool> deleteAuth() async {
    final data = AuthRepository().deleteAuthData();
    return data;
  }
}
