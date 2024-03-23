import 'package:dio/dio.dart';
import 'package:mobile_app_slb/data/models/assortment_model.dart';
import 'package:mobile_app_slb/data/models/auth_model.dart';
import 'package:mobile_app_slb/data/models/availability_model.dart';
import 'package:mobile_app_slb/data/models/brand_model.dart';
import 'package:mobile_app_slb/data/models/cart_model.dart';
import 'package:mobile_app_slb/data/models/category_model.dart';
import 'package:mobile_app_slb/data/models/collection_model.dart';
import 'package:mobile_app_slb/data/models/currentstock_model.dart';
import 'package:mobile_app_slb/data/models/error_model.dart';
import 'package:mobile_app_slb/data/models/outcome_model.dart';
import 'package:mobile_app_slb/data/models/productinfo_model.dart';
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

  Future<dynamic> getBrands(String token) async {
    final res = await dio.get("${baseUrl}brand",
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      final List<BrandModel> data =
          (res.data as List).map((e) => BrandModel.fromJson(e)).toList();
      return data;
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> getCollections(String token) async {
    final res = await dio.get("${baseUrl}collection",
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      final List<CollectionModel> data =
          (res.data as List).map((e) => CollectionModel.fromJson(e)).toList();
      return data;
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> getCategories(String token) async {
    final res = await dio.get("${baseUrl}category",
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      final List<CategoryModel> data =
          (res.data as List).map((e) => CategoryModel.fromJson(e)).toList();
      return data;
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> getProductInfo(String token, int productId) async {
    final res = await dio.get("${baseUrl}product/$productId",
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      final ProductInfoModel data = ProductInfoModel.fromJson(res.data);
      return data;
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> createOutcome(
      String token, CartModel product, int storeId) async {
    final res = await dio.post("${baseUrl}transaction/outcome/hidden",
        data: {
          "from": storeId,
          "type": 2,
          "products": [
            {"productId": product.model.id, "amount": product.quantity}
          ]
        },
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      final OutcomeModel data = OutcomeModel.fromJson(res.data);
      return data;
    } else if (res.statusCode == 415) {
      return ErrorModel("unsupported media", 415, "Unsupported Media Type");
    } else if (res.statusCode == 400) {
      return ErrorModel("not enough", 400, "Not enough products in stock");
    } else if (res.statusCode == 403) {
      return ErrorModel("forbidden", 403, "Stock forbidden");
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> updateOutcome(String token, List<CartModel> products,
      int storeId, int transactionId) async {
    final res =
        await dio.patch("${baseUrl}transaction/outcome/hidden/$transactionId",
            data: getProductList(products),
            options: Options(validateStatus: (_) => true, headers: {
              "Content-Type": "application/json",
              "authorization": "Bearer $token",
            }));

    if (res.statusCode == 200) {
      return true;
    } else if (res.statusCode == 415) {
      return ErrorModel("unsupported media", 415, "Unsupported Media Type");
    } else if (res.statusCode == 400) {
      return ErrorModel(
          "bad transaction id", 400, "Transaction id must be INT");
    } else if (res.statusCode == 403) {
      return ErrorModel("forbidden", 403, "Stock forbidden");
    } else if (res.statusCode == 404) {
      return ErrorModel("not found", 404, "Transaction not found");
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> deleteOutcome(String token, int transactionId) async {
    // final res =
    //     await dio.delete("${baseUrl}transaction/outcome/hidden/$transactionId",
    //         options: Options(validateStatus: (_) => true, headers: {
    //           "Content-Type": "application/json",
    //           "authorization": "Bearer $token",
    //         }));
    //
    // if (res.statusCode == 200) {
    //   return true;
    // } else if (res.statusCode == 404) {
    //   return ErrorModel("not found", 404, "Transaction not found");
    // } else if (res.statusCode == 400) {
    //   return ErrorModel(
    //       "bad transaction id", 400, "Transaction id must be INT");
    // } else if (res.statusCode == 403) {
    //   return ErrorModel("bad transaction", 403, "Forbidden");
    // } else {
    //   return ErrorModel("auth error", 401, "Unauthorized");
    // }
    return true;
  }

  Future<dynamic> startAssembly(String token, int transactionId) async {
    final res = await dio.post("${baseUrl}transaction/outcome/$transactionId",
        data: {},
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      return true;
    } else if (res.statusCode == 404) {
      return ErrorModel("not found", 404, "Transaction not found");
    } else if (res.statusCode == 400) {
      return ErrorModel(
          "bad transaction id", 400, "Transaction id must be INT");
    } else if (res.statusCode == 403) {
      return ErrorModel("forbidden", 403, "Stock forbidden");
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> deleteAssembly(String token, int transactionId) async {
    // final res =
    //     await dio.patch("${baseUrl}transaction/outcome/$transactionId/cancel",
    //         data: {},
    //         options: Options(validateStatus: (_) => true, headers: {
    //           "Content-Type": "application/json",
    //           "authorization": "Bearer $token",
    //         }));
    //
    // if (res.statusCode == 200) {
    //   return true;
    // } else if (res.statusCode == 404) {
    //   return ErrorModel("not found", 404, "Transaction not found");
    // } else if (res.statusCode == 400) {
    //   return ErrorModel(
    //       "bad transaction id", 400, "Transaction id must be INT");
    // } else if (res.statusCode == 403) {
    //   return ErrorModel("forbidden", 403, "Stock forbidden");
    // } else {
    //   return ErrorModel("auth error", 401, "Unauthorized");
    // }
    return true;
  }

  Future<dynamic> approveAssembly(String token, int transactionId) async {
    final res =
        await dio.patch("${baseUrl}transaction/outcome/$transactionId/approve",
            data: {},
            options: Options(validateStatus: (_) => true, headers: {
              "Content-Type": "application/json",
              "authorization": "Bearer $token",
            }));

    if (res.statusCode == 200) {
      return true;
    } else if (res.statusCode == 404) {
      return ErrorModel("not found", 404, "Transaction not found");
    } else if (res.statusCode == 400) {
      return ErrorModel(
          "bad transaction id", 400, "Transaction id must be INT");
    } else if (res.statusCode == 403) {
      return ErrorModel("forbidden", 403, "Stock forbidden");
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  List<Map<String, dynamic>> getProductList(List<CartModel> cartList) {
    List<Map<String, dynamic>> productList = [];

    for (var cartItem in cartList) {
      var productInfo = {
        "productId": cartItem.model.id,
        "amount": cartItem.quantity
      };
      productList.add(productInfo);
    }

    return productList;
  }

  Future<dynamic> getCurrentStock(String token) async {
    final res = await dio.get("${baseUrl}auth/mobile/current-stock",
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      List<CartModel> curData = [];
      for (var element in (res.data["transactionData"]["products"] as List)) {
        Map<String, dynamic> curPrice = {};

        if (element["product"]["offertaPrice"] == null) {
          if (element["product"]["distributorPrice"] <=
              element["product"]["professionalPrice"]) {
            curPrice = {"Distribution": element["product"]["distributorPrice"]};
          } else {
            curPrice = {
              "Professional": element["product"]["professionalPrice"]
            };
          }
        } else {
          if (element["product"]["distributorPrice"] <=
                  element["product"]["professionalPrice"] &&
              element["product"]["distributorPrice"] <=
                  element["product"]["offertaPrice"]) {
            curPrice = {"Distribution": element["product"]["distributorPrice"]};
          } else if (element["product"]["professionalPrice"] <=
                  element["product"]["distributorPrice"] &&
              element["product"]["professionalPrice"] <=
                  element["product"]["offertaPrice"]) {
            curPrice = {
              "Professional": element["product"]["professionalPrice"]
            };
          } else {
            curPrice = {"Oferta": element["product"]["offertaPrice"]};
          }
        }

        curData.add(CartModel(
            AssortmentModel(
                element["product"]["id"],
                element["product"]["name"].toString(),
                element["product"]["vendorCode"].toString(),
                element["product"]["commonPrice"],
                element["product"]["photo"],
                element["product"]["eanCode"].toString(),
                double.parse(element["product"]["amountInBox"].toString())),
            element["amount"].toInt(),
            curPrice,
            curPrice[curPrice.keys.first] * element["amount"]));
      }
      return CurrentStockModel(res.data["transactionData"]["id"],
          res.data["transactionData"]["type"]["id"], curData);
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }
}
