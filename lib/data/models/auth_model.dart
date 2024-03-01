class AuthModel {
  final String token;
  final String type;

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(json["token"], json["type"]);
  }

  AuthModel(this.token, this.type);

  Map<String, dynamic> toJson() => {
    "token": token,
    "type": type
  };
}