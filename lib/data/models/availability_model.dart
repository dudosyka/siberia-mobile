class AvailabilityModel {
  final int id;
  final String name;
  final String address;

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
        json["id"], json["name"] ?? "None", json["address"] ?? "None");
  }

  AvailabilityModel(this.id, this.name, this.address);

  Map<String, dynamic> toJson() => {};
}
