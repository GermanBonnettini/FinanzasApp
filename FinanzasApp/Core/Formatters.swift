//
//  Formatters.swift
//  FinanzasApp
//
//  Formatters reutilizables para dinero/fecha (sin coste de crear instancias repetidas).
//

import Foundation

enum Formatters {
    static let currency: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.maximumFractionDigits = 0
        nf.currencySymbol = "$"
        nf.locale = Locale(identifier: "es_ES")
        return nf
    }()

    static let monthYear: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_ES")
        df.dateFormat = "LLLL yyyy"
        return df
    }()

    static let dayMonth: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_ES")
        df.dateFormat = "d MMM"
        return df
    }()
    
    static let date: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_ES")
        df.dateFormat = "d MMM yyyy"
        return df
    }()
}


