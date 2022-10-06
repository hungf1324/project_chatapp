import 'package:flutter/material.dart';
import 'package:project_chatapp/firebase/chat_services.dart';
import 'package:project_chatapp/helpers/quick_functions.dart';
import 'package:project_chatapp/helpers/quick_navigators.dart';
import 'package:project_chatapp/screens/chats/selected_friends_screen.dart';
import 'package:project_chatapp/screens/chats/home_screen.dart';
import 'package:project_chatapp/screens/users/detail_user_screen.dart';
import 'package:project_chatapp/widgets/custom_appbar.dart';
import 'package:project_chatapp/widgets/custom_textform.dart';
import 'package:project_chatapp/widgets/quick_text.dart';

class TempChatScreen extends StatelessWidget {
  const TempChatScreen({
    super.key,
    this.friendID = '',
    this.friendList = const [],
    required this.chatName,
    required this.chatAvatar,
    this.userEmail = '',
    this.friendStatus = '',
  });

  final String friendID;
  final String chatName;
  final String chatAvatar;
  final List<String> friendList;
  final String userEmail;
  final String friendStatus;

  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = TextEditingController();
    return Scaffold(
      appBar: CustomAppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              maxRadius: 15,
              child: friendID.trim() == '' && friendList != []
                  ? checkGroupAvatar(avatar: chatAvatar, size: 20)
                  : checkPersonAvatar(avatar: chatAvatar, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: qText(
                chatName,
                overflow: TextOverflow.ellipsis,
                align: TextAlign.start,
              ),
            ),
          ],
        ),
        actions: [
          if (friendID.trim() == '' && friendList != [])
            IconButton(
              onPressed: () {
                goRemoveUntilScreen(context, screen: const HomeScreen());
                goNextScreen(
                  context,
                  screen: SelectedFriendsScreen(friendStartList: friendList),
                );
              },
              icon: const Icon(Icons.person_add),
            )
          else
            IconButton(
              onPressed: () => goNextScreen(
                context,
                screen: DetailUserScreen(
                  userEmail: userEmail,
                  userID: friendID,
                  userAvatar: chatAvatar,
                  userName: chatName,
                ),
              ),
              icon: const Icon(Icons.info_outline, color: Colors.black),
            ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => goRemoveUntilScreen(
            context,
            screen: const HomeScreen(),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: _buildSendBar(messageController, context),
      body: SafeArea(child: Container()),
    );
  }

  _buildSendBar(messageController, context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.image, color: Colors.blue),
          ),
          Expanded(
            child: CustomTextForm(
              hintText: 'Send Message',
              controller: messageController,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              autofocus: true,
            ),
          ),
          IconButton(
            onPressed: () {
              String message = messageController.text;
              if (message.isNotEmpty && message.trim() != '') {
                if (friendID.trim() == '' && friendList != []) {
                  ChatServices().createGroupChat(
                    friendIDs: friendList,
                    firstMessage: message,
                    chatName: chatName,
                    context: context,
                  );
                } else {
                  ChatServices().createDuoChat(
                    chatName: chatName,
                    firstMessage: message,
                    friendID: friendID,
                    context: context,
                  );
                }
                messageController.clear();
              }
            },
            icon: const Icon(Icons.send, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
