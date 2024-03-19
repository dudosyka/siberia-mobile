class ProductInfoModel {
  final int id;
  final String description;
  final String brand;
  final String collection;
  final String category;
  final String color;
  final double commonPrice;
  final double distributionPrice;
  final double professionalPrice;
  final double offertaPrice;

  factory ProductInfoModel.fromJson(Map<String, dynamic> json) {
    return ProductInfoModel(
        json["id"],
        json["description"],
        json["brand"]["name"],
        json["collection"]["name"],
        json["category"]["name"],
        json["color"],
        json["commonPrice"],
        json["distributorPrice"],
        json["professionalPrice"],
        json["offertaPrice"] ?? 0.0);
  }

  ProductInfoModel(
      this.id,
      this.description,
      this.brand,
      this.collection,
      this.category,
      this.color,
      this.commonPrice,
      this.distributionPrice,
      this.professionalPrice,
      this.offertaPrice);

  Map<String, dynamic> toJson() => {};
}
