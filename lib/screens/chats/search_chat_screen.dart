import 'package:flutter/material.dart';
import 'package:project_chatapp/constants/firebase_paths.dart';
import 'package:project_chatapp/firebase/chat_services.dart';
import 'package:project_chatapp/firebase/user_services.dart';
import 'package:project_chatapp/helpers/quick_functions.dart';
import 'package:project_chatapp/helpers/quick_navigators.dart';
import 'package:project_chatapp/screens/chats/messages_screen.dart';
import 'package:project_chatapp/widgets/custom_appbar.dart';
import 'package:project_chatapp/widgets/custom_textform.dart';
import 'package:project_chatapp/widgets/quick_text.dart';

class SearchChatScreen extends StatefulWidget {
  const SearchChatScreen({super.key});

  @override
  State<SearchChatScreen> createState() => _SearchChatScreenState();
}

class _SearchChatScreenState extends State<SearchChatScreen> {
  List<String> listID = [];
  List<String> listChatID = [];

  reloadSearch(String? text) {
    if (text!.trim() != '' && text.isNotEmpty) {
      ChatServices()
          .searchChatsID(searchCase: text)
          .then((value) => setState((() => listChatID = value)));
      ChatServices()
          .searchChats(searchCase: text)
          .then((value) => setState((() => listID = value)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: CustomTextForm(
          hintText: 'Search chat here...',
          autofocus: true,
          borderWidth: 0,
          borderColor: Colors.transparent,
          borderErrorColor: Colors.transparent,
          borderFocusedColor: Colors.transparent,
          fillColor: Colors.transparent,
          searchColor: Colors.black,
          onChanged: (value) => reloadSearch(value),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: listChatID == []
            ? _buildNoChats()
            : ListView.builder(
                itemCount: listChatID.length,
                itemBuilder: (context, index) {
                  String chatID = listChatID[index];
                  String userID = listID[index];
                  return StreamBuilder(
                    stream: chatCollection.doc(chatID).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return qText(snapshot.error.toString());
                      } else if (!snapshot.hasData) {
                        return _buildNoChats();
                      } else {
                        String chatType = snapshot.data![FirebasePaths.type];
                        String groupName = snapshot.data![FirebasePaths.name];
                        String groupAvatar =
                            snapshot.data![FirebasePaths.avatar];
                        return chatType == "Duo"
                            ? _buildDuoChats(chatID: chatID, userID: userID)
                            : _buildGroupChats(
                                chatID: chatID,
                                groupName: groupName,
                                groupAvatar: groupAvatar,
                              );
                      }
                    },
                  );
                },
              ),
      ),
    );
  }

  _buildDuoChats({
    required String chatID,
    required String userID,
  }) {
    return StreamBuilder(
      stream: userCollection.doc(userID).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return qText(snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return _buildNoChats();
        } else {
          String userName = snapshot.data![FirebasePaths.name];
          String userAvatar = snapshot.data![FirebasePaths.avatar];
          return _buildChatTile(
            chatID: chatID,
            name: userName,
            avatar: checkPersonAvatar(avatar: userAvatar),
          );
        }
      },
    );
  }

  _buildGroupChats({
    required String chatID,
    required String groupName,
    required String groupAvatar,
  }) {
    return _buildChatTile(
      chatID: chatID,
      name: groupName,
      avatar: checkGroupAvatar(avatar: groupAvatar),
    );
  }

  _buildChatTile({
    required String chatID,
    required String name,
    required Widget? avatar,
  }) {
    return ListTile(
      leading: CircleAvatar(maxRadius: 15, child: avatar),
      title:
          qText(name, align: TextAlign.start, overflow: TextOverflow.ellipsis),
      onTap: () => goNextScreen(
        context,
        screen: MessagesScreen(
          chatID: chatID,
          chatName: name,
          chatAvatar: avatar,
        ),
      ),
    );
  }

  _buildNoChats() => const Center(
        child: qText(
          "No chat to search.",
          align: TextAlign.center,
        ),
      );
}
