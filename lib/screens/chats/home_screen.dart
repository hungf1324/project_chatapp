import 'package:flutter/material.dart';
import 'package:project_chatapp/constants/firebase_paths.dart';
import 'package:project_chatapp/firebase/user_services.dart';
import 'package:project_chatapp/helpers/quick_functions.dart';
import 'package:project_chatapp/helpers/quick_navigators.dart';
import 'package:project_chatapp/screens/chats/messages_screen.dart';
import 'package:project_chatapp/screens/users/menu_screen.dart';
import 'package:project_chatapp/screens/chats/selected_friends_screen.dart';
import 'package:project_chatapp/firebase/chat_services.dart';
import 'package:project_chatapp/screens/chats/search_chat_screen.dart';
import 'package:project_chatapp/widgets/custom_appbar.dart';
import 'package:project_chatapp/widgets/quick_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream? chats;
  String? name = '';
  String avatar = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getUserData());
  }

  getUserData() {
    UserService()
        .getUserName(id: currentUID)
        .then((value) => setState(() => name = value));
    UserService()
        .getUserAvatar(id: currentUID)
        .then((val) => setState(() => avatar = val));
    UserService()
        .getUserEmail(id: currentUID)
        .then((val) => setState(() => email = val));
    ChatServices()
        .getChatSnapshots()
        .then((snapshot) => setState(() => chats = snapshot));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => goNextScreen(
            context,
            screen: MenuScreen(
              avatar: avatar,
              email: email,
              name: name!,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                maxRadius: 15,
                child: checkPersonAvatar(avatar: avatar),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: qText(
                  name!,
                  overflow: TextOverflow.ellipsis,
                  align: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => goNextScreen(
              context,
              screen: const SearchChatScreen(),
            ),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () =>
                goNextScreen(context, screen: const SelectedFriendsScreen()),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: chats,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return qText(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data.docs.length == 0) {
              return _buildNoChats();
            } else {
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  String chatID = snapshot.data.docs[index][FirebasePaths.id];
                  String lastSenderID =
                      snapshot.data.docs[index][FirebasePaths.lastSender];
                  String lastMessage =
                      snapshot.data.docs[index][FirebasePaths.lastMessage];
                  String chatType =
                      snapshot.data.docs[index][FirebasePaths.type];
                  String chatName =
                      snapshot.data.docs[index][FirebasePaths.name];
                  String chatAvatar =
                      snapshot.data.docs[index][FirebasePaths.avatar];
                  String creatorID =
                      snapshot.data.docs[index][FirebasePaths.admin];
                  String lastTime = timeBetween(
                      from: DateTime.fromMillisecondsSinceEpoch(
                        snapshot.data.docs[index][FirebasePaths.lastTime],
                      ),
                      to: DateTime.now());
                  List<dynamic> seenList =
                      snapshot.data.docs[index][FirebasePaths.seen];
                  bool hasSeen = seenList.contains(currentUID);
                  return StreamBuilder(
                    stream: userCollection.doc(lastSenderID).snapshots(),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return qText(snap.error.toString());
                      } else if (!snap.hasData) {
                        return const qText('Unknown User');
                      } else {
                        String lastSender = lastSenderID == currentUID
                            ? 'You'
                            : snap.data![FirebasePaths.name];
                        return chatType == "Group"
                            ? _buildGroupChat(
                                chatID: chatID,
                                chatName: chatName,
                                chatAvatar: chatAvatar,
                                lastMessage: lastMessage,
                                lastSender: lastSender,
                                lastTime: lastTime,
                                hasSeen: hasSeen,
                              )
                            : _buildDuoChat(
                                chatID: chatID,
                                friendID: chatName == currentUID
                                    ? creatorID
                                    : chatName,
                                lastMessage: lastMessage,
                                lastSender: lastSender,
                                lastTime: lastTime,
                                hasSeen: hasSeen,
                              );
                      }
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  _buildDuoChat({
    required String chatID,
    required String friendID,
    required String lastSender,
    required String lastMessage,
    required String lastTime,
    required bool hasSeen,
  }) {
    return StreamBuilder(
      stream: userCollection.doc(friendID).snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return qText(snap.error.toString());
        } else if (!snap.hasData) {
          return const qText('Unknown User');
        } else {
          String friendName = snap.data![FirebasePaths.name];
          String? chatAvatar = snap.data![FirebasePaths.avatar];
          return _buildChatTile(
            chatID: chatID,
            lastSender: lastSender,
            lastMessage: lastMessage,
            lastTime: lastTime,
            chatTitle: friendName,
            avatar: checkPersonAvatar(avatar: chatAvatar!, size: 20),
            hasSeen: hasSeen,
          );
        }
      },
    );
  }

  _buildGroupChat({
    required String chatID,
    required String chatName,
    required String lastSender,
    required String lastMessage,
    required String? chatAvatar,
    required String lastTime,
    required bool hasSeen,
  }) {
    return _buildChatTile(
      chatID: chatID,
      chatTitle: chatName,
      lastSender: lastSender,
      lastMessage: lastMessage,
      avatar: checkGroupAvatar(avatar: chatAvatar!, size: 20),
      lastTime: lastTime,
      hasSeen: hasSeen,
    );
  }

  _buildChatTile({
    required String chatID,
    required String chatTitle,
    required String lastSender,
    required String lastMessage,
    required String lastTime,
    required Widget? avatar,
    required bool hasSeen,
  }) {
    return ListTile(
      leading: CircleAvatar(maxRadius: 20, child: avatar),
      title: qText(
        chatTitle,
        overflow: TextOverflow.ellipsis,
        align: TextAlign.start,
        weight: hasSeen == true ? null : FontWeight.bold,
      ),
      subtitle: Row(
        children: [
          qText(
            '$lastSender : ',
            overflow: TextOverflow.ellipsis,
            weight: hasSeen == true ? null : FontWeight.bold,
            color: hasSeen == true ? null : Colors.black87,
          ),
          qText(
            lastMessage,
            overflow: TextOverflow.clip,
            weight: hasSeen == true ? null : FontWeight.bold,
            color: hasSeen == true ? null : Colors.black87,
          ),
        ],
      ),
      trailing: qText(
        lastTime,
        weight: hasSeen == true ? null : FontWeight.bold,
      ),
      onTap: () => goNextScreen(
        screen: MessagesScreen(
          chatID: chatID,
          chatAvatar: avatar,
          chatName: chatTitle,
        ),
        context,
      ),
    );
  }

  _buildNoChats() => Center(
        child: SizedBox(
          height: screenHeight(context) * .768,
          child: const qText(
            "You've not joined any chat\nTap the icon to create one.",
            align: TextAlign.center,
          ),
        ),
      );
}
