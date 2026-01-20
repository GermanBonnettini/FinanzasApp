//
//  BarChartView.swift
//  FinanzasApp
//
//  Gráfico de barras animado para mostrar gastos mensuales.
//

import SwiftUI

struct BarChartView: View {
    let data: [(month: String, amount: Double)]
    
    @State private var animate = false
    
    private var maxAmount: Double {
        max(data.map { $0.amount }.max() ?? 1, 1)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 8) {
                        // Barra
                        GeometryReader { geo in
                            VStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                AppTheme.accent,
                                                AppTheme.accent.opacity(0.7)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(height: animate ? geo.size.height * CGFloat(item.amount / maxAmount) : 0)
                                    .shadow(color: AppTheme.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                        .frame(height: 120)
                        
                        // Valor
                        Text(Formatters.currency.string(from: NSNumber(value: item.amount)) ?? "$0")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        
                        // Mes (abreviado)
                        Text(abbreviatedMonth(item.month))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(AppTheme.textTertiary)
                            .lineLimit(1)
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: animate)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                animate = true
            }
        }
    }
    
    private func abbreviatedMonth(_ month: String) -> String {
        let components = month.split(separator: " ")
        if components.count >= 1 {
            return String(components[0].prefix(3))
        }
        return month
    }
}

#Preview {
    ZStack {
        AppBackground()
        NeonCard {
            BarChartView(data: [
                ("Enero 2025", 25000),
                ("Febrero 2025", 32000),
                ("Marzo 2025", 28000),
                ("Abril 2025", 35000),
                ("Mayo 2025", 29000),
                ("Junio 2025", 31000)
            ])
            .frame(height: 180)
        }
        .padding()
    }
}

