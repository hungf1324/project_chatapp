import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_chatapp/constants/firebase_paths.dart';
import 'package:project_chatapp/firebase/chat_services.dart';
import 'package:project_chatapp/firebase/user_services.dart';

class FriendsServices {
  sendRequest({required String friendID}) async {
    userCollection.doc(currentUID).update({
      FirebasePaths.requestSend: FieldValue.arrayUnion([friendID])
    });
    userCollection.doc(friendID).update({
      FirebasePaths.requestReceived: FieldValue.arrayUnion([currentUID])
    });
  }

  cancelRequest({required String friendID}) async {
    userCollection.doc(currentUID).update({
      FirebasePaths.requestSend: FieldValue.arrayRemove([friendID])
    });
    userCollection.doc(friendID).update({
      FirebasePaths.requestReceived: FieldValue.arrayRemove([currentUID])
    });
  }

  acceptedRequest({required String friendID}) async {
    userCollection.doc(currentUID).update({
      FirebasePaths.friends: FieldValue.arrayUnion([friendID])
    });
    userCollection.doc(currentUID).update({
      FirebasePaths.requestReceived: FieldValue.arrayRemove([friendID])
    });
    userCollection.doc(friendID).update({
      FirebasePaths.friends: FieldValue.arrayUnion([currentUID])
    });
    userCollection.doc(friendID).update({
      FirebasePaths.requestSend: FieldValue.arrayRemove([friendID])
    });
  }

  refusedRequest({required String friendID}) async {
    userCollection.doc(currentUID).update({
      FirebasePaths.requestReceived: FieldValue.arrayRemove([friendID])
    });
    userCollection.doc(friendID).update({
      FirebasePaths.requestSend: FieldValue.arrayRemove([currentUID])
    });
  }

  deletedFriend({required String friendID}) async {
    userCollection.doc(currentUID).update({
      FirebasePaths.friends: FieldValue.arrayRemove([friendID])
    });
    userCollection.doc(friendID).update({
      FirebasePaths.friends: FieldValue.arrayRemove([currentUID])
    });
  }

  searchFriends({required String? searchCase}) async {
    searchCase!.toLowerCase();
    List<String>? listID = [];
    List<String>? searchID = [];
    var friendSnapshot = await userCollection
        .where(FirebasePaths.friends, arrayContains: currentUID)
        .get();
    for (var friend in friendSnapshot.docs) {
      String friendID = friend[FirebasePaths.id];
      listID.add(friendID);
    }
    var searchSnapshot = await userCollection
        .where(FirebasePaths.id, whereIn: listID)
        .where(FirebasePaths.searchName, arrayContains: searchCase)
        .get();

    for (var friend in searchSnapshot.docs) {
      String friendID = friend[FirebasePaths.id];
      searchID.add(friendID);
    }
    return searchID;
  }

  getFriendChat() async {
    return chatCollection
        .where(FirebasePaths.members, arrayContains: currentUID)
        .where(FirebasePaths.type, isEqualTo: "Duo")
        .orderBy(FirebasePaths.lastTime, descending: true)
        .snapshots();
  }

  getFriendList() async {
    DocumentSnapshot<Object?> snapshot =
        await UserService().accessUserData(userID: currentUID);
    return snapshot[FirebasePaths.friends];
  }

  getRequestSendList() async {
    DocumentSnapshot<Object?> snapshot =
        await UserService().accessUserData(userID: currentUID);
    return snapshot[FirebasePaths.requestSend];
  }

  getRequestReceivedList() async {
    DocumentSnapshot<Object?> snapshot =
        await UserService().accessUserData(userID: currentUID);
    return snapshot[FirebasePaths.requestReceived];
  }

  getGeneralGroup({required String userID}) async {
    List general = [];
    var snap = await chatCollection
        .where(FirebasePaths.members, arrayContainsAny: [currentUID, userID])
        .where(FirebasePaths.type, isEqualTo: "Group")
        .get();
    for (var group in snap.docs) {
      String groupID = group[FirebasePaths.id];
      general.add(groupID);
    }
    return general;
  }
}
