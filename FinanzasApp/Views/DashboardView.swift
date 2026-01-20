//
//  DashboardView.swift
//  FinanzasApp
//
//  Pantalla 1: balance total, resumen mensual y gráfico simple animado.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var vm: AppViewModel
    let namespace: Namespace.ID
    
    // Cachear valores para evitar recálculos
    @State private var cachedDonutSlices: [DonutSlice] = []
    @State private var cachedTotalBalance: String = "$0"
    @State private var cachedMonthIncome: String = "$0"
    @State private var cachedMonthExpense: String = "$0"
    @State private var cachedMonthBalance: String = "$0"

    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    NeonCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Balance total")
                                .foregroundStyle(AppTheme.textSecondary)
                                .font(.footnote)

                            Text(cachedTotalBalance)
                                .foregroundStyle(AppTheme.textPrimary)
                                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)

                            Divider().overlay(.white.opacity(0.08))

                            HStack(spacing: 14) {
                                metricPill(title: "Ingresos", valueString: cachedMonthIncome, color: AppTheme.income)
                                metricPill(title: "Gastos", valueString: cachedMonthExpense, color: AppTheme.expense)
                                Spacer()
                            }
                        }
                    }

                    NeonCard {
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Gastos por categoría")
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .font(.footnote)

                                Text(vm.monthTitle)
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .font(.system(.title3, design: .rounded).weight(.semibold))
                                    .lineLimit(1)

                                Text("Balance del mes: \(cachedMonthBalance)")
                                    .foregroundStyle(AppTheme.textTertiary)
                                    .font(.subheadline)
                                    .lineLimit(1)
                            }

                            Spacer(minLength: 8)

                            DonutChartView(slices: cachedDonutSlices)
                                .frame(width: 140, height: 140)
                        }
                    }

                    if !vm.monthExpenseByCategory.isEmpty {
                        NeonCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Top categorías")
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .font(.footnote)

                                ForEach(vm.monthExpenseByCategory.prefix(4), id: \.0.id) { cat, value in
                                    HStack {
                                        Label(cat.title, systemImage: cat.systemImage)
                                            .foregroundStyle(AppTheme.textPrimary)
                                            .font(.system(.body, design: .rounded).weight(.semibold))
                                        Spacer()
                                        Text(currency(value))
                                            .foregroundStyle(AppTheme.expense)
                                            .font(.system(.body, design: .rounded).weight(.semibold))
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("")
        .onChange(of: vm.totalBalance) { _, newValue in
            cachedTotalBalance = currency(newValue)
        }
        .onChange(of: vm.monthIncome) { _, newValue in
            cachedMonthIncome = currency(newValue)
        }
        .onChange(of: vm.monthExpense) { _, newValue in
            cachedMonthExpense = currency(newValue)
        }
        .onChange(of: vm.monthBalance) { _, newValue in
            cachedMonthBalance = currency(newValue)
        }
        .onChange(of: vm.monthExpenseByCategory.map(\.1)) { _, _ in
            updateDonutSlices()
        }
        .onChange(of: vm.selectedMonth) { _, _ in
            updateAllCachedValues()
        }
        .onAppear {
            updateAllCachedValues()
        }
    }
    
    private func updateAllCachedValues() {
        cachedTotalBalance = currency(vm.totalBalance)
        cachedMonthIncome = currency(vm.monthIncome)
        cachedMonthExpense = currency(vm.monthExpense)
        cachedMonthBalance = currency(vm.monthBalance)
        updateDonutSlices()
    }
    
    private func updateDonutSlices() {
        let base = vm.monthExpenseByCategory
        if base.isEmpty {
            cachedDonutSlices = [
                DonutSlice(category: .otros, value: 1, color: AppTheme.surface2)
            ]
            return
        }

        let palette: [Color] = [
            AppTheme.accent,
            AppTheme.accent2,
            AppTheme.expense.opacity(0.9),
            AppTheme.accent.opacity(0.6),
            AppTheme.accent2.opacity(0.6),
            AppTheme.expense.opacity(0.6),
        ]

        cachedDonutSlices = base.enumerated().map { idx, pair in
            DonutSlice(category: pair.0, value: pair.1, color: palette[idx % palette.count])
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dashboard")
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))

                Text("Minimal, rápido y claro.")
                    .foregroundStyle(AppTheme.textTertiary)
                    .font(.subheadline)
            }
            Spacer()

            // Selector de mes (ligero; listo para evolucionar a un picker).
            Text(vm.monthTitle)
                .foregroundStyle(AppTheme.textSecondary)
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous).fill(AppTheme.surface)
                )
                .overlay(Capsule(style: .continuous).strokeBorder(.white.opacity(0.06), lineWidth: 1))
        }
    }

    private func metricPill(title: String, valueString: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .foregroundStyle(AppTheme.textTertiary)
                .font(.caption)
            Text(valueString)
                .foregroundStyle(color)
                .font(.system(.body, design: .rounded).weight(.semibold))
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous).fill(AppTheme.surface2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func currency(_ value: Double) -> String {
        Formatters.currency.string(from: NSNumber(value: value)) ?? "$0"
    }
}

#Preview {
    DashboardView(namespace: Namespace().wrappedValue)
        .environmentObject(AppViewModel.preview)
}


