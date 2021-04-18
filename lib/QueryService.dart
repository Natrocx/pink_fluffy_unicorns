import 'dart:math';

import 'User.dart';

class QueryService {
  static Future<User> getUserInfo(String email) async {
    // Method stub, awaiting server Implementation
    return User(
        email, Random().nextInt(1 << 31).toString(), Random().nextInt(1 << 31));
  }

  static Future<User> getRandomUserSuggestion() async {
    return User("TBD", "TBD", -11);
  }
}
