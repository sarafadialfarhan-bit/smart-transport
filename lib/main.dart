import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen.dart';

void main() async {


  Future<void> createAdminAccount() async {
    try {
      // 1. إنشاء الحساب في Firebase Auth
      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "Admin@Admin.com",
        password: "adminadmin",
      );

      // 2. إعداد بيانات الأدمن في Firestore
      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'name': 'System Admin',
        'email': 'Admin@Admin.com',
        'role': 'admin', // هذا الحقل هو المسؤول عن صلاحيات الأدمن
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("تم إنشاء حساب الأدمن بنجاح!");
    } catch (e) {
      print("خطأ أثناء إنشاء الحساب: $e");
    }
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  createAdminAccount();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child:  SmartTransportApp(),
    ),
  );
}

class SmartTransportApp extends StatelessWidget {
  const SmartTransportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'app_title'.tr(),
      theme: ThemeData(
        fontFamily: 'Cairo',
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
      ),
      home: WelcomeScreen(),
    );
  }
}
