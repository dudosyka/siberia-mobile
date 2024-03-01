import 'package:dio/dio.dart';
import 'package:mobile_app_slb/data/models/auth_model.dart';
import 'package:mobile_app_slb/data/models/error_model.dart';

class RemoteData {
  final String baseUrl = "https://h1l3x.dudosyka.ru/";
  final Dio dio = Dio();

  Future<dynamic> loginUser(String qrToken) async {
    final res = await dio.post("${baseUrl}auth/mobile",
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $qrToken",
        }));

    if (res.statusCode == 200) {
      final AuthModel model = AuthModel.fromJson(res.data);

      return model;
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }
}
