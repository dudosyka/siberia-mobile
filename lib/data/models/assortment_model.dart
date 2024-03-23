import 'package:path/path.dart' as p;

class AssortmentModel {
  final int id;
  final String name;
  final String vendorCode;
  final double price;
  final List? fileNames;
  final String eanCode;
  final double? quantity;
  int currentIndex = 0;

  factory AssortmentModel.fromJson(Map<String, dynamic> json) {
    List<String> files = [];

    if (json["photo"] != null) {
      for (var element in (json["photo"] as List)) {
        if (p.extension(element) == ".jpeg" ||
            p.extension(element) == ".png" ||
            p.extension(element) == ".jpg") {
          files.add(element);
        }
      }
    }

    return AssortmentModel(
        json["id"],
        json["name"],
        json["vendorCode"],
        json["price"],
        files.isEmpty ? null : files,
        json["eanCode"],
        json["quantity"]);
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
