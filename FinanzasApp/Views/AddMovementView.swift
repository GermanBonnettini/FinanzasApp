//
//  AddMovementView.swift
//  FinanzasApp
//
//  Pantalla 3: modal para agregar movimiento con inputs minimalistas y animaciones sutiles.
//

import SwiftUI

struct AddMovementView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: AppViewModel
    @Namespace private var ns

    @State private var type: MovementType = .expense
    @State private var category: Category = .comida
    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var date: Date = .now
    @State private var isRecurring: Bool = false
    
    // Categorías disponibles según el tipo
    private var availableCategories: [Category] {
        Category.categories(for: type)
    }

    @FocusState private var isAmountFocused: Bool
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                        .padding(.top, 8)

                    NeonCard {
                        VStack(alignment: .leading, spacing: 18) {
                            typeSelector
                            
                            recurringToggle

                            HStack(spacing: 12) {
                                field(title: "Monto") {
                                    TextField("0", text: $amountText)
                                        .keyboardType(.numberPad)
                                        .focused($isAmountFocused)
                                        .font(.system(.title3, design: .rounded).weight(.semibold))
                                        .foregroundStyle(AppTheme.textPrimary)
                                }

                                field(title: "Fecha") {
                                    DatePicker("", selection: $date, displayedComponents: .date)
                                        .labelsHidden()
                                        .tint(AppTheme.accent)
                                }
                            }

                            field(title: "Descripción (opcional)") {
                                TextField("Ej: Supermercado, Taxi, Nómina…", text: $title)
                                    .focused($isTitleFocused)
                                    .foregroundStyle(AppTheme.textPrimary)
                            }

                            categoryGrid
                        }
                    }

                    // Espacio para el botón fijo
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom) {
                Button {
                    submit()
                } label: {
                    Text("Guardar")
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(.black)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                                .fill(AppTheme.accent)
                                .shadow(color: AppTheme.accent.opacity(0.25), radius: 18, x: 0, y: 10)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canSubmit)
                .opacity(canSubmit ? 1 : 0.45)
                .scaleEffect(canSubmit ? 1 : 0.99)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .background(
                    LinearGradient(
                        colors: [
                            AppTheme.background.opacity(0.95),
                            AppTheme.background.opacity(0.98)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blur(radius: 20)
                )
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isAmountFocused = true
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Nuevo movimiento")
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                Text(type == .expense ? "Registra un gasto" : "Registra un ingreso")
                    .foregroundStyle(AppTheme.textTertiary)
                    .font(.subheadline)
            }
            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(Circle().strokeBorder(.white.opacity(0.08), lineWidth: 1))
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var typeSelector: some View {
        HStack(spacing: 10) {
            typePill(.expense, title: "Gasto", color: AppTheme.expense)
            typePill(.income, title: "Ingreso", color: AppTheme.income)
            Spacer()
        }
    }

    private func typePill(_ t: MovementType, title: String, color: Color) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                type = t
                let newCategories = Category.categories(for: t)
                if let firstCategory = newCategories.first {
                    category = firstCategory
                }
            }
        } label: {
            ZStack {
                if type == t {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(color.opacity(0.18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(color.opacity(0.45), lineWidth: 1)
                        )
                        .matchedGeometryEffect(id: "type-pill", in: ns)
                }
                Text(title)
                    .foregroundStyle(type == t ? AppTheme.textPrimary : AppTheme.textSecondary)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var recurringToggle: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                isRecurring.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isRecurring ? AppTheme.accent.opacity(0.2) : AppTheme.surface2.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(isRecurring ? AppTheme.accent.opacity(0.5) : .white.opacity(0.08), lineWidth: isRecurring ? 1.5 : 1)
                        )
                    
                    Image(systemName: isRecurring ? "repeat.circle.fill" : "repeat.circle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(isRecurring ? AppTheme.accent : AppTheme.textTertiary)
                }
                .frame(width: 44, height: 44)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(type == .expense ? "Gasto recurrente" : "Ingreso recurrente")
                        .foregroundStyle(AppTheme.textPrimary)
                        .font(.system(.body, design: .rounded).weight(.semibold))
                    Text(type == .expense ? "Como suscripciones o pagos mensuales" : "Como sueldo o ingresos fijos")
                        .foregroundStyle(AppTheme.textTertiary)
                        .font(.caption)
                }
                
                Spacer()
                
                Toggle("", isOn: $isRecurring)
                    .tint(AppTheme.accent)
                    .labelsHidden()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                            .fill(AppTheme.surface2.opacity(0.6))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func field<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundStyle(AppTheme.textTertiary)
                .font(.caption.weight(.medium))
            content()
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                                .fill(AppTheme.surface2.opacity(0.6))
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                )
        }
    }

    private var categoryGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categoría")
                .foregroundStyle(AppTheme.textTertiary)
                .font(.caption.weight(.medium))

            let cols = [GridItem(.adaptive(minimum: 90), spacing: 12)]
            LazyVGrid(columns: cols, spacing: 12) {
                ForEach(availableCategories) { cat in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            category = cat
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(AppTheme.surface2.opacity(0.6))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                                )

                            if category == cat {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(AppTheme.accent.opacity(0.85), lineWidth: 2)
                                    .matchedGeometryEffect(id: "cat-outline", in: ns)
                            }

                            VStack(spacing: 8) {
                                Image(systemName: cat.systemImage)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(category == cat ? AppTheme.accent : AppTheme.textSecondary)
                                    .matchedGeometryEffect(id: "cat-icon-\(cat.id)", in: ns, isSource: category == cat)

                                Text(cat.title)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(category == cat ? AppTheme.textPrimary : AppTheme.textSecondary)
                                    .lineLimit(1)
                            }
                            .padding(.vertical, 12)
                        }
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .scaleEffect(category == cat ? 1.02 : 1.0)
                }
            }
        }
    }

    private var canSubmit: Bool {
        parsedAmount > 0
    }

    private var parsedAmount: Double {
        // Acepta números con puntos/espacios de forma tolerante.
        let cleaned = amountText
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(cleaned) ?? 0
    }

    private func submit() {
        let movement = Movement(
            type: type,
            category: category,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: parsedAmount,
            date: date,
            isRecurring: isRecurring
        )
        vm.add(movement)
        dismiss()
    }
}

#Preview {
    AddMovementView()
        .environmentObject(AppViewModel.preview)
}


