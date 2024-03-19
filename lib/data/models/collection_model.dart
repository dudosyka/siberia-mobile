class CollectionModel {
  final int id;
  final String name;
  bool isSelected = false;

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(json["id"], json["name"]);
  }

  CollectionModel(this.id, this.name);

  Map<String, dynamic> toJson() => {

  };
}