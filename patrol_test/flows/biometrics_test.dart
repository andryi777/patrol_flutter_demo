import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/login_helper.dart';

void main() {
  patrolTest(
    'navegar a biometrics desde settings',
    ($) async {
      await performLogin($);

      // Wait for home screen to fully load
      await Future.delayed(const Duration(seconds: 2));
      await $.pump(const Duration(seconds: 2));

      // Navegar a Settings
      await $.tester.tap(find.text('Settings'));
      await $.pump(const Duration(seconds: 1));

      // Tap en Biometrics
      await $.tester.tap(find.text('Biometrics'));
      await $.pump(const Duration(seconds: 1));
      await Future.delayed(const Duration(seconds: 2));
      await $.pump(const Duration(seconds: 1));

      // Verificar que llegamos a la pantalla de Biometrics
      expect(find.text('Biometric Status'), findsOneWidget);
      expect(find.text('Authenticate with Biometrics'), findsOneWidget);
    },
    tags: ['biometrics'],
  );

  patrolTest(
    'verificar disponibilidad de biometrics',
    ($) async {
      await performLogin($);

      // Wait for home screen to fully load
      await Future.delayed(const Duration(seconds: 2));
      await $.pump(const Duration(seconds: 2));

      // Navegar a Settings → Biometrics
      await $.tester.tap(find.text('Settings'));
      await $.pump(const Duration(seconds: 1));
      await $.tester.tap(find.text('Biometrics'));
      await $.pump(const Duration(seconds: 1));
      await Future.delayed(const Duration(seconds: 2));
      await $.pump(const Duration(seconds: 1));

      // Uno de estos mensajes debe aparecer
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
      await performLogin($);

      // Wait for home screen to fully load (extra time for this test)
      await Future.delayed(const Duration(seconds: 4));
      await $.pump(const Duration(seconds: 3));

      // Navegar a Settings → Biometrics
      await $.tester.tap(find.text('Settings'));
      await $.pump(const Duration(seconds: 1));
      await $.tester.tap(find.text('Biometrics'));
      await $.pump(const Duration(seconds: 1));
      await Future.delayed(const Duration(seconds: 2));
      await $.pump(const Duration(seconds: 1));

      // Buscar el botón de autenticación
      final authButtonFinder = find.widgetWithText(
        ElevatedButton,
        'Authenticate with Biometrics',
      );
      expect(authButtonFinder, findsOneWidget);

      // Verificar estado del botón según disponibilidad de biometrics
      final isAvailable =
          find.text('Biometrics available').evaluate().isNotEmpty;

      final button =
          $.tester.widget<ElevatedButton>(authButtonFinder);

      if (isAvailable) {
        // Si biometrics está disponible, el botón debe estar habilitado
        expect(button.onPressed, isNotNull,
            reason: 'Botón debe estar habilitado cuando biometrics disponible');
      } else {
        // Si no está disponible, el botón debe estar deshabilitado
        expect(button.onPressed, isNull,
            reason: 'Botón debe estar deshabilitado cuando biometrics no disponible');
      }
    },
    tags: ['biometrics'],
  );

  patrolTest(
    'tocar boton autenticar abre dialogo del sistema',
    ($) async {
      await performLogin($);

      // Wait for home screen to fully load
      await Future.delayed(const Duration(seconds: 2));
      await $.pump(const Duration(seconds: 2));

      // Navegar a Settings → Biometrics
      await $.tester.tap(find.text('Settings'));
      await $.pump(const Duration(seconds: 1));
      await $.tester.tap(find.text('Biometrics'));
      await $.pump(const Duration(seconds: 1));
      await Future.delayed(const Duration(seconds: 2));
      await $.pump(const Duration(seconds: 1));

      // Solo continuar si biometrics está disponible
      final isAvailable =
          find.text('Biometrics available').evaluate().isNotEmpty;

      if (!isAvailable) {
        // Skip si no hay biometrics disponible
        return;
      }

      // Tocar el botón de autenticación
      final authButton = find.widgetWithText(
        ElevatedButton,
        'Authenticate with Biometrics',
      );
      await $.tester.tap(authButton);
      await $.pump(const Duration(seconds: 1));

      // El diálogo del sistema aparecerá
      // En simulador: ir a Features > Face ID > Matching Face para completar
      // El test verifica que tocar el botón no causa crash
      await Future.delayed(const Duration(seconds: 3));
      await $.pump(const Duration(seconds: 1));

      // Verificar que seguimos en la pantalla de biometrics (no crash)
      expect(find.text('Biometric Status'), findsOneWidget);
    },
    tags: ['biometrics', 'native'],
  );
}
