import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_chatapp/constants/firebase_paths.dart';
import 'package:project_chatapp/firebase/auth_services.dart';
import 'package:project_chatapp/firebase/user_services.dart';
import 'package:project_chatapp/helpers/form_validators.dart';
import 'package:project_chatapp/helpers/quick_navigators.dart';
import 'package:project_chatapp/helpers/quick_pannels.dart';
import 'package:project_chatapp/screens/auth/register_screen.dart';
import 'package:project_chatapp/screens/chats/home_screen.dart';
import 'package:project_chatapp/widgets/custom_roundbutton.dart';
import 'package:project_chatapp/widgets/custom_textform.dart';
import 'package:project_chatapp/widgets/quick_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  String name = '';
  String userEmail = '';
  String password = '';
  bool _isLoading = false;

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        _buildHeader(),
                        const Spacer(flex: 1),
                        _buildInput(context),
                        const Spacer(flex: 2),
                        _buildButton(context),
                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  _buildButton(context) {
    return Column(
      children: [
        CustomRoundButton(
          onPressed: () => _login(),
          buttonColor: Colors.blue,
          child: const qText('Login'),
        ),
        CustomRoundButton(
          onPressed: () => _login(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.g_mobiledata),
              qText('Login With Google'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => goNextScreen(context, screen: const RegisterScreen()),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              qText(
                'Don\'t have an Account?',
                color: Colors.white,
              ),
              SizedBox(width: 5),
              qText(
                'Register',
                color: Colors.blue,
              ),
            ],
          ),
        )
      ],
    );
  }

  _buildInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CustomTextForm(
          hintText: 'Email',
          prefixIcon: const Icon(Icons.email),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => setState(() => userEmail = value),
          validator: FormValidators.emailValidator,
        ),
        CustomTextForm(
          hintText: 'Password',
          prefixIcon: const Icon(Icons.lock),
          obscureText: true,
          onChanged: (value) => setState(() => password = value),
          validator: FormValidators.passwordValidator,
        ),
        InkWell(
          onTap: () {},
          child: qText('Forgot Password?', color: Colors.grey[600]),
        ),
      ],
    );
  }

  _buildHeader() {
    return Column(
      children: [
        const qText(
          'Welcome Back!',
          color: Colors.white,
          size: 28,
        ),
        qText(
          'Please login to your account',
          color: Colors.grey[600],
        ),
      ],
    );
  }

  _login() async {
    if (formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await authService
          .emailLogin(email: userEmail, password: password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await UserService().checkUser(email: userEmail);
          String userName = snapshot.docs[0][FirebasePaths.name];
          authService.saveToSF(email: userEmail, name: userName);
          if (mounted) {
            goReplaceScreen(context, screen: const HomeScreen());
          }
        } else {
          showSnackBar(value, context, color: Colors.red);
          setState(() => _isLoading = false);
        }
      });
    }
  }
}
