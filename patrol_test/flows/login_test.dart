import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/login_helper.dart';
import '../test_main.dart';

void main() {
  patrolTest(
    'login screen muestra campos de email y password',
    ($) async {
      await testMain();

      // Esperar a que aparezca la pantalla de login
      await $.waitUntilVisible(find.text('Login'));

      expect(find.text('Login'), findsWidgets);
      expect(find.byType(TextFormField), findsWidgets);
    },
    tags: ['smoke'],
  );

  patrolTest(
    'usuario puede hacer login exitosamente',
    ($) async {
      await performLogin($);
      // performLogin ya espera el BottomNavigationBar
      // Verificar que estamos en Home
      expect(find.text('Home'), findsWidgets);
    },
    tags: ['smoke', 'login'],
  );
}
