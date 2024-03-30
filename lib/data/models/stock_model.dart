class StockModel {
  final int id;
  final String name;
  final String address;
  final bool arrivalsManaging;
  final bool salesManaging;
  final bool transfersManaging;
  final int? typeId;
  final int? statusId;

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
        json["stockData"]["id"],
        json["stockData"]["name"],
        json["stockData"]["address"],
        json["operationsAccess"]["arrivalsManaging"],
        json["operationsAccess"]["salesManaging"],
        json["operationsAccess"]["transfersManaging"],
        json["transactionData"]?["type"]["id"],
        json["transactionData"]?["status"]["id"]
    );
  }

  StockModel(this.id, this.name, this.address, this.arrivalsManaging,
      this.salesManaging, this.transfersManaging, this.typeId, this.statusId);

  Map<String, dynamic> toJson() => {};
}
