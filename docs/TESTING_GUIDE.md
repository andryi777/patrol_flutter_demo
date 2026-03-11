# Testing Guide

## Integration Tests with Patrol

Este proyecto usa [Patrol](https://patrol.leancode.co/) para pruebas de integración nativas en iOS y Android.

### Requisitos

- Flutter 3.41+ (Dart SDK >=3.10.0)
- Patrol CLI 4.1+
- Para iOS: Xcode 16+, CocoaPods, iOS 13+
- Para Android: Android SDK, Java 17+

### Comandos Principales

```bash
# Ejecutar todas las pruebas de integración
patrol test

# Ejecutar un test específico
patrol test patrol_test/flows/login_test.dart

# Especificar dispositivo
patrol test --device "iPhone 17 Pro"

# Ver dispositivos disponibles
flutter devices
```

### Estructura de Tests

```
patrol_test/
├── flows/              # Tests por flujo de usuario
│   ├── login_test.dart
│   └── biometrics_test.dart
├── helpers/            # Helpers reutilizables
│   └── login_helper.dart
├── test_bundle.dart    # Generado automáticamente (ignorado en git)
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

### Test de Biometrics en iOS Simulator
Antes de correr el test de biometrics:
1. En el simulador: **Features → Face ID → Enrolled**
2. Durante el test, cuando aparezca el diálogo: **Features → Face ID → Matching Face**

```bash
# Correr solo tests de biometrics
patrol test --tags biometrics
```

### Error de sandbox en iOS
El proyecto ya tiene el sandbox deshabilitado en Xcode. Si persiste:
1. Abrir `ios/Runner.xcworkspace` en Xcode
2. Runner → Build Settings → User Script Sandboxing → No

### App se cierra al cambiar idioma
Verificar que `app_router.dart` no esté haciendo `ref.watch()` de providers de localización.

---

## Lecciones Aprendidas

### iOS: Evitar múltiples clones del simulador

**Problema:** Al ejecutar tests con Patrol en iOS, Xcode creaba múltiples clones del simulador (Clone 1, Clone 2, etc.), consumiendo recursos y causando confusión.

**Causa raíz:** En `ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`, los `TestableReference` tenían `parallelizable = "YES"`, lo que indica a Xcode que puede crear clones del simulador para ejecutar tests en paralelo.

**Solución:** Cambiar `parallelizable = "NO"` en ambos TestableReference:

```xml
<!-- Antes -->
<TestableReference skipped="NO" parallelizable="YES">

<!-- Después -->
<TestableReference skipped="NO" parallelizable="NO">
```

**Ubicación:** Líneas 43 y 54 de `Runner.xcscheme`

### Optimizar tiempo de ejecución con --no-uninstall

**Problema:** La app se reinstalaba en cada ejecución de tests, perdiendo tiempo.

**Solución:** Usar el flag `--no-uninstall` para mantener la app instalada después de las pruebas:

```bash
# Comando optimizado para iOS
patrol test --device "UUID-DEL-SIMULADOR" --no-uninstall --ios 17.5

# Para encontrar el UUID del simulador
xcrun simctl list devices | grep -i booted
```

**Nota:** No existe un flag `--skip-install` en Patrol 4.2.0. La app siempre se reconstruye/reinstala al inicio, pero `--no-uninstall` evita la desinstalación posterior.

### patrol test vs patrol develop: Optimizar tiempos de build

**Problema:** `patrol test` siempre reconstruye la app (~40-50s), incluso con `--no-uninstall`.

**Hallazgo:** No existe un flag `--skip-build` en Patrol 4.2.0. El build es inevitable con `patrol test`.

**Solución para desarrollo:** Usar `patrol develop` que soporta **Hot Restart**.

| Comando | Build inicial | Re-ejecución |
|---------|---------------|--------------|
| `patrol test` | ~40s (siempre) | ~40s (rebuild completo) |
| `patrol develop` | ~40s (una vez) | **~1s** (Hot Restart) |

#### Uso de patrol develop

```bash
# Iniciar modo desarrollo (requiere terminal interactiva)
patrol develop \
  --target patrol_test/flows/login_test.dart \
  --device "iPhone 15 Pro" \
  --no-uninstall \
  --ios 17.5
```

Una vez iniciado, usa estas teclas:
| Tecla | Acción |
|-------|--------|
| `R` | Hot Restart - re-ejecuta tests (~1s) |
| `r` | Hot Reload - aplica cambios de código |
| `q` | Salir |

**Cuándo usar cada uno:**
- **`patrol develop`**: Desarrollo iterativo, debugging, escribir tests nuevos
- **`patrol test`**: CI/CD, ejecución completa de suite, validación final

### Comando recomendado para desarrollo

```bash
# Desarrollo iterativo (más rápido, soporta Hot Restart)
patrol develop --target patrol_test/flows/login_test.dart --device "iPhone 15 Pro" --no-uninstall --ios 17.5

# Ejecución de tests en CI/CD
patrol test --device "iPhone 15 Pro" --no-uninstall --ios 17.5
```
