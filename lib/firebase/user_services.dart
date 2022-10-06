import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_chatapp/constants/firebase_paths.dart';
import 'package:project_chatapp/helpers/quick_functions.dart';

String currentUID = FirebaseAuth.instance.currentUser!.uid;
final CollectionReference userCollection =
    FirebaseFirestore.instance.collection(FirebasePaths.userCollection);

class UserService {
  Future saveUserData({
    required String name,
    required String email,
  }) async {
    return await userCollection.doc(currentUID).set({
      FirebasePaths.id: currentUID,
      FirebasePaths.name: name,
      FirebasePaths.email: email,
      FirebasePaths.avatar: "",
      FirebasePaths.friends: [],
      FirebasePaths.requestSend: [],
      FirebasePaths.requestReceived: [],
      FirebasePaths.searchName: separateText(name),
      FirebasePaths.searchEmail: separateText(email),
    });
  }

  Future checkUser({required String email}) async {
    return await userCollection
        .where(FirebasePaths.email, isEqualTo: email)
        .get();
  }

  reloadCurrentUserID() async {
    currentUID = FirebaseAuth.instance.currentUser!.uid;
  }

  accessUserData({required String userID}) async {
    return await userCollection.doc(userID).get();
  }

  getUserName({required String id}) async {
    DocumentSnapshot<Object?> snapshot = await accessUserData(userID: id);
    return snapshot[FirebasePaths.name];
  }

  getUserEmail({required String id}) async {
    DocumentSnapshot<Object?> snapshot = await accessUserData(userID: id);
    return snapshot[FirebasePaths.email];
  }

  getUserAvatar({required String id}) async {
    DocumentSnapshot<Object?> snapshot = await accessUserData(userID: id);
    return snapshot[FirebasePaths.avatar];
  }

  searchUsers({required String searchCase}) async {
    searchCase.toLowerCase();
    List<String> searchList = [];
    var nameSnapshot = await userCollection
        .where(FirebasePaths.searchName, arrayContains: searchCase)
        .orderBy(FirebasePaths.name)
        .get();
    for (var user in nameSnapshot.docs) {
      String userID = user[FirebasePaths.id];
      if (userID != currentUID) searchList.add(userID);
    }
    var emailSnapshot = await userCollection
        .where(FirebasePaths.searchEmail, arrayContains: searchCase)
        .orderBy(FirebasePaths.email)
        .get();
    for (var user in emailSnapshot.docs) {
      String userID = user[FirebasePaths.id];
      if (searchList.contains(userID) == false && userID != currentUID) {
        searchList.add(userID);
      }
    }
    return searchList;
  }
}
