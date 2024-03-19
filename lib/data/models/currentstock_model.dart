import 'package:mobile_app_slb/data/models/cart_model.dart';

class CurrentStockModel {
  final int id;
  final int statusId;
  final List<CartModel> cartModels;

  factory CurrentStockModel.fromJson(Map<String, dynamic> json) {
    return CurrentStockModel(json["id"], json["transactionData"]["type"]["id"],
        json["transactionData"]);
  }

  CurrentStockModel(this.id, this.statusId, this.cartModels);

  Map<String, dynamic> toJson() => {};
}
