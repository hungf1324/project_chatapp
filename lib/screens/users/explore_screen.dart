import 'package:flutter/material.dart';
import 'package:project_chatapp/constants/firebase_paths.dart';
import 'package:project_chatapp/firebase/user_services.dart';
import 'package:project_chatapp/helpers/quick_functions.dart';
import 'package:project_chatapp/helpers/quick_navigators.dart';
import 'package:project_chatapp/screens/users/detail_user_screen.dart';
import 'package:project_chatapp/widgets/custom_appbar.dart';
import 'package:project_chatapp/widgets/custom_textform.dart';
import 'package:project_chatapp/widgets/quick_text.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List searchList = [];
  List friendList = [];
  List sendList = [];
  List receivedList = [];

  searchUser(String? text) {
    if (text != null && text.trim() != '') {
      UserService()
          .searchUsers(searchCase: text)
          .then((value) => setState((() => searchList = value)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: CustomTextForm(
          hintText: 'User List',
          borderWidth: 0,
          borderColor: Colors.transparent,
          borderErrorColor: Colors.transparent,
          borderFocusedColor: Colors.transparent,
          fillColor: Colors.transparent,
          searchColor: Colors.black,
          onChanged: (value) {
            searchUser(value);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                searchList != [] && searchList.isNotEmpty
                    ? _buildSearch()
                    : const SizedBox(),
                _buildUserList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildUserList() {
    return StreamBuilder(
      stream: userCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              String userID = snapshot.data!.docs[index][FirebasePaths.id];
              return searchList.contains(userID) || userID == currentUID
                  ? const SizedBox()
                  : _buildUser(userID);
            },
          );
        }
      },
    );
  }

  _buildSearch() {
    searchList.isEmpty || searchList == []
        ? const SizedBox()
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: searchList.length,
            itemBuilder: (context, index) {
              String searchID = searchList[index];
              return searchID == currentUID
                  ? const SizedBox()
                  : _buildUser(searchID);
            },
          );
  }

  _buildUser(String userID) {
    return StreamBuilder(
      stream: userCollection.doc(userID).snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return qText(snap.error.toString());
        } else if (!snap.hasData) {
          return const qText('Unknown User');
        } else {
          String userName = snap.data![FirebasePaths.name];
          String userAvatar = snap.data![FirebasePaths.avatar];
          String userEmail = snap.data![FirebasePaths.email];
          return StreamBuilder(
            stream: userCollection.doc(currentUID).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError || !snapshot.hasData) {
                return qText(snapshot.error.toString());
              } else {
                List friendList = snapshot.data![FirebasePaths.friends];
                List requestSendList =
                    snapshot.data![FirebasePaths.requestSend];
                List requestReveciedList =
                    snapshot.data![FirebasePaths.requestReceived];
                String friendStatus = friendList.contains(userID)
                    ? FirebasePaths.friends
                    : requestSendList.contains(userID)
                        ? FirebasePaths.requestSend
                        : requestReveciedList.contains(userID)
                            ? FirebasePaths.requestReceived
                            : '';
                return _buildUserTile(
                  userAvatar: userAvatar,
                  userName: userName,
                  userID: userID,
                  userEmail: userEmail,
                  friendStatus: friendStatus,
                );
              }
            },
          );
        }
      },
    );
  }

  _buildUserTile({
    required String userAvatar,
    required String userName,
    required String userID,
    required String userEmail,
    required String friendStatus,
  }) {
    return ListTile(
      leading: CircleAvatar(
        child: checkPersonAvatar(avatar: userAvatar),
      ),
      title: qText(
        userName,
        align: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: qText(
        userEmail,
        align: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => goNextScreen(
        context,
        screen: DetailUserScreen(
          userID: userID,
          userAvatar: userAvatar,
          userEmail: userEmail,
          userName: userName,
        ),
      ),
      trailing: friendStatus == FirebasePaths.friends
          ? const Icon(Icons.person_rounded, color: Colors.blue)
          : friendStatus == FirebasePaths.requestSend
              ? const Icon(Icons.person_add, color: Colors.orange)
              : friendStatus == FirebasePaths.requestReceived
                  ? const Icon(Icons.person_add_alt_1, color: Colors.yellow)
                  : const Icon(Icons.person_rounded, color: Colors.grey),
    );
  }
}
