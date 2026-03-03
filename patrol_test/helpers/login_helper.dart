import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../test_main.dart';

/// Helper para realizar login en los tests
Future<void> performLogin(PatrolIntegrationTester $) async {
  await testMain();
  await Future.delayed(const Duration(seconds: 5));
  await $.pump(const Duration(seconds: 2));

  final textFields = find.byType(TextFormField);
  await $.tester.enterText(textFields.first, 'test@test.com');
  await $.pump(const Duration(milliseconds: 500));
  await $.tester.enterText(textFields.last, 'password123');
  await $.pump(const Duration(milliseconds: 500));

  final loginButton = find.byType(ElevatedButton);
  await $.tester.tap(loginButton);
  await $.pump(const Duration(seconds: 1));
  await Future.delayed(const Duration(seconds: 3));
  await $.pump(const Duration(seconds: 2));
}
