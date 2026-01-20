//
//  MovementRowView.swift
//  FinanzasApp
//
//  Fila de movimiento (reutilizable) con icono, categoría, fecha y monto.
//

import SwiftUI

struct MovementRowView: View {
    let movement: Movement
    let namespace: Namespace.ID
    
    // Cachear valores calculados
    private var formattedAmount: String {
        let raw = Formatters.currency.string(from: NSNumber(value: movement.amount)) ?? "$0"
        return movement.type == .expense ? "-\(raw)" : raw
    }

    private var amountColor: Color {
        movement.type == .income ? AppTheme.income : AppTheme.expense
    }
    
    private var displayTitle: String {
        movement.title.isEmpty ? movement.category.title : movement.title
    }
    
    private var subtitleText: String {
        "\(movement.category.title) • \(Formatters.dayMonth.string(from: movement.date))"
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.surface2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(.white.opacity(0.06), lineWidth: 1)
                    )
                Image(systemName: movement.category.systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
                    .matchedGeometryEffect(id: "catIcon-\(movement.id)", in: namespace)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(displayTitle)
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .lineLimit(1)

                Text(subtitleText)
                    .foregroundStyle(AppTheme.textTertiary)
                    .font(.footnote)
                    .lineLimit(1)
            }

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedAmount)
                    .foregroundStyle(amountColor)
                    .font(.system(.body, design: .rounded).weight(.semibold))

                Text(movement.type == .income ? "Ingreso" : "Gasto")
                    .foregroundStyle(AppTheme.textTertiary)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    ZStack {
        AppBackground()
        NeonCard {
            MovementRowView(
                movement: Movement(type: .expense, category: .comida, title: "Café", amount: 1400, date: .now),
                namespace: Namespace().wrappedValue
            )
        }
        .padding()
    }
}


