import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../components/background_decoration.dart';
import '../components/custom_text_form_field.dart';
import '../components/custom_button.dart';
import '../constants.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundDecoration(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Hero(
                tag: 'logo',
                child: Icon(
                  Icons.lock_reset_rounded,
                  size: 90,
                  color: kWhiteColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "forgot_password_title".tr(),
                style: const TextStyle(
                  color: kWhiteColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              CustomTextFormField(
                title: "email".tr(),
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 25),
              CustomButton(
                title: "send".tr(),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "back".tr(),
                  style: const TextStyle(color: kWhiteColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
