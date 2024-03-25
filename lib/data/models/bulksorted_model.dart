import 'assembly_model.dart';
import 'cart_model.dart';

class BulkSortedModel {
  final AssemblyModel assemblyModel;
  final String? to;
  final List<CartModel> cartModel;

  factory BulkSortedModel.fromJson(Map<String, dynamic> json) {
    return BulkSortedModel(
      json["assemblyModel"],
      json["to"],
      json["cartModel"]
    );
  }

  BulkSortedModel(this.assemblyModel, this.to, this.cartModel);

  Map<String, dynamic> toJson() => {};
}
