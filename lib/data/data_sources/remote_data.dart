import 'package:dio/dio.dart';
import 'package:mobile_app_slb/data/models/arrivalproduct_model.dart';
import 'package:mobile_app_slb/data/models/assembly_model.dart';
import 'package:mobile_app_slb/data/models/assortment_model.dart';
import 'package:mobile_app_slb/data/models/auth_model.dart';
import 'package:mobile_app_slb/data/models/availability_model.dart';
import 'package:mobile_app_slb/data/models/brand_model.dart';
import 'package:mobile_app_slb/data/models/bulksorted_model.dart';
import 'package:mobile_app_slb/data/models/cart_model.dart';
import 'package:mobile_app_slb/data/models/category_model.dart';
import 'package:mobile_app_slb/data/models/collection_model.dart';
import 'package:mobile_app_slb/data/models/currentstock_model.dart';
import 'package:mobile_app_slb/data/models/error_model.dart';
import 'package:mobile_app_slb/data/models/outcome_model.dart';
import 'package:mobile_app_slb/data/models/productinfo_model.dart';
import 'package:mobile_app_slb/data/models/shop_model.dart';
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
      final StockModel model = StockModel.fromJson(res.data);

      return model;
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> getAssortment(
      String token, Map<String, dynamic> filters) async {
    final res = await dio.post("${baseUrl}product/search",
        data: {"filters": filters, "needImages": true},
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));
    print(token);
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
        await dio.patch("${baseUrl}transaction/outcome/$transactionId",
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

        if (element["product"]["offertaPrice"] == null ||
            element["product"]["offertaPrice"] == 0.0) {
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

        final res2 =
        await dio.get("${baseUrl}product/${element["product"]["id"]}",
            options: Options(validateStatus: (_) => true, headers: {
              "Content-Type": "application/json",
              "authorization": "Bearer $token",
            }));

        if (res2.statusCode == 200) {
          curData.add(CartModel(
              AssortmentModel(
                  element["product"]["id"],
                  element["product"]["name"].toString(),
                  element["product"]["vendorCode"].toString(),
                  element["product"]["commonPrice"],
                  element["product"]["photo"],
                  element["product"]["eanCode"].toString(),
                  res2.data["quantity"]),
              element["amount"].toInt(),
              curPrice,
              curPrice[curPrice.keys.first] * element["amount"]));
        } else {
          return ErrorModel("auth error", 401, "Unauthorized");
        }
      }
      return CurrentStockModel(res.data["transactionData"]["id"],
          res.data["transactionData"]["type"]["id"], curData);
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> getBulkAssembly(String token) async {
    final res = await dio.get("${baseUrl}transaction/assembly",
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      final data =
          (res.data as List).map((e) => AssemblyModel.fromJson(e)).toList();

      return data;
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> getBulkList(String token, List<int> ids) async {
    final res = await dio.post("${baseUrl}transaction/assembly/products/list",
        data: ids,
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      List<CartModel> curData = [];
      for (var element in (res.data as List)) {
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

      return curData;
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> getBulkSorted(String token, List<int> ids) async {
    final res = await dio.post("${baseUrl}transaction/assembly/products/sorted",
        data: ids,
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      List<BulkSortedModel> curData = [];
      for (var element in (res.data as List)) {
        List<CartModel> curCart = [];
        for (var element in (element["products"] as List)) {
          Map<String, dynamic> curPrice = {};

          if (element["product"]["offertaPrice"] == null) {
            if (element["product"]["distributorPrice"] <=
                element["product"]["professionalPrice"]) {
              curPrice = {
                "Distribution": element["product"]["distributorPrice"]
              };
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
              curPrice = {
                "Distribution": element["product"]["distributorPrice"]
              };
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

          curCart.add(CartModel(
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

        curData.add(BulkSortedModel(
            AssemblyModel(
                element["id"],
                element["from"]["id"],
                element["from"]["name"],
                element["from"]["address"],
                element["status"]["id"],
                element["status"]["name"],
                element["type"]["id"],
                element["type"]["name"],
                element["timestamp"]),
            element["to"],
            curCart));
      }

      return curData;
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> createTransfer(
      String token, List<CartModel> products, int storeId) async {
    final res = await dio.post("${baseUrl}transaction/transfer",
        data: {
          "to": storeId,
          "type": 3,
          "products": products.map((e) {
            return {"productId": e.model.id, "amount": e.quantity};
          }).toList()
        },
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      return true;
    } else if (res.statusCode == 415) {
      return ErrorModel("unsupported media", 415, "Unsupported Media Type");
    } else if (res.statusCode == 403) {
      return ErrorModel("forbidden", 403, "Stock forbidden");
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> getAddresses(String token, String name) async {
    final res = await dio.post("${baseUrl}stock/all",
        data: {
          "filters": {"name": name}
        },
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      return (res.data as List).map((e) => ShopModel.fromJson(e)).toList();
    } else if (res.statusCode == 415) {
      return ErrorModel("unsupported media", 415, "Unsupported Media Type");
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> selectAddress(
      String token, int transactionId, int stockId) async {
    final res =
        await dio.get("$baseUrl/transaction/transfer/$transactionId/4/$stockId",
            options: Options(validateStatus: (_) => true, headers: {
              "Content-Type": "application/json",
              "authorization": "Bearer $token",
            }));

    if (res.statusCode == 200) {
      if (res.data as bool) {
        return true;
      } else {
        return false;
      }
    } else if (res.statusCode == 415) {
      return ErrorModel("unsupported media", 415, "Unsupported Media Type");
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> completeTransferAssembly(
      String token, int transactionId, int stockId) async {
    final res = await dio.patch(
        "$baseUrl/transaction/transfer/$transactionId/4/$stockId",
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      return true;
    } else if (res.statusCode == 415) {
      return ErrorModel("unsupported media", 415, "Unsupported Media Type");
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> getTransfer(
      String token, int transactionId, List<int> objects, String type) async {
    if (type == "all") {
      final res =
          await dio.patch("$baseUrl/transaction/transfer/$transactionId/6",
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
    } else if (type == "missing") {
      final res =
          await dio.patch("$baseUrl/transaction/transfer/$transactionId/7",
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
    } else {
      final res = await dio.patch(
          "$baseUrl/transaction/transfer/$transactionId/partial",
          data: objects,
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
      } else {
        return ErrorModel("auth error", 401, "Unauthorized");
      }
    }
  }

  Future<dynamic> getProductBarcode(String token, String barcode) async {
    final res = await dio.get("$baseUrl/product/bar/$barcode",
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      return (res.data as List)
          .map((e) => ArrivalProductModel.fromJson(e))
          .toList();
    } else if (res.statusCode == 415) {
      return ErrorModel("unsupported media", 415, "Unsupported Media Type");
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<dynamic> setTransactionIncome(
      String token, int storeId, List<CartModel> models) async {
    final res = await dio.post("$baseUrl/transaction/income",
        data: {
          "to": storeId,
          "type": 1,
          "products": models
              .map((e) => {
                    "productId": e.model.id,
                    "amount": e.quantity,
                    "price": e.curPrice
                  })
              .toList()
        },
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));

    if (res.statusCode == 200) {
      return true;
    } else if (res.statusCode == 415) {
      return ErrorModel("unsupported media", 415, "Bad request body");
    } else if (res.statusCode == 400) {
      return ErrorModel(
          "bad transaction id", 400, "Transaction id must be INT");
    } else if (res.statusCode == 403) {
      return ErrorModel("forbidden", 403, "Stock forbidden");
    } else {
      return ErrorModel("auth error", 401, "Unauthorized");
    }
  }

  Future<void> bugReport(String token, String description) async {
    await dio.post("${baseUrl}bug/report",
        data: {"description": description},
        options: Options(validateStatus: (_) => true, headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }));
  }
}
