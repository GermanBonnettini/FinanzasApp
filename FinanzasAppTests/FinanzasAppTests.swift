//
//  FinanzasAppTests.swift
//  FinanzasAppTests
//
//  Created by H4MM3R-9 on 16/12/2025.
//

import Testing
import Foundation
@testable import FinanzasApp

// MARK: - MovementStore Tests

struct MovementStoreTests {
    
    @Test("MovementStore debería guardar y cargar movimientos correctamente")
    func testSaveAndLoad() throws {
        let store = MovementStore(defaults: UserDefaults(suiteName: "test.store")!, key: "test.movements")
        let movements = [
            Movement(type: .income, category: .sueldo, title: "Sueldo", amount: 1000),
            Movement(type: .expense, category: .comida, title: "Comida", amount: 50)
        ]
        
        try store.save(movements)
        let loaded = try store.load()
        
        #expect(loaded.count == 2)
        #expect(loaded[0].title == "Sueldo")
        #expect(loaded[1].title == "Comida")
    }
    
    @Test("MovementStore debería retornar array vacío si no hay datos guardados")
    func testLoadEmpty() throws {
        let store = MovementStore(defaults: UserDefaults(suiteName: "test.empty")!, key: "test.empty.movements")
        let loaded = try store.load()
        #expect(loaded.isEmpty)
    }
}

// MARK: - Movement Model Tests

struct MovementModelTests {
    
    @Test("Movement debería inicializarse correctamente")
    func testInitialization() {
        let movement = Movement(
            type: .expense,
            category: .transporte,
            title: "Uber",
            amount: 25.50,
            date: Date(),
            isRecurring: true
        )
        
        #expect(movement.type == .expense)
        #expect(movement.category == .transporte)
        #expect(movement.title == "Uber")
        #expect(movement.amount == 25.50)
        #expect(movement.isRecurring == true)
    }
    
    @Test("MovementType debería tener el signo correcto")
    func testMovementTypeSign() {
        #expect(MovementType.income.sign == 1)
        #expect(MovementType.expense.sign == -1)
    }
    
    @Test("Category debería retornar categorías correctas por tipo")
    func testCategoryFiltering() {
        let expenseCategories = Category.categories(for: .expense)
        let incomeCategories = Category.categories(for: .income)
        
        #expect(expenseCategories.contains(.comida))
        #expect(expenseCategories.contains(.transporte))
        #expect(!expenseCategories.contains(.sueldo))
        
        #expect(incomeCategories.contains(.sueldo))
        #expect(incomeCategories.contains(.venta))
        #expect(!incomeCategories.contains(.comida))
    }
}

// MARK: - AppViewModel Tests

@MainActor
struct AppViewModelTests {
    
    @Test("AppViewModel debería agregar movimientos correctamente")
    func testAddMovement() async {
        let vm = AppViewModel(store: InMemoryTestStore())
        
        let movement = Movement(
            type: .income,
            category: .sueldo,
            title: "Test Income",
            amount: 1000
        )
        
        await vm.add(movement)
        
        #expect(vm.movements.count == 1)
        #expect(vm.movements.first?.title == "Test Income")
    }
    
    @Test("AppViewModel debería eliminar movimientos correctamente")
    func testDeleteMovement() async {
        let vm = AppViewModel(store: InMemoryTestStore())
        
        let movement = Movement(
            type: .expense,
            category: .comida,
            title: "Test Expense",
            amount: 50
        )
        
        await vm.add(movement)
        let id = movement.id
        
        await vm.delete(id: id)
        
        #expect(vm.movements.isEmpty)
    }
    
    @Test("AppViewModel debería calcular balance mensual correctamente")
    func testMonthlyBalance() async {
        let vm = AppViewModel(store: InMemoryTestStore())
        let calendar = Calendar.current
        let now = Date()
        
        // Agregar ingresos y gastos del mes actual
        await vm.add(Movement(type: .income, category: .sueldo, title: "Sueldo", amount: 1000, date: now))
        await vm.add(Movement(type: .expense, category: .comida, title: "Comida", amount: 200, date: now))
        await vm.add(Movement(type: .expense, category: .transporte, title: "Uber", amount: 50, date: now))
        
        // El balance debería ser 1000 - 200 - 50 = 750
        #expect(vm.monthBalance == 750)
        #expect(vm.monthIncome == 1000)
        #expect(vm.monthExpense == 250)
    }
    
    @Test("AppViewModel debería calcular balance total correctamente")
    func testTotalBalance() async {
        let vm = AppViewModel(store: InMemoryTestStore())
        
        await vm.add(Movement(type: .income, category: .sueldo, title: "Sueldo", amount: 5000))
        await vm.add(Movement(type: .expense, category: .comida, title: "Comida", amount: 1000))
        await vm.add(Movement(type: .expense, category: .transporte, title: "Uber", amount: 500))
        
        #expect(vm.totalBalance == 3500) // 5000 - 1000 - 500
    }
    
    @Test("AppViewModel debería filtrar movimientos por mes correctamente")
    func testMonthlyFiltering() async {
        let vm = AppViewModel(store: InMemoryTestStore())
        let calendar = Calendar.current
        let now = Date()
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: now)!
        
        // Movimientos del mes actual
        await vm.add(Movement(type: .income, category: .sueldo, title: "Sueldo Actual", amount: 1000, date: now))
        
        // Movimiento del mes pasado
        await vm.add(Movement(type: .expense, category: .comida, title: "Comida Pasada", amount: 200, date: lastMonth))
        
        // Debería mostrar solo el movimiento del mes actual
        #expect(vm.monthMovements.count == 1)
        #expect(vm.monthMovements.first?.title == "Sueldo Actual")
    }
    
    @Test("AppViewModel debería calcular gastos por categoría correctamente")
    func testExpensesByCategory() async {
        let vm = AppViewModel(store: InMemoryTestStore())
        
        await vm.add(Movement(type: .expense, category: .comida, title: "Comida 1", amount: 100))
        await vm.add(Movement(type: .expense, category: .comida, title: "Comida 2", amount: 150))
        await vm.add(Movement(type: .expense, category: .transporte, title: "Uber", amount: 50))
        
        let expensesByCategory = vm.monthExpenseByCategory
        let comidaTotal = expensesByCategory.first { $0.0 == .comida }?.1 ?? 0
        
        #expect(comidaTotal == 250) // 100 + 150
    }
    
    @Test("AppViewModel debería calcular unique vs recurring correctamente")
    func testUniqueVsRecurring() async {
        let vm = AppViewModel(store: InMemoryTestStore())
        
        await vm.add(Movement(type: .expense, category: .comida, title: "Comida Única", amount: 100, isRecurring: false))
        await vm.add(Movement(type: .expense, category: .suscripciones, title: "Netflix", amount: 50, isRecurring: true))
        await vm.add(Movement(type: .expense, category: .suscripciones, title: "Spotify", amount: 30, isRecurring: true))
        
        let (unique, recurring) = vm.monthUniqueVsRecurring
        
        #expect(unique == 100)
        #expect(recurring == 80) // 50 + 30
    }
}

// MARK: - TicketViewModel Tests

@MainActor
struct TicketViewModelTests {
    
    @Test("TicketViewModel debería inicializarse correctamente")
    func testInitialization() async {
        let vm = TicketViewModel()
        
        // Verificar que el ViewModel se inicializa correctamente
        #expect(vm.detectedText.isEmpty)
        #expect(vm.detectedAmount == nil)
        #expect(vm.isProcessing == false)
    }
    
    @Test("TicketViewModel debería resetear correctamente")
    func testReset() async {
        let vm = TicketViewModel()
        
        // Simular estado procesado
        vm.detectedText = "Test text"
        vm.detectedAmount = 100.0
        vm.isProcessing = true
        
        vm.reset()
        
        #expect(vm.detectedText.isEmpty)
        #expect(vm.detectedAmount == nil)
        #expect(vm.isProcessing == false)
    }
}

// MARK: - Test Helpers

private final class InMemoryTestStore: MovementStoreProtocol {
    private var cache: [Movement] = []
    
    func load() throws -> [Movement] {
        return cache
    }
    
    func save(_ movements: [Movement]) throws {
        cache = movements
    }
}
