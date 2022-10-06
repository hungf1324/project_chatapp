import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_chatapp/helpers/shared_preferences_functions.dart';
import 'package:project_chatapp/firebase/user_services.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
AuthService authService = AuthService();

class AuthService {
  Future emailRegister({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      UserService().reloadCurrentUserID();
      UserService().saveUserData(name: name, email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      print(e);
      return e.code;
    }
  }

  Future emailLogin({
    required String email,
    required String password,
  }) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      UserService().reloadCurrentUserID();
      return true;
    } on FirebaseAuthException catch (e) {
      print(e);
      return e.code;
    }
  }

  saveToSF({required String email, required String name}) async {
    await SFFunction.saveUserSignInStatus(true);
    await SFFunction.saveUserEmail(email);
  }

  Future logOut() async {
    try {
      await SFFunction.saveUserSignInStatus(false);
      await SFFunction.saveUserEmail('');
    } catch (e) {
      return null;
    }
  }
}
