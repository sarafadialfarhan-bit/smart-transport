import 'package:flutter/material.dart';

// الألوان الأساسية لتطبيق النقل
const kPrimaryColor = Color(0xFF455A64);
const kSecondaryColor = Color(0xFF263238);
const kBackgroundColor = Color(0xFFF5F5F5);
const kWhiteColor = Colors.white;
const kGreyColor = Colors.grey;
const kGreenColor = Colors.green;

// ألوان متوافقة مع واجهات الدخول القديمة لمنع الأخطاء
const kMainColor = kPrimaryColor;
const kDarkColor2 = kSecondaryColor;

const kLightGradient = LinearGradient(
  colors: [Color(0xFF607D8B), Color(0xFF455A64)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kDarkGradient = LinearGradient(
  colors: [Color(0xFF263238), Color(0xFF37474F)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
