import 'package:flutter/material.dart';
import 'package:project_chatapp/firebase/auth_services.dart';
import 'package:project_chatapp/helpers/form_validators.dart';
import 'package:project_chatapp/helpers/quick_navigators.dart';
import 'package:project_chatapp/helpers/quick_pannels.dart';
import 'package:project_chatapp/screens/auth/login_screen.dart';
import 'package:project_chatapp/screens/chats/home_screen.dart';
import 'package:project_chatapp/widgets/custom_roundbutton.dart';
import 'package:project_chatapp/widgets/custom_textform.dart';
import 'package:project_chatapp/widgets/quick_text.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
                        _buildInput(),
                        const Spacer(flex: 2),
                        _buildButton(context),
                        const Spacer(flex: 2),
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
          onPressed: _register,
          buttonColor: Colors.blue,
          child: const qText('Register'),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => goReplaceScreen(context, screen: const LoginScreen()),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              qText(
                'Have an Account?',
                color: Colors.white,
              ),
              SizedBox(width: 5),
              qText(
                'Login',
                color: Colors.blue,
              ),
            ],
          ),
        )
      ],
    );
  }

  _buildInput() {
    return Column(
      children: [
        CustomTextForm(
          hintText: 'Name',
          prefixIcon: const Icon(Icons.person),
          keyboardType: TextInputType.name,
          onChanged: (value) => setState(() => name = value),
          validator: FormValidators.requiredValidator,
        ),
        CustomTextForm(
          hintText: 'Email',
          prefixIcon: const Icon(Icons.email),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => setState(() => email = value),
          validator: FormValidators.emailValidator,
        ),
        CustomTextForm(
          hintText: 'Password',
          prefixIcon: const Icon(Icons.lock),
          obscureText: true,
          onChanged: (value) => setState(() => password = value),
          validator: FormValidators.passwordValidator,
        ),
      ],
    );
  }

  _buildHeader() {
    return Column(
      children: [
        const qText(
          'Create New Account!',
          color: Colors.white,
          size: 22,
        ),
        qText(
          'Please fill in the form to countine',
          color: Colors.grey[600],
        ),
      ],
    );
  }

  _register() async {
    if (formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await authService
          .emailRegister(name: name, email: email, password: password)
          .then((value) async {
        if (value == true) {
          authService.saveToSF(email: email, name: name);
          goRemoveUntilScreen(context, screen: const HomeScreen());
        } else {
          showSnackBar(value, context, color: Colors.red);
          setState(() => _isLoading = false);
        }
      });
    }
  }
}
