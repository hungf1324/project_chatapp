import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_chatapp/constants/firebase_paths.dart';
import 'package:project_chatapp/firebase/user_services.dart';
import 'package:project_chatapp/helpers/quick_navigators.dart';
import 'package:project_chatapp/screens/chats/home_screen.dart';
import 'package:project_chatapp/firebase/chat_services.dart';
import 'package:project_chatapp/widgets/custom_appbar.dart';
import 'package:project_chatapp/widgets/custom_textform.dart';
import 'package:project_chatapp/widgets/quick_text.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    required this.chatID,
    required this.chatName,
    required this.chatAvatar,
  });

  final String chatID;
  final String chatName;
  final Widget? chatAvatar;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  Stream<QuerySnapshot>? messages;
  TextEditingController messageController = TextEditingController();

  getChatData() async {
    ChatServices()
        .getChatMessages(chatID: widget.chatID)
        .then((val) => setState(() => messages = val));
  }

  markAsSeen() {
    chatCollection.doc(widget.chatID).update({
      FirebasePaths.seen: FieldValue.arrayUnion([currentUID]),
    });
  }

  @override
  void initState() {
    super.initState();
    getChatData();
    markAsSeen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              maxRadius: 15,
              child: widget.chatAvatar,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: qText(
                widget.chatName,
                overflow: TextOverflow.ellipsis,
                align: TextAlign.start,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => ChatServices().showChatDetail(
              chatID: widget.chatID,
              context: context,
            ),
            icon: const Icon(Icons.info_outline),
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
      bottomNavigationBar: _buildSendBar(),
      body: SafeArea(child: _buildChat()),
    );
  }

  _buildSendBar() {
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
              if (messageController.text.isNotEmpty) {
                ChatServices().sendMessage(
                  id: widget.chatID,
                  content: messageController.text,
                );
                setState(() {
                  messageController.clear();
                });
              }
            },
            icon: const Icon(Icons.send, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  _buildChat() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: StreamBuilder(
        stream: messages,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                String senderID =
                    snapshot.data.docs[index][FirebasePaths.sender];
                var content = snapshot.data.docs[index][FirebasePaths.content];
                if (currentUID == senderID) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 30),
                      _buildMessage(
                        message: content,
                        textColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      const SizedBox(width: 5),
                      CircleAvatar(
                        maxRadius: 20,
                        child: StreamBuilder(
                          stream: userCollection.doc(senderID).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data != null &&
                                snapshot.data![FirebasePaths.avatar] != '') {
                              return snapshot.data![FirebasePaths.avatar];
                            } else {
                              return const Icon(Icons.person);
                            }
                          },
                        ),
                      ),
                      _buildMessage(
                        message: content,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 30),
                    ],
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  _buildMessage({
    required String message,
    Color? textColor,
    Color? backgroundColor,
  }) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            color: backgroundColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: qText(
              message,
              color: textColor,
              align: TextAlign.start,
            ),
          ),
        ),
      ),
    );
  }
}
