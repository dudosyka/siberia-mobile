class ProductInfoModel {
  final int id;
  final String name;
  final List? photos;
  final String vendorCode;
  final String eanCode;
  final double quantity;
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
        json["name"] ?? "None",
        json["photo"],
        json["vendorCode"] ?? "None",
        json["eanCode"] ?? "None",
        json["quantity"],
        json["description"] ?? "None",
        json["brand"] == null ? "None" : json["brand"]["name"] ?? "None",
        json["collection"] == null
            ? "None"
            : json["collection"]["name"] ?? "None",
        json["category"] == null ? "None" : json["category"]["name"] ?? "None",
        json["color"] ?? "None",
        json["commonPrice"],
        json["distributorPrice"],
        json["professionalPrice"],
        json["offertaPrice"] ?? 0.0);
  }

  ProductInfoModel(
      this.id,
      this.name,
      this.photos,
      this.vendorCode,
      this.eanCode,
      this.quantity,
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
