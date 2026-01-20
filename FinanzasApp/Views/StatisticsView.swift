//
//  StatisticsView.swift
//  FinanzasApp
//
//  Pantalla de estadísticas completas: gráficos, resúmenes y calendario.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var vm: AppViewModel
    let namespace: Namespace.ID
    
    @State private var selectedPeriod: Period = .allTime
    
    enum Period: String, CaseIterable {
        case month = "Mes actual"
        case allTime = "Todo el tiempo"
    }
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    
                    // Selector de período
                    periodSelector
                    
                    // Resumen de gastos únicos vs recurrentes
                    uniqueVsRecurringCard
                    
                    // Gráfico de barras mensual
                    monthlyExpensesCard
                    
                    // Calendario de calor
                    calendarCard
                    
                    // Top categorías
                    topCategoriesCard
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("")
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Estadísticas")
                .foregroundStyle(AppTheme.textPrimary)
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
            Text("Análisis detallado de tus finanzas")
                .foregroundStyle(AppTheme.textTertiary)
                .font(.subheadline)
        }
    }
    
    private var periodSelector: some View {
        HStack(spacing: 10) {
            ForEach(Period.allCases, id: \.self) { period in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundStyle(selectedPeriod == period ? .black : AppTheme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedPeriod == period ? AppTheme.accent : AppTheme.surface2.opacity(0.6))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var uniqueVsRecurringCard: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Gastos únicos vs recurrentes")
                    .foregroundStyle(AppTheme.textSecondary)
                    .font(.footnote)
                
                let data = selectedPeriod == .month ? vm.monthUniqueVsRecurring : vm.totalUniqueVsRecurring
                let total = data.unique + data.recurring
                
                if total > 0 {
                    HStack(spacing: 20) {
                        // Gráfico donut
                        DonutChartView(slices: [
                            DonutSlice(category: .otros, value: data.unique, color: AppTheme.accent),
                            DonutSlice(category: .suscripciones, value: data.recurring, color: AppTheme.accent2)
                        ])
                        .frame(width: 120, height: 120)
                        
                        // Leyenda y valores
                        VStack(alignment: .leading, spacing: 12) {
                            legendRow(
                                color: AppTheme.accent,
                                label: "Únicos",
                                value: data.unique,
                                percentage: total > 0 ? (data.unique / total) * 100 : 0
                            )
                            
                            legendRow(
                                color: AppTheme.accent2,
                                label: "Recurrentes",
                                value: data.recurring,
                                percentage: total > 0 ? (data.recurring / total) * 100 : 0
                            )
                        }
                        
                        Spacer()
                    }
                } else {
                    Text("No hay gastos registrados")
                        .foregroundStyle(AppTheme.textTertiary)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                }
            }
        }
    }
    
    private func legendRow(color: Color, label: String, value: Double, percentage: Double) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                
                HStack(spacing: 6) {
                    Text(Formatters.currency.string(from: NSNumber(value: value)) ?? "$0")
                        .foregroundStyle(AppTheme.textSecondary)
                        .font(.caption)
                    
                    Text("(\(Int(percentage))%)")
                        .foregroundStyle(AppTheme.textTertiary)
                        .font(.caption2)
                }
            }
        }
    }
    
    private var monthlyExpensesCard: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Gastos por mes")
                    .foregroundStyle(AppTheme.textSecondary)
                    .font(.footnote)
                
                Text("Últimos 6 meses")
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                
                if !vm.monthlyExpenses.isEmpty {
                    BarChartView(data: vm.monthlyExpenses)
                        .frame(height: 180)
                        .padding(.top, 8)
                } else {
                    Text("No hay datos suficientes")
                        .foregroundStyle(AppTheme.textTertiary)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                }
            }
        }
    }
    
    private var calendarCard: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Calendario de balance")
                    .foregroundStyle(AppTheme.textSecondary)
                    .font(.footnote)
                
                Text("Días positivos y negativos")
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                
                CalendarHeatmapView(dailyBalances: calculateDailyBalances(), calendar: .current)
                    .padding(.top, 8)
            }
        }
    }
    
    private func calculateDailyBalances() -> [Date: Double] {
        let calendar = Calendar.current
        let now = Date()
        var dailyBalances: [Date: Double] = [:]
        
        // Obtener todos los días del mes actual con movimientos
        if let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
           let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) {
            var currentDate = monthStart
            while currentDate < monthEnd {
                let dayStart = calendar.startOfDay(for: currentDate)
                dailyBalances[dayStart] = vm.dailyBalance(for: currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
        }
        
        return dailyBalances
    }
    
    private var topCategoriesCard: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Top categorías")
                    .foregroundStyle(AppTheme.textSecondary)
                    .font(.footnote)
                
                Text("Categorías con más gastos")
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                
                if !vm.topCategories.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(Array(vm.topCategories.enumerated()), id: \.offset) { index, item in
                            HStack(spacing: 12) {
                                // Ranking
                                Text("\(index + 1)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(AppTheme.textTertiary)
                                    .frame(width: 24, height: 24)
                                    .background(
                                        Circle()
                                            .fill(AppTheme.surface2)
                                    )
                                
                                // Icono y nombre
                                HStack(spacing: 10) {
                                    Image(systemName: item.0.systemImage)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(AppTheme.accent)
                                        .frame(width: 24)
                                    
                                    Text(item.0.title)
                                        .foregroundStyle(AppTheme.textPrimary)
                                        .font(.system(.body, design: .rounded).weight(.semibold))
                                }
                                
                                Spacer()
                                
                                // Valor
                                Text(Formatters.currency.string(from: NSNumber(value: item.1)) ?? "$0")
                                    .foregroundStyle(AppTheme.expense)
                                    .font(.system(.body, design: .rounded).weight(.semibold))
                            }
                            .padding(.vertical, 4)
                            
                            if index < vm.topCategories.count - 1 {
                                Divider().overlay(.white.opacity(0.08))
                            }
                        }
                    }
                    .padding(.top, 8)
                } else {
                    Text("No hay categorías registradas")
                        .foregroundStyle(AppTheme.textTertiary)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                }
            }
        }
    }
}

#Preview {
    StatisticsView(namespace: Namespace().wrappedValue)
        .environmentObject(AppViewModel.preview)
}

