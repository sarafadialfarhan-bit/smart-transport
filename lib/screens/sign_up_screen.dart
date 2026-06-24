import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import '../components/custom_button.dart';
import '../components/custom_text_form_field.dart';
import '../components/background_decoration.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundDecoration(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    "assets/images/logo.png",
                    height: 120,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "sign_up".tr(),
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "join_us".tr(),
                  style: const TextStyle(color: kGreyColor, fontSize: 16),
                ),
                const SizedBox(height: 40),
                CustomTextFormField(
                  title: "full_name".tr(),
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 15),
                CustomTextFormField(
                  title: "email".tr(),
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                CustomTextFormField(
                  title: "password".tr(),
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 15),
                CustomTextFormField(
                  title: "confirm_password".tr(),
                  icon: Icons.lock_clock_outlined,
                  isPassword: true,
                ),
                const SizedBox(height: 30),
                Hero(
                  tag: 'signUp',
                  child: CustomButton(
                    title: "sign_up".tr(),
                    onPressed: () {
                      // منطق إنشاء الحساب
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("already_have_account".tr()),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "login".tr(),
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
