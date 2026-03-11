import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/login_helper.dart';

void main() {
  patrolTest(
    'navegar a biometrics desde settings',
    ($) async {
      await navigateToBiometrics($);

      expect(find.text('Biometric Status'), findsOneWidget);
      expect(find.text('Authenticate with Biometrics'), findsOneWidget);
    },
    tags: ['biometrics'],
  );

  patrolTest(
    'verificar disponibilidad de biometrics',
    ($) async {
      await navigateToBiometrics($);
      await waitForBiometricsStatus($);

      final available =
          find.text('Biometrics available').evaluate().isNotEmpty;
      final notAvailable =
          find.text('Biometrics not available on this device').evaluate().isNotEmpty;

      expect(available || notAvailable, isTrue,
          reason: 'Debe mostrar el estado de biometrics');
    },
    tags: ['biometrics'],
  );

  patrolTest(
    'boton autenticar esta habilitado cuando biometrics disponible',
    ($) async {
      await navigateToBiometrics($);
      await waitForBiometricsStatus($);

      final authButtonFinder = find.widgetWithText(
        ElevatedButton,
        'Authenticate with Biometrics',
      );
      expect(authButtonFinder, findsOneWidget);

      final isAvailable =
          find.text('Biometrics available').evaluate().isNotEmpty;

      final button = $.tester.widget<ElevatedButton>(authButtonFinder);

      if (isAvailable) {
        expect(button.onPressed, isNotNull,
            reason: 'Botón debe estar habilitado cuando biometrics disponible');
      } else {
        expect(button.onPressed, isNull,
            reason: 'Botón debe estar deshabilitado cuando biometrics no disponible');
      }
    },
    tags: ['biometrics'],
  );
}
