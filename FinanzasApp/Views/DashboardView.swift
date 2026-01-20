//
//  DashboardView.swift
//  FinanzasApp
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var vm: AppViewModel
    let namespace: Namespace.ID

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    balanceCard
                    categoryCard
                    if !vm.monthExpenseByCategory.isEmpty {
                        topCategoriesCard
                    }
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("")
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dashboard")
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                Text("Minimal, rápido y claro.")
                    .foregroundStyle(AppTheme.textTertiary)
                    .font(.subheadline)
            }
            Spacer()
            Text(vm.monthTitle)
                .foregroundStyle(AppTheme.textSecondary)
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Capsule().fill(AppTheme.surface))
                .overlay(Capsule().strokeBorder(.white.opacity(0.06), lineWidth: 1))
        }
    }
    
    private var balanceCard: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Balance total")
                    .foregroundStyle(AppTheme.textSecondary)
                    .font(.footnote)
                Text(currency(vm.totalBalance))
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                Divider().overlay(.white.opacity(0.08))
                HStack(spacing: 14) {
                    metricPill("Ingresos", currency(vm.monthIncome), AppTheme.income)
                    metricPill("Gastos", currency(vm.monthExpense), AppTheme.expense)
                    Spacer()
                }
            }
        }
    }
    
    private var categoryCard: some View {
        NeonCard {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Gastos por categoría")
                        .foregroundStyle(AppTheme.textSecondary)
                        .font(.footnote)
                    Text(vm.monthTitle)
                        .foregroundStyle(AppTheme.textPrimary)
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                    Text("Balance del mes: \(currency(vm.monthBalance))")
                        .foregroundStyle(AppTheme.textTertiary)
                        .font(.subheadline)
                }
                Spacer()
                DonutChartView(slices: donutSlices)
                    .frame(width: 140, height: 140)
            }
        }
    }
    
    private var topCategoriesCard: some View {
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
    
    private var donutSlices: [DonutSlice] {
        let categories = vm.monthExpenseByCategory
        guard !categories.isEmpty else {
            return [DonutSlice(category: .otros, value: 1, color: AppTheme.surface2)]
        }
        let palette: [Color] = [
            AppTheme.accent, AppTheme.accent2, AppTheme.expense.opacity(0.9),
            AppTheme.accent.opacity(0.6), AppTheme.accent2.opacity(0.6), AppTheme.expense.opacity(0.6)
        ]
        return categories.enumerated().map { idx, pair in
            DonutSlice(category: pair.0, value: pair.1, color: palette[idx % palette.count])
        }
    }
    
    private func metricPill(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .foregroundStyle(AppTheme.textTertiary)
                .font(.caption)
            Text(value)
                .foregroundStyle(color)
                .font(.system(.body, design: .rounded).weight(.semibold))
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 14).fill(AppTheme.surface2))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.06), lineWidth: 1))
    }
    
    private func currency(_ value: Double) -> String {
        Formatters.currency.string(from: NSNumber(value: value)) ?? "$0"
    }
}

#Preview {
    DashboardView(namespace: Namespace().wrappedValue)
        .environmentObject(AppViewModel.preview)
}


