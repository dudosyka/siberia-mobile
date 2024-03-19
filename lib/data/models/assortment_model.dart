class AssortmentModel {
  final int id;
  final String name;
  final String vendorCode;
  final double price;
  final List? fileNames;
  final String eanCode;
  final double? quantity;

  factory AssortmentModel.fromJson(Map<String, dynamic> json) {
    return AssortmentModel(json["id"], json["name"], json["vendorCode"],
        json["price"], json["photo"], json["eanCode"], json["quantity"]);
  }

  AssortmentModel(this.id, this.name, this.vendorCode, this.price,
      this.fileNames, this.eanCode, this.quantity);

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "vendorCode": vendorCode,
    "price": price,
    "photo": fileNames,
    "eanCode": eanCode,
    "quantity": quantity
  };
}
