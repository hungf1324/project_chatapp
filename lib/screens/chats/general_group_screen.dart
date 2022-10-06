import 'package:flutter/material.dart';
import 'package:project_chatapp/constants/firebase_paths.dart';
import 'package:project_chatapp/firebase/chat_services.dart';
import 'package:project_chatapp/firebase/firends_services.dart';
import 'package:project_chatapp/helpers/quick_functions.dart';
import 'package:project_chatapp/helpers/quick_navigators.dart';
import 'package:project_chatapp/screens/chats/home_screen.dart';
import 'package:project_chatapp/screens/chats/messages_screen.dart';
import 'package:project_chatapp/widgets/custom_appbar.dart';
import 'package:project_chatapp/widgets/quick_text.dart';

class GeneralGroupScreen extends StatefulWidget {
  const GeneralGroupScreen({super.key, required this.userID});

  final String userID;

  @override
  State<GeneralGroupScreen> createState() => _GeneralGroupScreenState();
}

class _GeneralGroupScreenState extends State<GeneralGroupScreen> {
  List general = [];
  @override
  void initState() {
    FriendsServices()
        .getGeneralGroup(userID: widget.userID)
        .then((val) => setState(() => general = val));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: const qText('General Group')),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: ListView.builder(
        itemCount: general.length,
        itemBuilder: (context, index) {
          String groupID = general[index];
          return StreamBuilder(
            stream: chatCollection.doc(groupID).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: qText(snapshot.error.toString()));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: qText('No General Group'),
                );
              } else {
                String groupName = snapshot.data![FirebasePaths.name];
                String groupAvatar = snapshot.data![FirebasePaths.avatar];
                int groupMemberCount =
                    snapshot.data![FirebasePaths.members].length;
                return ListTile(
                  title: qText(groupName),
                  subtitle: qText('$groupMemberCount members'),
                  leading: CircleAvatar(
                    child: checkGroupAvatar(avatar: groupAvatar, size: 22),
                  ),
                  onTap: () {
                    goRemoveUntilScreen(context, screen: const HomeScreen());
                    goNextScreen(context,
                        screen: MessagesScreen(
                          chatID: groupID,
                          chatName: groupName,
                          chatAvatar: checkGroupAvatar(avatar: groupAvatar),
                        ));
                  },
                );
              }
            },
          );
        },
      )),
    );
  }
}
