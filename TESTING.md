# Guía de Pruebas - FinanzasApp

## Pruebas Unitarias (Swift Testing)

El proyecto incluye pruebas unitarias usando el framework **Swift Testing** de Apple.

### Ejecutar Pruebas

1. **Desde Xcode:**
   - Presiona `Cmd + U` para ejecutar todas las pruebas
   - O haz clic en el botón ▶️ junto a cada prueba individual

2. **Desde Terminal:**
   ```bash
   xcodebuild test -scheme FinanzasApp -destination 'platform=iOS Simulator,name=iPhone 15'
   ```

### Estructura de Pruebas

Las pruebas están organizadas en los siguientes grupos:

- **MovementStoreTests**: Pruebas de persistencia de datos
- **MovementModelTests**: Pruebas de modelos y enums
- **AppViewModelTests**: Pruebas de lógica de negocio
- **TicketViewModelTests**: Pruebas de procesamiento de tickets

### Cobertura Actual

✅ Persistencia (MovementStore)
✅ Modelos (Movement, Category, MovementType)
✅ ViewModel principal (AppViewModel)
✅ Cálculos financieros (balances, categorías)
✅ Filtrado por mes
✅ Unique vs Recurring expenses

## TestSprite UI Testing

TestSprite es una herramienta de pruebas de UI automatizadas que funciona a través de MCP (Model Context Protocol).

### Requisitos Previos

1. **Node.js instalado** (ya configurado ✅)
   ```bash
   node --version  # Debería mostrar v24.13.0 o superior
   npx --version   # Debería estar disponible
   ```

2. **Reiniciar Cursor** después de instalar Node.js para que el MCP server de TestSprite funcione.

### Configuración de TestSprite

TestSprite se conecta automáticamente a través del MCP server cuando Cursor detecta Node.js en el PATH.

### Uso de TestSprite

TestSprite está diseñado principalmente para aplicaciones web. Para apps iOS/SwiftUI, las opciones son:

1. **SwiftUI Testing** (Recomendado para iOS)
   - Usa el framework nativo de Apple
   - Integrado con Xcode
   - Mejor rendimiento y soporte

2. **XCTest UI Testing**
   - Para pruebas de UI más complejas
   - Simula interacciones del usuario
   - Requiere un simulador o dispositivo

### Pruebas de UI (XCTest UI Testing)

Las pruebas de UI están implementadas en `FinanzasAppUITests.swift` y cubren:

#### Navegación
- ✅ `testNavigationBetweenTabs()` - Navegación entre Dashboard, Movimientos y Estadísticas

#### Agregar Movimientos
- ✅ `testAddExpense()` - Agregar un gasto completo
- ✅ `testAddIncome()` - Agregar un ingreso completo
- ✅ `testAddMovementValidation()` - Validación del formulario

#### Ver y Eliminar
- ✅ `testViewMovementsList()` - Ver lista de movimientos
- ✅ `testDeleteMovement()` - Eliminar movimiento con swipe

#### Pantallas
- ✅ `testDashboardDisplaysCorrectly()` - Verificar elementos del Dashboard
- ✅ `testStatisticsView()` - Verificar pantalla de Estadísticas

#### Performance
- ✅ `testLaunchPerformance()` - Medir tiempo de lanzamiento

### Ejecutar Pruebas de UI

1. **Desde Xcode:**
   - Selecciona el scheme `FinanzasAppUITests`
   - Presiona `Cmd + U` para ejecutar todas las pruebas
   - O ejecuta pruebas individuales desde el Test Navigator

2. **Desde Terminal:**
   ```bash
   xcodebuild test -scheme FinanzasApp -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:FinanzasAppUITests
   ```

### Notas sobre Pruebas de UI

- Las pruebas usan `accessibilityLabel` para identificar elementos
- Se incluyen `sleep()` para esperar animaciones
- Las pruebas son independientes y pueden ejecutarse en cualquier orden
- Se recomienda ejecutar en un simulador limpio para resultados consistentes

## Próximos Pasos

1. ✅ Pruebas unitarias básicas creadas
2. ⏳ Agregar más casos edge (valores negativos, fechas inválidas, etc.)
3. ⏳ Pruebas de UI con XCTest
4. ⏳ Pruebas de integración
5. ⏳ Pruebas de rendimiento

## Notas

- Las pruebas usan `InMemoryTestStore` para evitar modificar datos reales
- Todas las pruebas son asíncronas usando `async/await`
- Se usa `#expect` del framework Swift Testing para aserciones
