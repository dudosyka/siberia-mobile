class BrandModel {
  final int id;
  final String name;
  bool isSelected = false;

   factory BrandModel.fromJson(Map<String, dynamic> json) {
       return BrandModel(json["id"], json["name"]);
   }

  BrandModel(this.id, this.name);

   Map<String, dynamic> toJson() => {

   };
}