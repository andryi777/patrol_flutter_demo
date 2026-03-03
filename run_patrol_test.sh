#!/bin/bash

# Detectar simulador activo
SIMULATOR_ID=$(xcrun simctl list devices | grep Booted | head -1 | grep -oE '[0-9A-F-]{36}')

if [ -z "$SIMULATOR_ID" ]; then
  echo "❌ No hay simulador activo. Inicia uno primero."
  exit 1
fi

echo "📱 Simulador: $SIMULATOR_ID"

# Buscar xctestrun
XCTESTRUN=$(ls build/ios_integ/Build/Products/*.xctestrun 2>/dev/null | head -1)

if [ -z "$XCTESTRUN" ]; then
  echo "🔨 Construyendo tests..."
  patrol build ios --target integration_test/flows/login_test.dart
  XCTESTRUN=$(ls build/ios_integ/Build/Products/*.xctestrun | head -1)
fi

echo "🧪 Ejecutando tests..."
xcodebuild test-without-building \
  -xctestrun "$XCTESTRUN" \
  -only-testing RunnerUITests/RunnerUITests \
  -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  2>&1 | grep -E "(Test Case|Test Suite.*passed|Test Suite.*failed|SUCCEEDED|FAILED)" | grep -v "nw_"

echo ""
echo "✅ Completado"
