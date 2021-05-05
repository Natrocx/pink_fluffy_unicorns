class User {
  final String email;
  final String displayName;
  final int id;
  final AccountType accountType;

  User(this.email, this.displayName, this.id, this.accountType);

  factory User.fromJson(Map<String, dynamic> json) => User(json["email"],
      json["displayName"], json["id"], AccountType.values[json["accountType"]]);

  Map<String, dynamic> toJson() => {
        "email": email,
        "displayName": displayName,
        "id": id,
        "accountType": accountType.index
      };
}

enum AccountType { Student, Dozent }
