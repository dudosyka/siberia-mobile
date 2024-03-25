class AssemblyModel {
  final int id;
  final int from;
  final String fromName;
  final String? address;
  final int statusId;
  final String statusName;
  final int typeId;
  final String typeName;
  final String timestamp;
  bool isSelected = false;

  factory AssemblyModel.fromJson(Map<String, dynamic> json) {
    return AssemblyModel(
        json["id"],
        json["from"],
        json["fromName"],
        json["address"],
        json["status"]["id"],
        json["status"]["name"],
        json["type"]["id"],
        json["type"]["name"],
        json["timestamp"]);
  }

  AssemblyModel(this.id, this.from, this.fromName, this.address, this.statusId,
      this.statusName, this.typeId, this.typeName, this.timestamp);

  Map<String, dynamic> toJson() => {};
}
