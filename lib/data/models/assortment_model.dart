class AssortmentModel {
  final int id;
  final String name;
  final String vendorCode;
  final double price;
  final String fileName;
  final String eanCode;
  final double? quantity;

  factory AssortmentModel.fromJson(Map<String, dynamic> json) {
    return AssortmentModel(json["id"], json["name"], json["vendorCode"],
        json["price"], json["fileName"], json["eanCode"], json["quantity"]);
  }

  AssortmentModel(this.id, this.name, this.vendorCode, this.price,
      this.fileName, this.eanCode, this.quantity);

  Map<String, dynamic> toJson() => {};
}
