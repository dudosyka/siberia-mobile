class ArrivalProductModel {
  final int id;
  final String name;
  final String vendorCode;
  final double price;

  factory ArrivalProductModel.fromJson(Map<String, dynamic> json) {
    return ArrivalProductModel(json["id"], json["name"] ?? "None",
        json["vendorCode"] ?? "None", json["price"]);
  }

  ArrivalProductModel(this.id, this.name, this.vendorCode, this.price);

  Map<String, dynamic> toJson() => {};
}
