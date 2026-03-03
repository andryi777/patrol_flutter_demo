# Testing Guide

## Integration Tests with Patrol

Este proyecto usa [Patrol](https://patrol.leancode.co/) para pruebas de integración nativas en iOS y Android.

### Requisitos

- Flutter 3.7+
- Para iOS: Xcode 14+, CocoaPods
- Para Android: Android SDK, Java 11+

### Comandos Principales

```bash
# Ejecutar todas las pruebas de integración
patrol test

# Ejecutar un test específico
patrol test integration_test/flows/login_test.dart

# Especificar dispositivo
patrol test --device "iPhone 17 Pro"

# Ver dispositivos disponibles
flutter devices
```

También puedes usar el script incluido:

```bash
./run_patrol_test.sh
```

### Estructura de Tests

```
integration_test/
├── flows/              # Tests por flujo de usuario
│   └── login_test.dart
├── test_bundle.dart    # Agrupa todos los tests
└── test_main.dart      # Entry point
```

### Escribir un Test

```dart
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('usuario puede hacer login', ($) async {
    // Esperar elemento
    await $(#emailField).waitUntilVisible();

    // Interactuar
    await $(#emailField).enterText('user@test.com');
    await $(#passwordField).enterText('password123');
    await $(#loginButton).tap();

    // Verificar
    expect($(#homeScreen), findsOneWidget);
  });
}
```

---

## Ejecutar la App en Desarrollo

### Iniciar la app

```bash
# En cualquier dispositivo disponible
flutter run

# En dispositivo específico
flutter run -d "iPhone 17 Pro"

# Listar dispositivos
flutter devices
```

### Mantener la app activa

Una vez iniciada, la app permanece corriendo. Usa estos comandos en la terminal:

| Tecla | Acción |
|-------|--------|
| `r` | Hot reload (cambios rápidos) |
| `R` | Hot restart (reinicio completo) |
| `d` | Detach (deja la app corriendo, libera terminal) |
| `q` | Quit (cierra la app) |

### Modo Detach

Para dejar la app corriendo y liberar la terminal:

```bash
# Presiona 'd' durante flutter run, o:
flutter run --no-hot
# Luego Ctrl+C para salir sin cerrar la app
```

---

## Tests Unitarios y de Widget

```bash
# Todos los tests
flutter test

# Test específico
flutter test test/features/auth/login_test.dart

# Con coverage
flutter test --coverage
```

---

## Troubleshooting

### Patrol no encuentra el dispositivo
```bash
flutter devices  # Verificar nombre exacto
patrol test --device "nombre exacto"
```

### Error de sandbox en iOS
El proyecto ya tiene el sandbox deshabilitado en Xcode. Si persiste:
1. Abrir `ios/Runner.xcworkspace` en Xcode
2. Runner → Build Settings → User Script Sandboxing → No

### App se cierra al cambiar idioma
Verificar que `app_router.dart` no esté haciendo `ref.watch()` de providers de localización.
