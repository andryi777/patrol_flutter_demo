import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../test_main.dart';

void main() {
  patrolTest(
    'login screen muestra campos de email y password',
    ($) async {
      await testMain();
      await $.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    },
    tags: ['smoke'],
  );
}
