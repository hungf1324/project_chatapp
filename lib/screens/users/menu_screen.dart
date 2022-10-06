import 'package:flutter/material.dart';
import 'package:project_chatapp/firebase/auth_services.dart';
import 'package:project_chatapp/helpers/quick_functions.dart';
import 'package:project_chatapp/helpers/quick_navigators.dart';
import 'package:project_chatapp/helpers/quick_pannels.dart';
import 'package:project_chatapp/screens/auth/login_screen.dart';
import 'package:project_chatapp/screens/chats/home_screen.dart';
import 'package:project_chatapp/screens/users/explore_screen.dart';
import 'package:project_chatapp/screens/users/friends_screen.dart';
import 'package:project_chatapp/widgets/custom_container.dart';
import 'package:project_chatapp/widgets/quick_text.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({
    super.key,
    required this.name,
    required this.email,
    required this.avatar,
  });

  final String name;
  final String email;
  final String avatar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    avatar: avatar,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                qText(
                  name,
                  size: 30,
                  weight: FontWeight.bold,
                ),
                qText(
                  email,
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
                      onTap: () => goRemoveUntilScreen(
                        context,
                        screen: const HomeScreen(),
                      ),
                    ),
                    _buildCategory(
                      context: context,
                      icon: Icons.people,
                      content: 'Friends',
                      color: Colors.green,
                      onTap: () => goReplaceScreen(
                        context,
                        screen: const FriendsScreen(),
                      ),
                    ),
                    _buildCategory(
                      context: context,
                      icon: Icons.explore,
                      content: 'Explore',
                      color: Colors.grey,
                      onTap: () => goReplaceScreen(
                        context,
                        screen: const ExploreScreen(),
                      ),
                    ),
                    _buildCategory(
                      context: context,
                      icon: Icons.logout,
                      content: 'Logout',
                      color: Colors.red,
                      onTap: () => showAlert(
                        title: 'Log Out',
                        content: const qText(
                          'Are you sure you want to Log Out?',
                        ),
                        agreeColor: Colors.red,
                        refuseColor: Colors.green,
                        onAgreed: () {
                          authService.logOut();
                          goRemoveUntilScreen(
                            context,
                            screen: const LoginScreen(),
                          );
                        },
                        context: context,
                      ),
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
