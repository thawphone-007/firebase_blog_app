import 'package:firebase_blog_app_lesson/data/google_sing_in.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Login To Blog App",
              style: TextTheme.of(context).headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Image.network(
              "https://img.icons8.com/color/1200/firebase.jpg",
              width: 200,
              height: 200,
            ),
            SizedBox(height: 24),
            SignInButton(
              onPressed: () {
                signInWithGoogle();
              },
              Buttons.google,
            ),
          ],
        ),
      ),
    );
  }
}
