class StockModel {
  final int id;
  final String name;
  final String address;
  final bool arrivalsManaging;
  final bool salesManaging;
  final bool transfersManaging;

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
        json["stockData"]["id"],
        json["stockData"]["name"],
        json["stockData"]["address"],
        json["operationsAccess"]["arrivalsManaging"],
        json["operationsAccess"]["salesManaging"],
        json["operationsAccess"]["transfersManaging"]);
  }

  StockModel(this.id, this.name, this.address, this.arrivalsManaging,
      this.salesManaging, this.transfersManaging);

  Map<String, dynamic> toJson() => {};
}
