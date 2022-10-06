import 'package:flutter/material.dart';
import 'package:project_chatapp/constants/firebase_paths.dart';
import 'package:project_chatapp/firebase/chat_services.dart';
import 'package:project_chatapp/firebase/firends_services.dart';
import 'package:project_chatapp/firebase/user_services.dart';
import 'package:project_chatapp/helpers/quick_functions.dart';
import 'package:project_chatapp/widgets/custom_appbar.dart';
import 'package:project_chatapp/widgets/quick_text.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List friendList = [];

  @override
  initState() {
    FriendsServices()
        .getFriendList()
        .then((val) => setState(() => friendList = val));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: const qText('Friend List')),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: ListView.builder(
        itemCount: friendList.length,
        itemBuilder: (context, index) {
          String friendID = friendList[index];
          return StreamBuilder(
            stream: userCollection.doc(friendID).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: qText(snapshot.error.toString()));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: qText('You have no friends'));
              } else {
                String friendName = snapshot.data![FirebasePaths.name];
                String friendAvatar = snapshot.data![FirebasePaths.avatar];
                String friendEmail = snapshot.data![FirebasePaths.email];
                return ListTile(
                  title: qText(friendName),
                  leading: CircleAvatar(
                    child: checkPersonAvatar(avatar: friendAvatar, size: 20),
                  ),
                  subtitle: qText(friendEmail),
                  onTap: () => ChatServices().checkDuoChat(
                    friendID: friendID,
                    friendName: friendName,
                    friendAvatar: friendAvatar,
                    friendEmail: friendEmail,
                    context: context,
                  ),
                );
              }
            },
          );
        },
      )),
    );
  }
}
