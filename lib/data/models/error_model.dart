class ErrorModel {
  final String type;
  final int statusCode;
  final String statusText;

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
        json["type"], json["httpStatusCode"], json["httpStatusText"]);
  }

  ErrorModel(this.type, this.statusCode, this.statusText);

  Map<String, dynamic> toJson() => {};
}
