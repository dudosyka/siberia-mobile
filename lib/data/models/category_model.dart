class CategoryModel {
  final int id;
  final String name;
  final List<CategoryModel> children;
  bool isSelected = false;
  bool isOpened = false;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
        json["id"],
        json["name"],
        json["children"] == null
            ? []
            : List<CategoryModel>.from(
                json["children"].map((x) => CategoryModel.fromJson(x))));
  }

  CategoryModel(this.id, this.name, this.children);

  Map<String, dynamic> toJson() => {};
}
