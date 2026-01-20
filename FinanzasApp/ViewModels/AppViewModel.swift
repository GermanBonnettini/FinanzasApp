//
//  AppViewModel.swift
//  FinanzasApp
//
//  MVVM: estado único de la app (movimientos + métricas + acciones).
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var movements: [Movement] = [] {
        didSet {
            updateCachedValues()
        }
    }
    @Published var selectedMonth: Date = Date() {
        didSet {
            updateCachedValues()
        }
    }

    // Valores cacheados para evitar recálculos innecesarios
    @Published private(set) var monthMovements: [Movement] = []
    @Published private(set) var monthIncome: Double = 0
    @Published private(set) var monthExpense: Double = 0
    @Published private(set) var monthBalance: Double = 0
    @Published private(set) var totalBalance: Double = 0
    @Published private(set) var monthExpenseByCategory: [(Category, Double)] = []

    private let store: MovementStoreProtocol
    private let calendar: Calendar

    init(store: MovementStoreProtocol = MovementStore(), calendar: Calendar = .current) {
        self.store = store
        self.calendar = calendar
        load()
    }

    // MARK: - CRUD

    func add(_ movement: Movement) {
        movements.insert(movement, at: 0)
        persist()
    }

    func delete(id: UUID) {
        movements.removeAll { $0.id == id }
        persist()
    }

    // MARK: - Derived data

    var monthTitle: String {
        Formatters.monthYear.string(from: selectedMonth).capitalized
    }
    
    // MARK: - Statistics
    
    /// Gastos únicos vs recurrentes del mes
    var monthUniqueVsRecurring: (unique: Double, recurring: Double) {
        let expenses = monthMovements.filter { $0.type == .expense }
        let unique = expenses.filter { !$0.isRecurring }.reduce(0) { $0 + $1.amount }
        let recurring = expenses.filter { $0.isRecurring }.reduce(0) { $0 + $1.amount }
        return (unique, recurring)
    }
    
    /// Gastos por mes (últimos 6 meses)
    var monthlyExpenses: [(month: String, amount: Double)] {
        var result: [(month: String, amount: Double)] = []
        let now = Date()
        
        for i in 0..<6 {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: now) else { continue }
            let comps = calendar.dateComponents([.year, .month], from: monthDate)
            
            let monthExpenses = movements.filter {
                $0.type == .expense
            }.filter {
                let c = calendar.dateComponents([.year, .month], from: $0.date)
                return c.year == comps.year && c.month == comps.month
            }.reduce(0) { $0 + $1.amount }
            
            let monthName = Formatters.monthYear.string(from: monthDate).capitalized
            result.append((month: monthName, amount: monthExpenses))
        }
        
        return result.reversed()
    }
    
    /// Balance diario para el calendario
    func dailyBalance(for date: Date) -> Double {
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? date
        
        let dayMovements = movements.filter {
            $0.date >= dayStart && $0.date < dayEnd
        }
        
        let income = dayMovements.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expense = dayMovements.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        
        return income - expense
    }
    
    /// Top categorías de gastos (todas las veces)
    var topCategories: [(Category, Double)] {
        let expenses = movements.filter { $0.type == .expense }
        var dict: [Category: Double] = [:]
        for m in expenses { dict[m.category, default: 0] += m.amount }
        return dict
            .map { ($0.key, $0.value) }
            .sorted(by: { $0.1 > $1.1 })
            .prefix(5)
            .map { $0 }
    }
    
    /// Total de gastos recurrentes vs únicos (todos los tiempos)
    var totalUniqueVsRecurring: (unique: Double, recurring: Double) {
        let expenses = movements.filter { $0.type == .expense }
        let unique = expenses.filter { !$0.isRecurring }.reduce(0) { $0 + $1.amount }
        let recurring = expenses.filter { $0.isRecurring }.reduce(0) { $0 + $1.amount }
        return (unique, recurring)
    }

    // MARK: - Cache updates

    private func updateCachedValues() {
        // Calcular movimientos del mes una sola vez
        let comps = calendar.dateComponents([.year, .month], from: selectedMonth)
        monthMovements = movements.filter {
            let c = calendar.dateComponents([.year, .month], from: $0.date)
            return c.year == comps.year && c.month == comps.month
        }
        .sorted(by: { $0.date > $1.date })

        // Calcular ingresos y gastos del mes
        monthIncome = monthMovements
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
        
        monthExpense = monthMovements
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
        
        monthBalance = monthIncome - monthExpense

        // Calcular balance total (una sola vez)
        let inc = movements.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let exp = movements.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        totalBalance = inc - exp

        // Calcular distribución por categoría
        let expenses = monthMovements.filter { $0.type == .expense }
        var dict: [Category: Double] = [:]
        for m in expenses { dict[m.category, default: 0] += m.amount }
        monthExpenseByCategory = dict
            .map { ($0.key, $0.value) }
            .sorted(by: { $0.1 > $1.1 })
    }

    // MARK: - Persistence

    private func load() {
        do {
            movements = try store.load().sorted(by: { $0.date > $1.date })
        } catch {
            movements = []
        }
    }

    private func persist() {
        do { try store.save(movements) } catch { /* silencioso: fallback */ }
    }
}

// MARK: - Preview

extension AppViewModel {
    static var preview: AppViewModel {
        let vm = AppViewModel(store: InMemoryStore())
        vm.seedForPreview()
        return vm
    }

    private func seedForPreview() {
        let now = Date()
        movements = [
            Movement(type: .income, category: .otros, title: "Sueldo", amount: 120000, date: now),
            Movement(type: .expense, category: .comida, title: "Supermercado", amount: 18500, date: calendar.date(byAdding: .day, value: -1, to: now) ?? now),
            Movement(type: .expense, category: .transporte, title: "Uber", amount: 6200, date: calendar.date(byAdding: .day, value: -2, to: now) ?? now),
            Movement(type: .expense, category: .ocio, title: "Cine", amount: 4500, date: calendar.date(byAdding: .day, value: -3, to: now) ?? now),
        ]
        selectedMonth = now
    }
}

private final class InMemoryStore: MovementStoreProtocol {
    private var cache: [Movement] = []
    func load() throws -> [Movement] { cache }
    func save(_ movements: [Movement]) throws { cache = movements }
}


