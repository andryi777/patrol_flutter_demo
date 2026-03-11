import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../test_main.dart';

// =============================================================================
// HELPERS GENÉRICOS (describen exactamente lo que hacen)
// =============================================================================

/// Espera hasta que un elemento desaparezca de la pantalla
Future<void> waitUntilGone(
  PatrolIntegrationTester $,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final endTime = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(endTime)) {
    await $.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isEmpty) return;
  }
}

/// Toca un elemento y espera a que aparezca otro
Future<void> tapAndWaitFor(
  PatrolIntegrationTester $,
  Finder tapTarget,
  Finder waitFor, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  await $.waitUntilVisible(tapTarget);
  await $.tester.tap(tapTarget);
  await $.waitUntilVisible(waitFor, timeout: timeout);
}

/// Toca un icono del bottom nav y espera a que aparezca contenido
Future<void> tapBottomNavIcon(
  PatrolIntegrationTester $,
  IconData icon,
  Finder waitFor,
) async {
  await tapAndWaitFor($, find.byIcon(icon), waitFor);
}

// =============================================================================
// HELPERS DE FLUJO (específicos del negocio)
// =============================================================================

/// Realiza login con credenciales de prueba
Future<void> performLogin(PatrolIntegrationTester $) async {
  await testMain();
  await $.waitUntilVisible(find.byType(TextFormField));

  final textFields = find.byType(TextFormField);
  await $.tester.enterText(textFields.first, 'test@test.com');
  await $.tester.enterText(textFields.last, 'password123');

  await $.tester.testTextInput.receiveAction(TextInputAction.done);
  await $.pump(const Duration(milliseconds: 200));

  await tapAndWaitFor(
    $,
    find.byType(ElevatedButton),
    find.byType(BottomNavigationBar),
    timeout: const Duration(seconds: 15),
  );
}

/// Navega a la pantalla de Biometrics (requiere login)
Future<void> navigateToBiometrics(PatrolIntegrationTester $) async {
  await performLogin($);
  // Ir a Settings tab y luego a Biometrics
  await tapBottomNavIcon($, Icons.settings, find.text('Biometrics'));
  await tapAndWaitFor($, find.text('Biometrics'), find.text('Biometric Status'));
}

/// Espera a que el estado de biometrics se cargue
Future<void> waitForBiometricsStatus(PatrolIntegrationTester $) async {
  await waitUntilGone($, find.text('Checking biometrics...'));
}
