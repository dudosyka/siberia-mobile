class OutcomeModel {
  final int id;
  final int from;
  final int status;
  final int type;

  factory OutcomeModel.fromJson(Map<String, dynamic> json) {
    return OutcomeModel(
        json["id"], json["from"], json["status"], json["type"]);
  }

  OutcomeModel(this.id, this.from, this.status, this.type);

  Map<String, dynamic> toJson() => {};
}
