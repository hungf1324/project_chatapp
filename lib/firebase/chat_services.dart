import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_chatapp/constants/firebase_paths.dart';
import 'package:project_chatapp/firebase/user_services.dart';
import 'package:project_chatapp/helpers/quick_functions.dart';
import 'package:project_chatapp/screens/chats/messages_screen.dart';
import 'package:project_chatapp/screens/chats/detail_chat_screen.dart';
import 'package:project_chatapp/screens/chats/tempchat_screen.dart';
import 'package:project_chatapp/screens/users/detail_user_screen.dart';

final CollectionReference chatCollection =
    FirebaseFirestore.instance.collection(FirebasePaths.chatCollection);

ChatServices chatServices = ChatServices();

class ChatServices {
  getChatSnapshots() async {
    return chatCollection
        .where(FirebasePaths.members, arrayContains: currentUID)
        .orderBy(FirebasePaths.lastTime, descending: true)
        .snapshots();
  }

  accessChatData({required String chatID}) async {
    return await chatCollection.doc(chatID).get();
  }

  getChatName({required String chatID}) async {
    DocumentSnapshot<Object?> snapshot = await accessChatData(chatID: chatID);
    String chatType = snapshot[FirebasePaths.type];
    if (chatType == "Duo") {
      DocumentSnapshot<Object?> snap = await UserService()
          .accessUserData(userID: snapshot[FirebasePaths.name]);
      return snap[FirebasePaths.name];
    } else {
      return snapshot[FirebasePaths.name];
    }
  }

  getChatAvatar({required String chatID}) async {
    DocumentSnapshot<Object?> snapshot = await accessChatData(chatID: chatID);
    String chatType = snapshot[FirebasePaths.type];
    if (chatType == "Duo") {
      DocumentSnapshot<Object?> snap = await UserService()
          .accessUserData(userID: snapshot[FirebasePaths.name]);
      String chatAvatar = snap[FirebasePaths.avatar];
      return chatAvatar == ''
          ? const Icon(Icons.person)
          : Image.network(chatAvatar.toString());
    } else {
      String chatAvatar = snapshot[FirebasePaths.avatar];
      return chatAvatar == ''
          ? const Icon(Icons.people)
          : Image.network(chatAvatar.toString());
    }
  }

  getChatMessages({required String chatID}) async {
    return chatCollection
        .doc(chatID)
        .collection(FirebasePaths.messageCollection)
        .orderBy(FirebasePaths.time)
        .snapshots();
  }

  getChatSeenList({required String chatID}) async {
    DocumentSnapshot<Object?> snapshot = await accessChatData(chatID: chatID);
    return snapshot[FirebasePaths.seen];
  }

  getChatAdmin({required String chatID}) async {
    DocumentSnapshot<Object?> snapshot = await accessChatData(chatID: chatID);
    return snapshot[FirebasePaths.admin];
  }

  showChatDetail({
    required String chatID,
    required BuildContext context,
  }) async {
    final navigator = Navigator.of(context);
    DocumentSnapshot<Object?> snapshot = await accessChatData(chatID: chatID);
    String chatType = snapshot[FirebasePaths.type];
    String chatName = snapshot[FirebasePaths.name];
    String chatAvatar = snapshot[FirebasePaths.avatar];
    String chatAdmin = snapshot[FirebasePaths.admin];
    if (chatType == "Duo") {
      String friendID = chatAdmin == currentUID ? chatName : chatAdmin;
      DocumentSnapshot<Object?> snap =
          await UserService().accessUserData(userID: friendID);
      String friendName = snap[FirebasePaths.name];
      String friendAvatar = snap[FirebasePaths.avatar];
      String friendEmail = snap[FirebasePaths.email];
      return navigator.push(
        MaterialPageRoute(
          builder: (context) => DetailUserScreen(
            chatID: chatID,
            userID: friendID,
            userEmail: friendEmail,
            userAvatar: friendAvatar,
            userName: friendName,
          ),
        ),
      );
    } else {
      return navigator.push(
        MaterialPageRoute(
          builder: (context) => DetailChatScreen(
            chatID: chatID,
            adminID: chatAdmin,
            chatAvatar: chatAvatar,
            chatName: chatName,
          ),
        ),
      );
    }
  }

  Future changeChatName({required String chatID, required String newChatName}) {
    return chatCollection.doc(chatID).update({
      FirebasePaths.name: newChatName,
      FirebasePaths.searchName: separateText(newChatName)
    });
  }

  Future createGroupChat({
    required List<String> friendIDs,
    required String firstMessage,
    required String chatName,
    required BuildContext context,
  }) async {
    final navigator = Navigator.of(context);
    DocumentReference chatsDocumentReference = await chatCollection.add({
      FirebasePaths.name: chatName,
      FirebasePaths.admin: currentUID,
      FirebasePaths.members: [currentUID],
      FirebasePaths.avatar: '',
      FirebasePaths.lastMessage: firstMessage,
      FirebasePaths.lastSender: currentUID,
      FirebasePaths.lastTime: DateTime.now().millisecondsSinceEpoch,
      FirebasePaths.seen: [currentUID],
      FirebasePaths.id: "",
      FirebasePaths.type: "Group",
      FirebasePaths.searchName: separateText(chatName),
    });

    await chatsDocumentReference.update({
      FirebasePaths.id: chatsDocumentReference.id,
      FirebasePaths.members: FieldValue.arrayUnion(friendIDs),
    });

    String chatID = chatsDocumentReference.id;

    Map<String, dynamic> messageData = {
      FirebasePaths.content: firstMessage,
      FirebasePaths.sender: currentUID,
      FirebasePaths.time: DateTime.now().millisecondsSinceEpoch,
      FirebasePaths.type: "String",
    };

    chatCollection
        .doc(chatID)
        .collection(FirebasePaths.messageCollection)
        .add(messageData);

    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (context) => MessagesScreen(
          chatID: chatID,
          chatName: chatName,
          chatAvatar: checkGroupAvatar(avatar: '', size: 20),
        ),
      ),
    );
  }

  Future checkDuoChat({
    required String friendID,
    required String friendName,
    required String friendAvatar,
    required String friendEmail,
    required BuildContext context,
  }) async {
    final navigator = Navigator.of(context);
    var chatSnapshot1 = await chatCollection
        .where(FirebasePaths.type, isEqualTo: "Duo")
        .where(FirebasePaths.members, isEqualTo: [currentUID, friendID]).get();
    var chatSnapshot2 = await chatCollection
        .where(FirebasePaths.type, isEqualTo: "Duo")
        .where(FirebasePaths.members, isEqualTo: [friendID, currentUID]).get();

    if (chatSnapshot1.docs.isEmpty && chatSnapshot2.docs.isEmpty) {
      return navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => TempChatScreen(
            friendID: friendID,
            chatName: friendName,
            userEmail: friendEmail,
            chatAvatar: friendAvatar,
          ),
        ),
      );
    } else {
      String chatID;
      if (chatSnapshot2.docs.isEmpty) {
        chatID = chatSnapshot1.docs[0][FirebasePaths.id];
      } else {
        chatID = chatSnapshot2.docs[0][FirebasePaths.id];
      }

      return navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => MessagesScreen(
            chatID: chatID,
            chatName: friendName,
            chatAvatar: checkPersonAvatar(avatar: friendAvatar, size: 20),
          ),
        ),
      );
    }
  }

  Future createDuoChat({
    required String firstMessage,
    required String friendID,
    required String chatName,
    required BuildContext context,
  }) async {
    final navigator = Navigator.of(context);
    DocumentReference chatsDocumentReference = await chatCollection.add({
      FirebasePaths.name: friendID,
      FirebasePaths.admin: currentUID,
      FirebasePaths.members: [currentUID],
      FirebasePaths.avatar: '',
      FirebasePaths.lastMessage: firstMessage,
      FirebasePaths.lastSender: currentUID,
      FirebasePaths.lastTime: DateTime.now().millisecondsSinceEpoch,
      FirebasePaths.seen: [currentUID],
      FirebasePaths.id: "",
      FirebasePaths.type: "Duo",
      FirebasePaths.searchName: [],
    });

    await chatsDocumentReference.update({
      FirebasePaths.id: chatsDocumentReference.id,
      FirebasePaths.members: FieldValue.arrayUnion([friendID]),
    });

    String chatID = chatsDocumentReference.id;

    Map<String, dynamic> messageData = {
      FirebasePaths.content: firstMessage,
      FirebasePaths.sender: currentUID,
      FirebasePaths.time: DateTime.now().millisecondsSinceEpoch,
      FirebasePaths.type: "String",
    };

    chatCollection
        .doc(chatID)
        .collection(FirebasePaths.messageCollection)
        .add(messageData);

    chatCollection.doc(chatID).update({
      FirebasePaths.lastMessage: firstMessage,
      FirebasePaths.lastSender: currentUID,
      FirebasePaths.lastTime: DateTime.now().millisecondsSinceEpoch,
      FirebasePaths.seen: [currentUID],
    });

    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (context) => MessagesScreen(
          chatID: chatID,
          chatName: chatName,
          chatAvatar: checkPersonAvatar(avatar: '', size: 20),
        ),
      ),
    );
  }

  sendMessage({
    required String id,
    required String content,
  }) {
    Map<String, dynamic> messageData = {
      FirebasePaths.content: content,
      FirebasePaths.sender: currentUID,
      FirebasePaths.time: DateTime.now().millisecondsSinceEpoch,
      FirebasePaths.type: "String",
    };

    chatCollection
        .doc(id)
        .collection(FirebasePaths.messageCollection)
        .add(messageData);

    chatCollection.doc(id).update({
      FirebasePaths.lastMessage: messageData[FirebasePaths.content],
      FirebasePaths.lastSender: messageData[FirebasePaths.sender],
      FirebasePaths.lastTime: messageData[FirebasePaths.time],
      FirebasePaths.seen: [currentUID],
    });
  }

  searchChatsID({required String? searchCase}) async {
    searchCase!.toLowerCase();
    List<String> searchList = [];
    List<String> groupChatID = [];
    List<String> duoChatID = [];
    if (searchCase != '' && searchCase.isNotEmpty) {
      var groupSnapshot = await chatCollection
          .where(FirebasePaths.type, isEqualTo: "Group")
          .where(FirebasePaths.members, arrayContains: currentUID)
          .get();
      for (var chat in groupSnapshot.docs) {
        groupChatID.add(chat[FirebasePaths.id]);
      }
      var groupSearch = await chatCollection
          .where(FirebasePaths.id, whereIn: groupChatID)
          .where(FirebasePaths.searchName, arrayContains: searchCase)
          .get();
      for (var group in groupSearch.docs) {
        searchList.add(group[FirebasePaths.id]);
      }
      var chatSnapshot = await chatCollection
          .where(FirebasePaths.type, isEqualTo: "Duo")
          .where(FirebasePaths.members, arrayContains: currentUID)
          .get();
      for (var chat in chatSnapshot.docs) {
        String admin = chat[FirebasePaths.admin];
        String friendID =
            admin == currentUID ? chat[FirebasePaths.name] : admin;
        duoChatID.add(friendID);
      }
      var friendSearch = await userCollection
          .where(FirebasePaths.id, whereIn: duoChatID)
          .where(FirebasePaths.searchName, arrayContains: searchCase)
          .get();
      for (var friend in friendSearch.docs) {
        var chatSnapshot1 = await chatCollection
            .where(FirebasePaths.type, isEqualTo: "Duo")
            .where(FirebasePaths.members,
                isEqualTo: [currentUID, friend[FirebasePaths.id]]).get();
        var chatSnapshot2 = await chatCollection
            .where(FirebasePaths.type, isEqualTo: "Duo")
            .where(FirebasePaths.members,
                isEqualTo: [friend[FirebasePaths.id], currentUID]).get();
        if (chatSnapshot2.docs.isEmpty) {
          searchList.add(chatSnapshot1.docs[0][FirebasePaths.id]);
        } else {
          searchList.add(chatSnapshot2.docs[0][FirebasePaths.id]);
        }
      }
    }
    return searchList;
  }

  searchChats({required String? searchCase}) async {
    searchCase!.toLowerCase();
    List<String> searchList = [];
    List<String> groupChatID = [];
    List<String> duoChatID = [];
    if (searchCase != '' && searchCase.isNotEmpty) {
      var groupSnapshot = await chatCollection
          .where(FirebasePaths.type, isEqualTo: "Group")
          .where(FirebasePaths.members, arrayContains: currentUID)
          .get();
      for (var chat in groupSnapshot.docs) {
        groupChatID.add(chat[FirebasePaths.id]);
      }
      var groupSearch = await chatCollection
          .where(FirebasePaths.id, whereIn: groupChatID)
          .where(FirebasePaths.searchName, arrayContains: searchCase)
          .get();
      for (var group in groupSearch.docs) {
        searchList.add(group[FirebasePaths.id]);
      }
      var chatSnapshot = await chatCollection
          .where(FirebasePaths.type, isEqualTo: "Duo")
          .where(FirebasePaths.members, arrayContains: currentUID)
          .get();
      for (var chat in chatSnapshot.docs) {
        String admin = chat[FirebasePaths.admin];
        String friendID =
            admin == currentUID ? chat[FirebasePaths.name] : admin;
        duoChatID.add(friendID);
      }
      var friendSearch = await userCollection
          .where(FirebasePaths.id, whereIn: duoChatID)
          .where(FirebasePaths.searchName, arrayContains: searchCase)
          .get();
      for (var friend in friendSearch.docs) {
        searchList.add(friend[FirebasePaths.id]);
      }
    }
    return searchList;
  }

  updateMember({required String chatID, required List<String> usersID}) {
    return chatCollection.doc(chatID).update({FirebasePaths.members: usersID});
  }

  kickMember({required String chatID, required String userID}) {
    return chatCollection.doc(chatID).update({
      FirebasePaths.members: FieldValue.arrayRemove([userID])
    });
  }

  deletedChat({required String chatID}) async {
    FirebaseFirestore.instance.runTransaction(
        (transaction) async => transaction.delete(chatCollection.doc(chatID)));
  }
}
