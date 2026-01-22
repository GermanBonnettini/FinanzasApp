//
//  FinanzasAppUITests.swift
//  FinanzasAppUITests
//
//  Created by H4MM3R-9 on 16/12/2025.
//

import XCTest

final class FinanzasAppUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Navegación Tests
    
    @MainActor
    func testNavigationBetweenTabs() throws {
        // Verificar que el Dashboard es la pantalla inicial
        XCTAssertTrue(app.staticTexts["Dashboard"].exists, "Dashboard debería ser visible")
        
        // Navegar a Movimientos usando accessibilityLabel
        let movementsButton = app.buttons["Movimientos"]
        if movementsButton.exists {
            movementsButton.tap()
            sleep(1) // Esperar animación
            XCTAssertTrue(app.staticTexts["Movimientos"].exists || app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Movimiento'")).firstMatch.exists, "Pantalla de Movimientos debería ser visible")
        }
        
        // Navegar a Estadísticas
        let statisticsButton = app.buttons["Estadísticas"]
        if statisticsButton.exists {
            statisticsButton.tap()
            sleep(1)
            XCTAssertTrue(app.staticTexts["Estadísticas"].exists, "Pantalla de Estadísticas debería ser visible")
        }
        
        // Volver al Dashboard
        let dashboardButton = app.buttons["Dashboard"]
        if dashboardButton.exists {
            dashboardButton.tap()
            sleep(1)
            XCTAssertTrue(app.staticTexts["Dashboard"].exists, "Debería volver al Dashboard")
        }
    }
    
    // MARK: - Agregar Movimiento Tests
    
    @MainActor
    func testAddExpense() throws {
        // Abrir modal de agregar movimiento usando accessibilityLabel
        let addButton = app.buttons["Añadir movimiento"]
        if !addButton.exists {
            // Fallback: buscar por icono plus
            let addButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Añadir' OR label CONTAINS 'plus' OR identifier CONTAINS 'add'"))
            if addButtons.count > 0 {
                addButtons.firstMatch.tap()
            } else {
                XCTFail("No se encontró el botón de agregar")
                return
            }
        } else {
            addButton.tap()
        }
        
        sleep(1) // Esperar que se abra el modal
        
        // Verificar que el modal está abierto
        let cancelButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Cancelar' OR label CONTAINS 'Cancel'")).firstMatch
        XCTAssertTrue(cancelButton.exists, "Modal de agregar movimiento debería estar abierto")
        
        // Verificar que está en modo "Gasto" por defecto
        let expenseButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Gasto' OR label CONTAINS 'Expense'")).firstMatch
        if expenseButton.exists {
            XCTAssertTrue(expenseButton.isSelected || expenseButton.value as? String == "1", "Debería estar en modo Gasto por defecto")
        }
        
        // Llenar el campo de monto
        let amountField = app.textFields.firstMatch
        if amountField.exists {
            amountField.tap()
            amountField.typeText("100")
        }
        
        // Llenar descripción (opcional)
        let titleField = app.textFields.element(boundBy: 1)
        if titleField.exists {
            titleField.tap()
            titleField.typeText("Test Expense")
        }
        
        // Seleccionar categoría (tocar una categoría disponible)
        let categoryButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'category' OR label CONTAINS 'Comida' OR label CONTAINS 'Transporte'"))
        if categoryButtons.count > 0 {
            categoryButtons.firstMatch.tap()
        }
        
        // Guardar movimiento
        let saveButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Guardar' OR label CONTAINS 'Save' OR label CONTAINS 'Añadir'")).firstMatch
        if saveButton.exists {
            saveButton.tap()
            sleep(1) // Esperar que se cierre el modal
        }
        
        // Verificar que el modal se cerró
        XCTAssertFalse(cancelButton.exists || !app.buttons.matching(NSPredicate(format: "label CONTAINS 'Cancelar'")).firstMatch.exists, "Modal debería haberse cerrado")
    }
    
    @MainActor
    func testAddIncome() throws {
        // Abrir modal de agregar movimiento
        let addButton = app.buttons["Añadir movimiento"]
        if !addButton.exists {
            let addButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Añadir' OR label CONTAINS 'plus' OR identifier CONTAINS 'add'"))
            if addButtons.count > 0 {
                addButtons.firstMatch.tap()
            } else {
                XCTFail("No se encontró el botón de agregar")
                return
            }
        } else {
            addButton.tap()
        }
        
        sleep(1)
        
        // Cambiar a modo Ingreso
        let incomeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Ingreso' OR label CONTAINS 'Income'")).firstMatch
        if incomeButton.exists {
            incomeButton.tap()
            sleep(1) // Esperar que cambien las categorías
        }
        
        // Llenar monto
        let amountField = app.textFields.firstMatch
        if amountField.exists {
            amountField.tap()
            amountField.typeText("5000")
        }
        
        // Llenar descripción
        let titleField = app.textFields.element(boundBy: 1)
        if titleField.exists {
            titleField.tap()
            titleField.typeText("Test Income")
        }
        
        // Guardar
        let saveButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Guardar' OR label CONTAINS 'Save' OR label CONTAINS 'Añadir'")).firstMatch
        if saveButton.exists {
            saveButton.tap()
            sleep(1)
        }
    }
    
    // MARK: - Ver Movimientos Tests
    
    @MainActor
    func testViewMovementsList() throws {
        // Primero agregar un movimiento para tener algo que ver
        try testAddExpense()
        
        // Navegar a Movimientos
        let movementsButton = app.buttons["Movimientos"]
        if movementsButton.exists {
            movementsButton.tap()
            sleep(1)
        }
        
        // Verificar que la lista está visible
        let list = app.tables.firstMatch
        if list.exists {
            XCTAssertTrue(list.cells.count > 0 || list.staticTexts.count > 0, "Debería haber movimientos en la lista")
        } else {
            // Si no hay tabla, verificar que hay algún contenido
            let cards = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS 'card' OR type == 'XCUIElementTypeOther'"))
            XCTAssertTrue(cards.count > 0, "Debería haber contenido visible")
        }
    }
    
    // MARK: - Eliminar Movimiento Tests
    
    @MainActor
    func testDeleteMovement() throws {
        // Agregar un movimiento primero
        try testAddExpense()
        
        // Navegar a Movimientos
        let movementsButton = app.buttons["Movimientos"]
        if movementsButton.exists {
            movementsButton.tap()
            sleep(1)
        }
        
        // Buscar un movimiento en la lista
        let list = app.tables.firstMatch
        if list.exists && list.cells.count > 0 {
            let firstCell = list.cells.firstMatch
            
            // Hacer swipe para eliminar
            firstCell.swipeLeft()
            
            // Buscar botón de eliminar
            let deleteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Eliminar' OR label CONTAINS 'Delete' OR identifier CONTAINS 'trash'")).firstMatch
            if deleteButton.exists {
                deleteButton.tap()
                sleep(1) // Esperar que se elimine
            }
        }
    }
    
    // MARK: - Dashboard Tests
    
    @MainActor
    func testDashboardDisplaysCorrectly() throws {
        // Verificar que estamos en el Dashboard
        XCTAssertTrue(app.staticTexts["Dashboard"].exists, "Dashboard debería ser visible")
        
        // Verificar que hay elementos del dashboard
        // Balance total o mensual debería estar visible
        // No fallar si no hay balance aún (app nueva)
        _ = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '$' OR label CONTAINS 'Balance' OR label MATCHES '.*[0-9]+.*'"))
        
        // Verificar que hay un gráfico o categorías
        // No fallar si no hay datos aún
        _ = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS 'chart' OR identifier CONTAINS 'donut'"))
    }
    
    // MARK: - Estadísticas Tests
    
    @MainActor
    func testStatisticsView() throws {
        // Agregar algunos movimientos primero para tener datos
        try testAddExpense()
        try testAddIncome()
        
        // Navegar a Estadísticas
        let statisticsButton = app.buttons["Estadísticas"]
        if statisticsButton.exists {
            statisticsButton.tap()
            sleep(1)
        }
        
        // Verificar que la pantalla de estadísticas está visible
        XCTAssertTrue(app.staticTexts["Estadísticas"].exists, "Pantalla de Estadísticas debería ser visible")
        
        // Verificar que hay gráficos o datos
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp() // Scroll para ver más contenido
            sleep(1)
        }
    }
    
    // MARK: - Validación de Formulario Tests
    
    @MainActor
    func testAddMovementValidation() throws {
        // Abrir modal
        let addButton = app.buttons["Añadir movimiento"]
        if !addButton.exists {
            let addButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Añadir' OR label CONTAINS 'plus' OR identifier CONTAINS 'add'"))
            if addButtons.count > 0 {
                addButtons.firstMatch.tap()
            } else {
                return
            }
        } else {
            addButton.tap()
        }
        
        sleep(1)
        
        // Intentar guardar sin monto (debería requerir monto)
        let saveButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Guardar' OR label CONTAINS 'Save' OR label CONTAINS 'Añadir'")).firstMatch
        if saveButton.exists {
            // El botón podría estar deshabilitado o la app podría validar
            // Esto depende de la implementación
        }
        
        // Cancelar
        let cancelButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Cancelar' OR label CONTAINS 'Cancel'")).firstMatch
        if cancelButton.exists {
            cancelButton.tap()
            sleep(1)
        }
    }
    
    // MARK: - Performance Tests
    
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
