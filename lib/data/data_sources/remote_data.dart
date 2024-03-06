import 'package:dio/dio.dart';
import 'package:mobile_app_slb/data/models/assortment_model.dart';
import 'package:mobile_app_slb/data/models/auth_model.dart';
import 'package:mobile_app_slb/data/models/availability_model.dart';
import 'package:mobile_app_slb/data/models/error_model.dart';
import 'package:mobile_app_slb/data/models/stock_model.dart';
import 'package:mobile_app_slb/utils/constants.dart' as constants;

class RemoteData {
  String baseUrl = constants.baseUrl;
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

  Future<dynamic> getStock(String token) async {
    final res = await dio.get("${baseUrl}auth/mobile/current-stock",
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      final StockModel model = StockModel.fromJson(res.data["stockData"]);

      return model;
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> getAssortment(
      String token, Map<String, dynamic> filters) async {
    final res = await dio.post("${baseUrl}product/search",
        data: {"filters": filters},
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));
    if (res.statusCode == 200) {
      final List<AssortmentModel> data =
          (res.data as List).map((e) => AssortmentModel.fromJson(e)).toList();
      return data;
    } else if (res.statusCode == 415) {
      return ErrorModel("filter error", 415, "Unsupported Media Type");
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> getProductAvailability(String token, int productId) async {
    final res = await dio.get("${baseUrl}product/$productId/availability",
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));
    if (res.statusCode == 200) {
      final List<AvailabilityModel> data =
          (res.data as List).map((e) => AvailabilityModel.fromJson(e)).toList();
      return data;
    } else if (res.statusCode == 400) {
      return ErrorModel("bad request", 400, "Product id must be INT");
    } else if (res.statusCode == 404) {
      return ErrorModel(
          "not found", 404, "Entity id=$productId not found in the database");
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }
}
