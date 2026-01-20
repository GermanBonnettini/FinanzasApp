//
//  CalendarHeatmapView.swift
//  FinanzasApp
//
//  Calendario con colores para mostrar días positivos (verde) y negativos (rojo).
//

import SwiftUI

struct CalendarHeatmapView: View {
    let dailyBalances: [Date: Double]
    let calendar: Calendar
    
    @State private var selectedDate: Date?
    
    private var currentMonth: Date {
        Date()
    }
    
    private var monthDays: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
    }
    
    private var firstWeekday: Int {
        guard let firstDay = monthDays.first else { return 0 }
        return calendar.component(.weekday, from: firstDay) - 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header con mes
            HStack {
                Text(Formatters.monthYear.string(from: currentMonth).capitalized)
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                Spacer()
            }
            
            // Días de la semana
            HStack(spacing: 4) {
                ForEach(["D", "L", "M", "X", "J", "V", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(AppTheme.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Grid de días
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                // Espacios vacíos para alinear el primer día
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Color.clear
                        .frame(height: 36)
                }
                
                // Días del mes
                ForEach(monthDays, id: \.self) { date in
                    dayCell(date: date)
                }
            }
            
            // Leyenda
            HStack(spacing: 16) {
                legendItem(color: AppTheme.income.opacity(0.6), label: "Día positivo")
                legendItem(color: AppTheme.expense.opacity(0.6), label: "Día negativo")
                legendItem(color: AppTheme.surface2, label: "Sin movimientos")
            }
            .padding(.top, 8)
        }
    }
    
    private func dayCell(date: Date) -> some View {
        let balance = dailyBalances[calendar.startOfDay(for: date)] ?? 0
        let isPositive = balance > 0
        let hasMovements = balance != 0
        
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(
                        selectedDate == date ? .black : (hasMovements ? AppTheme.textPrimary : AppTheme.textTertiary)
                    )
                
                if hasMovements {
                    Circle()
                        .fill(isPositive ? AppTheme.income.opacity(0.7) : AppTheme.expense.opacity(0.7))
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(AppTheme.surface2)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 36, height: 36)
            .background(RoundedRectangle(cornerRadius: 8).fill(selectedDate == date ? AppTheme.accent.opacity(0.3) : Color.clear))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(selectedDate == date ? AppTheme.accent : Color.clear, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption2)
                .foregroundStyle(AppTheme.textTertiary)
        }
    }
}

#Preview {
    ZStack {
        AppBackground()
        NeonCard {
            CalendarHeatmapView(
                dailyBalances: [
                    Calendar.current.startOfDay(for: Date()): 5000,
                    Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()): -2000
                ],
                calendar: .current
            )
        }
        .padding()
    }
}

