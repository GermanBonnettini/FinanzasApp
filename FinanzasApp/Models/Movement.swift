//
//  Movement.swift
//  FinanzasApp
//
//  Modelo principal: ingreso/gasto. Codable para persistencia ligera.
//

import Foundation

enum MovementType: String, Codable, CaseIterable {
    case income
    case expense

    var sign: Double { self == .income ? 1 : -1 }
}

enum Category: String, Codable, CaseIterable, Identifiable, Equatable {
    // Gastos
    case comida
    case transporte
    case ocio
    case hogar
    case salud
    case suscripciones
    case compras
    case otros
    
    // Ingresos
    case sueldo
    case venta
    case freelance
    case inversion
    case regalo
    case reembolso
    case alquiler
    case negocio

    var id: String { rawValue }

    var title: String {
        switch self {
        // Gastos
        case .comida: return "Comida"
        case .transporte: return "Transporte"
        case .ocio: return "Ocio"
        case .hogar: return "Hogar"
        case .salud: return "Salud"
        case .suscripciones: return "Suscripciones"
        case .compras: return "Compras"
        case .otros: return "Otros"
        // Ingresos
        case .sueldo: return "Sueldo"
        case .venta: return "Venta"
        case .freelance: return "Freelance"
        case .inversion: return "Inversión"
        case .regalo: return "Regalo"
        case .reembolso: return "Reembolso"
        case .alquiler: return "Alquiler"
        case .negocio: return "Negocio"
        }
    }

    /// SF Symbols simples y claros.
    var systemImage: String {
        switch self {
        // Gastos
        case .comida: return "fork.knife"
        case .transporte: return "car.fill"
        case .ocio: return "gamecontroller.fill"
        case .hogar: return "house.fill"
        case .salud: return "cross.case.fill"
        case .suscripciones: return "repeat"
        case .compras: return "bag.fill"
        case .otros: return "sparkles"
        // Ingresos
        case .sueldo: return "dollarsign.circle.fill"
        case .venta: return "tag.fill"
        case .freelance: return "laptopcomputer"
        case .inversion: return "chart.line.uptrend.xyaxis"
        case .regalo: return "gift.fill"
        case .reembolso: return "arrow.counterclockwise"
        case .alquiler: return "key.fill"
        case .negocio: return "briefcase.fill"
        }
    }
    
    /// Categorías para gastos
    static var expenseCategories: [Category] {
        [.comida, .transporte, .ocio, .hogar, .salud, .suscripciones, .compras, .otros]
    }
    
    /// Categorías para ingresos
    static var incomeCategories: [Category] {
        [.sueldo, .venta, .freelance, .inversion, .regalo, .reembolso, .alquiler, .negocio]
    }
    
    /// Obtener categorías según el tipo de movimiento
    static func categories(for type: MovementType) -> [Category] {
        switch type {
        case .expense: return expenseCategories
        case .income: return incomeCategories
        }
    }
}

struct Movement: Identifiable, Codable, Equatable {
    let id: UUID
    var type: MovementType
    var category: Category
    var title: String
    var amount: Double
    var date: Date
    var isRecurring: Bool

    init(
        id: UUID = UUID(),
        type: MovementType,
        category: Category,
        title: String,
        amount: Double,
        date: Date = Date(),
        isRecurring: Bool = false
    ) {
        self.id = id
        self.type = type
        self.category = category
        self.title = title
        self.amount = amount
        self.date = date
        self.isRecurring = isRecurring
    }
}


