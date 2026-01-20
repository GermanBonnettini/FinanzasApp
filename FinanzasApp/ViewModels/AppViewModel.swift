//
//  AppViewModel.swift
//  FinanzasApp
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var movements: [Movement] = [] {
        didSet { updateCachedValues() }
    }
    @Published var selectedMonth: Date = Date() {
        didSet { updateCachedValues() }
    }

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

    // MARK: - Computed Properties

    var monthTitle: String {
        Formatters.monthYear.string(from: selectedMonth).capitalized
    }
    
    var monthUniqueVsRecurring: (unique: Double, recurring: Double) {
        let expenses = monthMovements.filter { $0.type == .expense }
        let unique = expenses.filter { !$0.isRecurring }.reduce(0) { $0 + $1.amount }
        let recurring = expenses.filter { $0.isRecurring }.reduce(0) { $0 + $1.amount }
        return (unique, recurring)
    }
    
    var totalUniqueVsRecurring: (unique: Double, recurring: Double) {
        let expenses = movements.filter { $0.type == .expense }
        let unique = expenses.filter { !$0.isRecurring }.reduce(0) { $0 + $1.amount }
        let recurring = expenses.filter { $0.isRecurring }.reduce(0) { $0 + $1.amount }
        return (unique, recurring)
    }
    
    var monthlyExpenses: [(month: String, amount: Double)] {
        (0..<6).compactMap { i -> (String, Double)? in
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: Date()) else { return nil }
            let comps = calendar.dateComponents([.year, .month], from: monthDate)
            let amount = movements
                .filter { $0.type == .expense }
                .filter {
                    let c = calendar.dateComponents([.year, .month], from: $0.date)
                    return c.year == comps.year && c.month == comps.month
                }
                .reduce(0) { $0 + $1.amount }
            return (Formatters.monthYear.string(from: monthDate).capitalized, amount)
        }.reversed()
    }
    
    func dailyBalance(for date: Date) -> Double {
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? date
        let dayMovements = movements.filter { $0.date >= dayStart && $0.date < dayEnd }
        let income = dayMovements.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expense = dayMovements.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        return income - expense
    }
    
    var topCategories: [(Category, Double)] {
        Dictionary(grouping: movements.filter { $0.type == .expense }, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
            .map { ($0.key, $0.value) }
            .sorted(by: { $0.1 > $1.1 })
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Private

    private func updateCachedValues() {
        let comps = calendar.dateComponents([.year, .month], from: selectedMonth)
        monthMovements = movements
            .filter {
                let c = calendar.dateComponents([.year, .month], from: $0.date)
                return c.year == comps.year && c.month == comps.month
            }
            .sorted(by: { $0.date > $1.date })

        monthIncome = monthMovements.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        monthExpense = monthMovements.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        monthBalance = monthIncome - monthExpense

        let totalIncome = movements.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let totalExpense = movements.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        totalBalance = totalIncome - totalExpense

        monthExpenseByCategory = Dictionary(grouping: monthMovements.filter { $0.type == .expense }, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
            .map { ($0.key, $0.value) }
            .sorted(by: { $0.1 > $1.1 })
    }

    private func load() {
        do {
            movements = try store.load().sorted(by: { $0.date > $1.date })
        } catch {
            movements = []
        }
    }

    private func persist() {
        try? store.save(movements)
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


