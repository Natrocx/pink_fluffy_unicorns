import 'package:hive/hive.dart';

part 'User.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String email;
  @HiveField(1)
  final String displayName;
  @HiveField(2)
  final int id;
  @HiveField(3)
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

@HiveType(typeId: 1)
enum AccountType {
  @HiveField(0)
  Student,
  @HiveField(1)
  Dozent
}
