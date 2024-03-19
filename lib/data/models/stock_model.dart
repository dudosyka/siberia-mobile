class StockModel {
  final int id;
  final String name;
  final String address;

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(json["id"], json["name"], json["address"]);
  }

  StockModel(this.id, this.name, this.address);

  Map<String, dynamic> toJson() => {};
}
