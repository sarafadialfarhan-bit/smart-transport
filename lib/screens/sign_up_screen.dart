import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import '../components/custom_button.dart';
import '../components/custom_text_form_field.dart';
import '../components/background_decoration.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'admin_panel_screen.dart';
import 'company_panel_screen.dart';
import 'search_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("auth_error_password_mismatch".tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? error = await _authService.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );

    if (error == null) {
      final user = _authService.currentUser;
      if (user != null) {
        final role = await UserService().getUserRole(user.uid);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("signup_success".tr()),
              backgroundColor: Colors.green,
            ),
          );
          
          if (role == 'admin') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
              (route) => false,
            );
          } else if (role == 'company') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const CompanyPanelScreen()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
              (route) => false,
            );
          }
        }
      } else {
         if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

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
                    'assets/images/icon.png',
                    height: 100,
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
                  controller: _nameController,
                  title: "full_name".tr(),
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 15),
                CustomTextFormField(
                  controller: _emailController,
                  title: "email".tr(),
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                CustomTextFormField(
                  controller: _passwordController,
                  title: "password".tr(),
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 15),
                CustomTextFormField(
                  controller: _confirmPasswordController,
                  title: "confirm_password".tr(),
                  icon: Icons.lock_clock_outlined,
                  isPassword: true,
                ),
                const SizedBox(height: 30),
                Hero(
                  tag: 'signUp',
                  child: CustomButton(
                    title: "sign_up".tr(),
                    onPressed: _signUp,
                    isLoading: _isLoading,
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
