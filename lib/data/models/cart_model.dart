import 'assortment_model.dart';

class CartModel {
  final AssortmentModel model;
  int quantity;
  bool isSelected = false;
  Map<String, dynamic> priceType = {};
  double curPrice = 0;

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(AssortmentModel.fromJson(json["model"]), json["quantity"],
        json["priceType"], json["curPrice"]);
  }

  CartModel(this.model, this.quantity, this.priceType, this.curPrice);

  Map<String, dynamic> toJson() =>
      {"model": model.toJson(), "quantity": quantity};
}
