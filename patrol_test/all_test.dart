// Archivo para ejecutar todos los tests con patrol develop
// Uso: patrol develop --target patrol_test/all_test.dart --device "DEVICE" --no-uninstall

import 'flows/login_test.dart' as login_test;
import 'flows/biometrics_test.dart' as biometrics_test;

void main() {
  login_test.main();
  biometrics_test.main();
}
