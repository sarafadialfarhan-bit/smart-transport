import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/log_in_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/admin_panel_screen.dart';
import 'screens/company_panel_screen.dart';
import 'screens/search_screen.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: const SmartTransportApp(),
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return FutureBuilder<String?>(
              future: UserService().getUserRole(snapshot.data!.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final role = roleSnapshot.data;
                if (role == 'admin') {
                  return const AdminPanelScreen();
                } else if (role == 'company') {
                  return const CompanyPanelScreen();
                } else if (role == 'supervisor') {
                  return const SearchScreen(); // Placeholder or Supervisor screen
                } else {
                  return const SearchScreen();
                }
              },
            );
          }

          return const WelcomeScreen();
        },
      ),
      routes: {
        '/login': (context) => const LogInScreen(),
        '/welcome': (context) => const WelcomeScreen(),
      },
    );
  }
}
