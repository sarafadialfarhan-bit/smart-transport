import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkMode = false;

  void _showFeatureNotAvailable(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("feature_soon".tr(args: [feature.tr()])),
        backgroundColor: kPrimaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
        content: Text(content.tr()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("close".tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "settings".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kWhiteColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader("account".tr()),
          _buildSettingsItem(
            icon: Icons.person_outline,
            title: "edit_profile".tr(),
            onTap: () => _showFeatureNotAvailable("edit_profile"),
          ),
          _buildSettingsItem(
            icon: Icons.lock_outline,
            title: "change_password".tr(),
            onTap: () => _showFeatureNotAvailable("change_password"),
          ),
          _buildSettingsItem(
            icon: Icons.language,
            title: "language".tr(),
            trailing: Text(context.locale.languageCode == 'ar' ? "العربية" : "English", style: const TextStyle(color: kGreyColor)),
            onTap: () => _showLanguageDialog(),
          ),
          const SizedBox(height: 25),
          _buildSectionHeader("notifications_and_appearance".tr()),
          _buildSwitchItem(
            icon: Icons.notifications_none,
            title: "trip_notifications".tr(),
            value: notificationsEnabled,
            onChanged: (val) => setState(() => notificationsEnabled = val),
          ),
          _buildSwitchItem(
            icon: Icons.dark_mode_outlined,
            title: "dark_mode".tr(),
            value: darkMode,
            onChanged: (val) {
              setState(() => darkMode = val);
            },
          ),
          const SizedBox(height: 25),
          _buildSectionHeader("support_and_help".tr()),
          _buildSettingsItem(
            icon: Icons.help_outline,
            title: "help_center".tr(),
            onTap: () => _showInfoDialog("help_center", "help_content"),
          ),
          _buildSettingsItem(
            icon: Icons.info_outline,
            title: "about_app".tr(),
            onTap: () => _showInfoDialog("about_app", "about_content"),
          ),
          _buildSettingsItem(
            icon: Icons.policy_outlined,
            title: "privacy_policy".tr(),
            onTap: () => _showInfoDialog("privacy_policy", "privacy_content"),
          ),
          const SizedBox(height: 30),
          _buildLogoutButton(),
          const SizedBox(height: 40),
          Center(
            child: Text(
              "app_version".tr(),
              style: TextStyle(color: kGreyColor.withOpacity(0.6), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, right: 10, left: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: kPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: kPrimaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: kGreyColor),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: kPrimaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: kPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
      ),
      child: ListTile(
        onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
        leading: const Icon(Icons.logout, color: Colors.redAccent),
        title: Text(
          "logout".tr(),
          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("select_language".tr()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("العربية"),
              trailing: context.locale.languageCode == 'ar' ? const Icon(Icons.check, color: kPrimaryColor) : null,
              onTap: () {
                context.setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("English"),
              trailing: context.locale.languageCode == 'en' ? const Icon(Icons.check, color: kPrimaryColor) : null,
              onTap: () {
                context.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
