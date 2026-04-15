import 'package:chat_app/constants.dart';
import 'package:flutter/material.dart';

import 'custom_text_form_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LogInScreen());
  }
}

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.width * 0.55,
                width: MediaQuery.of(context).size.width * 0.55,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      spreadRadius: 4,
                      blurRadius: 2,
                    ),
                  ],
                  gradient: kDarkGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(360),
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.width * 0.75,
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    spreadRadius: 5,
                    blurRadius: 5,
                  ),
                ],
                gradient: kLightGradient,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(360),
                ),
              ),
            ),
            Positioned(
              left: 50,
              bottom: 120,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      spreadRadius: 4,
                      blurRadius: 2,
                    ),
                  ],
                  gradient: kDarkGradient,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 75,
              bottom: 240,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      spreadRadius: 4,
                      blurRadius: 2,
                    ),
                  ],
                  gradient: kLightGradient,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Log In",
                      style: TextStyle(color: kMainColor, fontSize: 40),
                    ),
                    SizedBox(height: 16),
                    CustomTextFormField(title: "Email"),
                    SizedBox(height: 8),
                    CustomTextFormField(title: "Password"),
                    SizedBox(height: 8),
                    Container(
                      width: 200,
                      decoration: BoxDecoration(
                          
                          borderRadius: BorderRadius.circular(60),
                          gradient: kLightGradient),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                        height: 65,
                          onPressed: () {},
                          child:
                       Text(
                        "Log In",
                        style: TextStyle(fontSize: 28.0, color: Colors.white),
                      ),
                    ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
