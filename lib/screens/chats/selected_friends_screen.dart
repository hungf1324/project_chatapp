import 'package:flutter/material.dart';
import 'package:project_chatapp/constants/firebase_paths.dart';
import 'package:project_chatapp/firebase/firends_services.dart';
import 'package:project_chatapp/firebase/user_services.dart';
import 'package:project_chatapp/firebase/chat_services.dart';
import 'package:project_chatapp/helpers/quick_functions.dart';
import 'package:project_chatapp/helpers/quick_navigators.dart';
import 'package:project_chatapp/screens/chats/messages_screen.dart';
import 'package:project_chatapp/screens/chats/home_screen.dart';
import 'package:project_chatapp/screens/chats/tempchat_screen.dart';
import 'package:project_chatapp/widgets/custom_appbar.dart';
import 'package:project_chatapp/widgets/custom_roundbutton.dart';
import 'package:project_chatapp/widgets/custom_textform.dart';
import 'package:project_chatapp/widgets/quick_text.dart';

class SelectedFriendsScreen extends StatefulWidget {
  const SelectedFriendsScreen({
    super.key,
    this.friendStartList,
    this.chatID = '',
    this.chatName,
    this.chatAvatar,
  });

  final List<String>? friendStartList;
  final String chatID;
  final String? chatName;
  final Widget? chatAvatar;

  @override
  State<SelectedFriendsScreen> createState() => _SelectedFriendsScreenState();
}

class _SelectedFriendsScreenState extends State<SelectedFriendsScreen> {
  List<String> friendsSelected = [];
  List<String>? searchList = [];
  searchFriend(String? text) {
    if (text != null && text.trim() != '') {
      FriendsServices()
          .searchFriends(searchCase: text)
          .then((value) => setState((() => searchList = value)));
    }
  }

  @override
  void initState() {
    if (widget.friendStartList != null && widget.friendStartList != []) {
      friendsSelected = widget.friendStartList!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: CustomTextForm(
          hintText: 'Friend List',
          borderWidth: 0,
          borderColor: Colors.transparent,
          borderErrorColor: Colors.transparent,
          borderFocusedColor: Colors.transparent,
          fillColor: Colors.transparent,
          searchColor: Colors.black,
          onChanged: (value) {
            setState(() => searchFriend(value));
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: CustomRoundButton(
          height: friendsSelected.length > 1 ? 70 : 0,
          buttonColor: widget.chatID.trim() == '' ? Colors.blue : Colors.green,
          onPressed: () {
            if (widget.chatID.trim() == '') {
              goReplaceScreen(
                context,
                screen: TempChatScreen(
                  chatName: 'Group chat with ${friendsSelected.length} friends',
                  chatAvatar: '',
                  friendList: friendsSelected,
                ),
              );
            } else {
              ChatServices().updateMember(
                chatID: widget.chatID,
                usersID: friendsSelected,
              );
              goRemoveUntilScreen(context, screen: const HomeScreen());
              goNextScreen(
                context,
                screen: MessagesScreen(
                  chatID: widget.chatID,
                  chatName: widget.chatName!,
                  chatAvatar: widget.chatAvatar,
                ),
              );
            }
          },
          child: qText(
            widget.chatID.trim() == ''
                ? 'Create new group chat'
                : 'Update Members',
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFriendSelected(),
                if (searchList != [] && searchList!.isNotEmpty)
                  _buildSearchFriend(),
                _buildFriendList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildSearchFriend() {
    return searchList!.isEmpty
        ? const SizedBox()
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: searchList!.length,
            itemBuilder: (context, index) {
              String friendID = searchList![index];
              return friendsSelected.contains(friendID)
                  ? const SizedBox()
                  : _buildFriend(friendID);
            },
          );
  }

  _buildFriendSelected() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: friendsSelected.length,
      itemBuilder: (context, index) {
        return _buildFriend(friendsSelected[index]);
      },
    );
  }

  _buildFriendList() {
    return StreamBuilder(
      stream: userCollection.doc(currentUID).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return qText(snapshot.error.toString());
        } else if (!snapshot.hasData ||
            snapshot.data![FirebasePaths.friends].length == 0) {
          return _buildNoFriend();
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data![FirebasePaths.friends].length,
            itemBuilder: (context, index) {
              String friendID = snapshot.data![FirebasePaths.friends][index];
              return friendsSelected.contains(friendID) ||
                      searchList!.contains(friendID)
                  ? const SizedBox()
                  : _buildFriend(friendID);
            },
          );
        }
      },
    );
  }

  _buildFriend(String friendID) {
    return StreamBuilder(
      stream: userCollection.doc(friendID).snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return qText(snap.error.toString());
        } else if (!snap.hasData) {
          return const qText('Unknown User');
        } else {
          String friendName = snap.data![FirebasePaths.name];
          String friendAvatar = snap.data![FirebasePaths.avatar];
          String friendEmail = snap.data![FirebasePaths.email];
          return _buildFriendTile(
            friendAvatar: friendAvatar,
            friendName: friendName,
            friendID: friendID,
            friendEmail: friendEmail,
          );
        }
      },
    );
  }

  _buildFriendTile({
    required String friendAvatar,
    required String friendName,
    required String friendID,
    required String friendEmail,
  }) {
    bool isSelected = friendsSelected.contains(friendID);
    return ListTile(
      leading: CircleAvatar(
        child: checkPersonAvatar(avatar: friendAvatar),
      ),
      title: qText(
        friendName,
        align: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: SizedBox(
        width: 20,
        child: isSelected ? const Icon(Icons.check, size: 26) : null,
      ),
      onTap: () => friendsSelected.isEmpty
          ? ChatServices().checkDuoChat(
              friendEmail: friendEmail,
              friendID: friendID,
              friendName: friendName,
              friendAvatar: friendAvatar,
              context: context,
            )
          : setState(
              () => isSelected
                  ? friendsSelected.remove(friendID)
                  : friendsSelected.add(friendID),
            ),
      onLongPress: () => setState(
        () => isSelected
            ? friendsSelected.remove(friendID)
            : friendsSelected.add(friendID),
      ),
    );
  }

  _buildNoFriend() => searchList!.isEmpty || searchList == []
      ? const Center(
          child: qText(
            "You're not have any friend\nGo add some one to chat.",
            align: TextAlign.center,
          ),
        )
      : const SizedBox();
}
