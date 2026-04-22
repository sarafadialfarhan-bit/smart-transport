import 'package:chat_app/constants.dart';
import 'package:chat_app/custom_button.dart';
import 'package:flutter/material.dart';
import 'background_decoration.dart';
import 'image_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: WelcomeScreen());
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundDecoration(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 75,
              backgroundImage: AssetImage("assets/images/logo.png"),
            ),
            Text("Welcome to Our Chat App!",
            style: TextStyle(
              fontSize: 30,
              color: kMainColor
            ),
            ),
            SizedBox(height: 16,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(title: "Log In",),
                CustomButton(title: "Sign Up",)
              ],
            )
          ],
        ),
      ),
    );
  }
}
