import 'package:flutter/material.dart';
import 'package:project_chatapp/constants/firebase_paths.dart';
import 'package:project_chatapp/firebase/chat_services.dart';
import 'package:project_chatapp/firebase/user_services.dart';
import 'package:project_chatapp/helpers/quick_functions.dart';
import 'package:project_chatapp/helpers/quick_navigators.dart';
import 'package:project_chatapp/helpers/quick_pannels.dart';
import 'package:project_chatapp/screens/chats/messages_screen.dart';
import 'package:project_chatapp/screens/chats/home_screen.dart';
import 'package:project_chatapp/screens/chats/selected_friends_screen.dart';
import 'package:project_chatapp/screens/users/detail_user_screen.dart';
import 'package:project_chatapp/widgets/custom_appbar.dart';
import 'package:project_chatapp/widgets/custom_container.dart';
import 'package:project_chatapp/widgets/custom_roundbutton.dart';
import 'package:project_chatapp/widgets/custom_textform.dart';
import 'package:project_chatapp/widgets/quick_text.dart';

class DetailChatScreen extends StatefulWidget {
  const DetailChatScreen({
    super.key,
    required this.chatID,
    required this.adminID,
    required this.chatName,
    required this.chatAvatar,
    this.chatMembers,
  });

  final String chatID;
  final String adminID;
  final String chatName;
  final String chatAvatar;
  final List<String>? chatMembers;

  @override
  State<DetailChatScreen> createState() => _DetailChatScreenState();
}

class _DetailChatScreenState extends State<DetailChatScreen> {
  String newChatName = '';
  List<String> memberList = [];

  @override
  Widget build(BuildContext context) {
    TextEditingController newChatNameController =
        TextEditingController(text: widget.chatName)
          ..selection = TextSelection.collapsed(offset: widget.chatName.length);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: CustomTextForm(
          borderWidth: 0,
          borderColor: Colors.transparent,
          borderErrorColor: Colors.transparent,
          borderFocusedColor: Colors.transparent,
          fillColor: Colors.transparent,
          searchColor: Colors.black,
          controller: newChatNameController,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () {
              String chatName = widget.chatName;
              newChatName = newChatNameController.text;
              if (newChatName.isNotEmpty && newChatName.trim() != '') {
                chatServices.changeChatName(
                  chatID: widget.chatID,
                  newChatName: newChatName,
                );
                chatName = newChatName;
              }
              goRemoveUntilScreen(context, screen: const HomeScreen());
              goNextScreen(
                context,
                screen: MessagesScreen(
                  chatID: widget.chatID,
                  chatName: chatName,
                  chatAvatar:
                      checkGroupAvatar(avatar: widget.chatAvatar, size: 20),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: CustomRoundButton(
          onPressed: () => showAlert(
            title: 'Delete this chat?',
            content: const qText('This action can\'t be reverse!'),
            agreeColor: Colors.red,
            onAgreed: () {
              goRemoveUntilScreen(context, screen: const HomeScreen());
              Future.delayed(
                const Duration(microseconds: 0),
                () => ChatServices().deletedChat(chatID: widget.chatID),
              );
            },
            context: context,
          ),
          buttonColor: Colors.red,
          child: const qText('Deleted group chat', color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.all(10),
                child: CircleAvatar(
                  radius: 50,
                  child: checkGroupAvatar(avatar: widget.chatAvatar, size: 60),
                ),
              ),
              const Spacer(flex: 3),
              _buildAdmin(),
              const Spacer(flex: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const qText('Member List', weight: FontWeight.w600, size: 14),
                  IconButton(
                    onPressed: () => goNextScreen(
                      context,
                      screen: SelectedFriendsScreen(
                        chatAvatar: checkGroupAvatar(
                          avatar: widget.chatAvatar,
                          size: 20,
                        ),
                        chatName: widget.chatName,
                        chatID: widget.chatID,
                        friendStartList: memberList,
                      ),
                    ),
                    icon: const Icon(Icons.person_search_sharp),
                  )
                ],
              ),
              SizedBox(
                height: screenHeight(context) / 3,
                child: _buildMembers(),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  _buildMembers() {
    return StreamBuilder(
      stream: chatCollection.doc(widget.chatID).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data![FirebasePaths.members] == null ||
            snapshot.data![FirebasePaths.members].length <= 1) {
          return const SizedBox();
        } else {
          return ListView.builder(
            itemCount: snapshot.data![FirebasePaths.members].length,
            itemBuilder: (context, index) {
              String memberID = snapshot.data![FirebasePaths.members][index];
              return StreamBuilder(
                stream: userCollection.doc(memberID).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null ||
                      memberID == widget.adminID) {
                    return const SizedBox();
                  } else {
                    String memberName = snapshot.data![FirebasePaths.name];
                    String memberAvatar = snapshot.data![FirebasePaths.avatar];
                    String memberEmail = snapshot.data![FirebasePaths.email];
                    String id = snapshot.data![FirebasePaths.id];
                    if (memberList.contains(id) == false) {
                      memberList.add(id);
                    }
                    return _buildUserTile(
                      context,
                      avatar: memberAvatar,
                      name: memberName,
                      role: "Member",
                      memberID: memberID,
                      email: memberEmail,
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  _buildAdmin() {
    return StreamBuilder(
      stream: userCollection.doc(widget.adminID).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const SizedBox();
        } else {
          String adminAvatar = snapshot.data![FirebasePaths.avatar];
          String adminName = snapshot.data![FirebasePaths.name];
          String adminEmail = snapshot.data![FirebasePaths.email];
          return _buildUserTile(
            context,
            avatar: adminAvatar,
            name: adminName,
            role: "Admin",
            memberID: widget.adminID,
            email: adminEmail,
          );
        }
      },
    );
  }

  _buildUserTile(
    context, {
    required String avatar,
    required String name,
    required String role,
    required String memberID,
    required String email,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: CustomContainer(
        color: role == 'Admin' ? Colors.red : Colors.green,
        child: ListTile(
          onTap: () => goNextScreen(context,
              screen: DetailUserScreen(
                userID: memberID,
                userAvatar: avatar,
                userEmail: email,
                userName: name,
              )),
          leading: CircleAvatar(
            child: checkPersonAvatar(avatar: avatar, size: 25),
          ),
          title: qText(
            name,
            color: role == 'Admin' ? Colors.white : null,
            align: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              qText(
                role,
                color: role == 'Admin' ? Colors.white : null,
              ),
              if (currentUID == widget.adminID) const SizedBox(width: 10),
              if (currentUID == widget.adminID)
                IconButton(
                  onPressed: () => showAlert(
                    context: context,
                    title: 'Kick $name?',
                    agreeColor: Colors.red,
                    onAgreed: () {
                      ChatServices().kickMember(
                        chatID: widget.chatID,
                        userID: memberID,
                      );
                      goPop(context);
                    },
                  ),
                  icon: const Icon(Icons.close, color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
