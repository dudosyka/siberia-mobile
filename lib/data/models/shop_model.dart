class ShopModel {
  final int id;
  final String name;
  final String address;

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(json["id"], json["name"], json["address"]);
  }

  ShopModel(this.id, this.name, this.address);

  Map<String, dynamic> toJson() => {

  };
}