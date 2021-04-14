class User {
  final String email;
  final String displayName;
  final int id;

  User(this.email, this.displayName, this.id);

  factory User.fromJson(Map<String, dynamic> json) =>
      User(json["email"], json["displayName"], json["id"]);

  Map<String, dynamic> toJson() =>
      {"email": email, "displayName": displayName, "id": id};
}
