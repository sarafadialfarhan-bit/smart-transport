import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_transport/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: In a real environment, we'd need to mock Firebase and EasyLocalization.
    // For now, we fix the class name reference to allow the project to compile.
    await tester.pumpWidget(const SmartTransportApp());

    // Verify that the app starts (it will likely show a loading indicator due to StreamBuilder/FutureBuilder)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
