//
//  AppTheme.swift
//  FinanzasApp
//
//  Tokens visuales: paleta oscura + acentos neón (verde/azul), tipografía y estilos base.
//

import SwiftUI

enum AppTheme {
    // Fondo oscuro con ligera variación para dar profundidad sin “ruido”.
    static let background = Color(red: 0.05, green: 0.06, blue: 0.08)
    static let background2 = Color(red: 0.03, green: 0.04, blue: 0.06)

    // Superficies (cards / panels).
    static let surface = Color(red: 0.09, green: 0.10, blue: 0.13)
    static let surface2 = Color(red: 0.12, green: 0.13, blue: 0.17)

    // Texto.
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.70)
    static let textTertiary = Color.white.opacity(0.45)

    // Acento neón (puedes alternar a azul si prefieres).
    static let accent = Color(red: 0.23, green: 0.98, blue: 0.63)     // verde neón
    static let accent2 = Color(red: 0.20, green: 0.70, blue: 1.00)    // azul neón

    // Estados semánticos.
    static let income = Color(red: 0.23, green: 0.98, blue: 0.63)
    static let expense = Color(red: 1.00, green: 0.35, blue: 0.55)

    // Layout / radius.
    static let cardRadius: CGFloat = 18
    static let controlRadius: CGFloat = 14
}


