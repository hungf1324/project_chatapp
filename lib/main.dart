import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_chatapp/helpers/shared_preferences_functions.dart';
import 'package:project_chatapp/screens/auth/login_screen.dart';
import 'package:project_chatapp/screens/chats/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getUserSignInStatus());
  }

  getUserSignInStatus() async {
    await SFFunction.getUserSignInStatus().then((value) {
      if (value != null) _isSignIn = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      home: _isSignIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
