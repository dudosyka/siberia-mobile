class StockModel {
  final int id;
  final String name;
  final String address;
  final bool arrivalsManaging;
  final bool salesManaging;
  final bool transfersManaging;
  final bool? transfersProcessing;
  final int? typeId;
  final int? statusId;

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
        json["stockData"]["id"],
        json["stockData"] == null
            ? "None"
            : json["stockData"]["name"] ?? "None",
        json["stockData"] == null
            ? "None"
            : json["stockData"]["address"] ?? "None",
        json["operationsAccess"]["arrivalsManaging"],
        json["operationsAccess"]["salesManaging"],
        json["operationsAccess"]["transfersManaging"],
        json["operationsAccess"]["transfersProcessing"],
        json["transactionData"]?["type"]["id"],
        json["transactionData"]?["status"]["id"]);
  }

  StockModel(
      this.id,
      this.name,
      this.address,
      this.arrivalsManaging,
      this.salesManaging,
      this.transfersManaging,
      this.transfersProcessing,
      this.typeId,
      this.statusId);

  Map<String, dynamic> toJson() => {};
}
