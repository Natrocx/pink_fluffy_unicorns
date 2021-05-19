import 'dart:math';

import 'User.dart';

class QueryService {
  static Future<User> getUserInfo(String email) async {
    // Method stub, awaiting server Implementation
    return User(email, Random().nextInt(1 << 31).toString(),
        Random().nextInt(1 << 31), AccountType.Student);
  }

  static Future<User> getRandomUserSuggestion() async {
    return User("TBD", "TBD", -11, AccountType.Student);
  }

  static Future<User?> validateLogin(String email, String password) async {
    // hit API
    await Future.delayed(Duration(seconds: 2));
    return await getRandomUserSuggestion();
  }

  static Future<User?> register(
      String email, String password, String firstName, String lastName) async {
    // hit API
    await Future.delayed(Duration(seconds: 2));
    return User(email, firstName + " " + lastName, -1111,
        email.startsWith("d") ? AccountType.Dozent : AccountType.Student);
  }

  static Future<List<String>> getMajorCouseList() async {
    return ["AI - Angewandte Informatik", "Uncoole Studiengänge"];
  }

  static Future<List<String>> getPossibleMinorCourses(
      String majorCourse) async {
    return ["TINF20AI1", "der Lappen-Kurs"];
  }

  static Future<Map<String, List<String>>> getCourseInfo() async {
    var majorCourses = await getMajorCouseList();
    Map<String, List<String>> majorWithMinorCourseDetails = Map();
    for (var course in majorCourses) {
      majorWithMinorCourseDetails[course] =
          await getPossibleMinorCourses(course);
    }
    return majorWithMinorCourseDetails;
  }

  static Future<bool> checkEmailVerificationCode(String code) async {
    return true;
  }
}
