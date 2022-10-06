import 'package:flutter/material.dart';
import 'package:project_chatapp/constants/firebase_paths.dart';
import 'package:project_chatapp/firebase/chat_services.dart';
import 'package:project_chatapp/firebase/firends_services.dart';
import 'package:project_chatapp/firebase/user_services.dart';
import 'package:project_chatapp/helpers/quick_functions.dart';
import 'package:project_chatapp/helpers/quick_navigators.dart';
import 'package:project_chatapp/helpers/quick_pannels.dart';
import 'package:project_chatapp/screens/chats/general_group_screen.dart';
import 'package:project_chatapp/widgets/custom_appbar.dart';
import 'package:project_chatapp/widgets/custom_container.dart';
import 'package:project_chatapp/widgets/quick_text.dart';

class DetailUserScreen extends StatelessWidget {
  const DetailUserScreen({
    super.key,
    required this.userID,
    this.chatID = '',
    required this.userAvatar,
    required this.userEmail,
    required this.userName,
  });

  final String userID;
  final String chatID;
  final String userName;
  final String userAvatar;
  final String userEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: const qText('User Detail')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Spacer(),
                CircleAvatar(
                  radius: 50,
                  child: checkPersonAvatar(
                    avatar: userAvatar,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                qText(
                  userName,
                  size: 30,
                  weight: FontWeight.bold,
                ),
                qText(
                  userEmail,
                  size: 18,
                  weight: FontWeight.w500,
                ),
                const Spacer(),
                Wrap(
                  children: [
                    _buildCategory(
                      context: context,
                      icon: Icons.chat,
                      content: 'Chats',
                      color: Colors.blue,
                      onTap: () => ChatServices().checkDuoChat(
                        friendID: userID,
                        friendName: userName,
                        friendAvatar: userAvatar,
                        friendEmail: userEmail,
                        context: context,
                      ),
                    ),
                    _buildCategory(
                      context: context,
                      icon: Icons.groups,
                      content: 'General Groups',
                      color: Colors.green,
                      onTap: () => goNextScreen(context,
                          screen: GeneralGroupScreen(userID: userID)),
                    ),
                    _buildCategory(
                      context: context,
                      icon: Icons.notifications_active,
                      content: 'Notifications',
                      color: Colors.grey,
                      onTap: () {},
                    ),
                    StreamBuilder(
                      stream: userCollection.doc(currentUID).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data == null) {
                          return const SizedBox();
                        } else {
                          String friendStatus = '';
                          List friends = snapshot.data![FirebasePaths.friends];
                          List sends =
                              snapshot.data![FirebasePaths.requestSend];
                          List received =
                              snapshot.data![FirebasePaths.requestReceived];
                          friendStatus = friends.contains(userID)
                              ? FirebasePaths.friends
                              : sends.contains(userID)
                                  ? FirebasePaths.requestSend
                                  : received.contains(userID)
                                      ? FirebasePaths.requestReceived
                                      : '';
                          return _buildCategory(
                              context: context,
                              icon: friendStatus == FirebasePaths.friends
                                  ? Icons.person_off
                                  : friendStatus == FirebasePaths.requestSend
                                      ? Icons.person_add_disabled
                                      : friendStatus ==
                                              FirebasePaths.requestReceived
                                          ? Icons.person
                                          : Icons.person_add,
                              content: friendStatus == FirebasePaths.friends
                                  ? 'Delete Friend'
                                  : friendStatus == FirebasePaths.requestSend
                                      ? "Cancel Friend Request"
                                      : friendStatus ==
                                              FirebasePaths.requestReceived
                                          ? "Answer Friend Request"
                                          : "Add Friend",
                              color: friendStatus == FirebasePaths.friends
                                  ? Colors.red
                                  : friendStatus == FirebasePaths.requestSend
                                      ? Colors.orange
                                      : friendStatus ==
                                              FirebasePaths.requestReceived
                                          ? Colors.yellow
                                          : Colors.lime,
                              onTap: () {
                                if (friendStatus == FirebasePaths.friends) {
                                  FriendsServices()
                                      .deletedFriend(friendID: userID);
                                } else if (friendStatus ==
                                    FirebasePaths.requestSend) {
                                  FriendsServices()
                                      .cancelRequest(friendID: userID);
                                } else if (friendStatus ==
                                    FirebasePaths.requestReceived) {
                                  showAlert(
                                      context: context,
                                      title: "Answer this Friend Request",
                                      onAgreed: () {
                                        FriendsServices()
                                            .acceptedRequest(friendID: userID);
                                        goPop(context);
                                      },
                                      onRefused: () {
                                        FriendsServices()
                                            .refusedRequest(friendID: userID);
                                        goPop(context);
                                      },
                                      agreeColor: Colors.green,
                                      agreeText: 'Agree',
                                      refuseColor: Colors.red,
                                      refuseText: 'Refuse');
                                } else {
                                  FriendsServices()
                                      .sendRequest(friendID: userID);
                                }
                              });
                        }
                      },
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildCategory({
    required IconData icon,
    required String content,
    required Color color,
    required Function()? onTap,
    required BuildContext context,
  }) =>
      Padding(
        padding: const EdgeInsets.all(5),
        child: GestureDetector(
          onTap: onTap,
          child: CustomContainer(
            borderShadow: true,
            color: color,
            width: screenWidth(context) / 2 - 20,
            child: AspectRatio(
              aspectRatio: 0.85,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 50,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  qText(
                    content,
                    size: 20,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ),
        ),
      );
}
