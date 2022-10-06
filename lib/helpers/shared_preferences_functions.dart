import 'package:shared_preferences/shared_preferences.dart';

class SFFunction {
  static String userSignInKEY = "SIGNINKEY";
  static String userNameKEY = "USERNAMEKEY";
  static String userEmailKEY = "USEREMAILKEY";

  static Future<bool> saveUserSignInStatus(bool isUserSignIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool(userSignInKEY, isUserSignIn);
  }

  static Future<bool> saveUserName(String name) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(userNameKEY, name);
  }

  static Future<bool> saveUserEmail(String email) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(userEmailKEY, email);
  }

  static Future<bool?> getUserSignInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userSignInKEY);
  }

  static Future<String?> getUserName() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKEY);
  }

  static Future<String?> getUserEmail() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKEY);
  }
}
