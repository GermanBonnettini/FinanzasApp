//
//  InboxView.swift
//  FinanzasApp
//
//  Pantalla de inbox para confirmar/editar/descartar movimientos detectados de tickets.
//

import SwiftUI

struct InboxView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: AppViewModel
    @ObservedObject var ticketVM: TicketViewModel
    
    @State private var editedAmount: String = ""
    @State private var editedTitle: String = ""
    @State private var editedCategory: Category = .comida
    @State private var editedDate: Date = Date()
    @State private var showEditSheet = false
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    
                    if let amount = ticketVM.detectedAmount {
                        detectionCard(amount: amount)
                        actionButtons
                    } else {
                        emptyState
                    }
                    
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            if let amount = ticketVM.detectedAmount {
                editedAmount = Formatters.currency.string(from: NSNumber(value: amount)) ?? ""
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditMovementSheet(
                amount: $editedAmount,
                title: $editedTitle,
                category: $editedCategory,
                date: $editedDate
            )
            .preferredColorScheme(.dark)
        }
    }
    
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Inbox")
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                Text("Confirma o edita el gasto detectado")
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
    
    private var emptyState: some View {
        NeonCard {
            VStack(spacing: 16) {
                Text("No se detectó información del ticket")
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                Text("Intenta tomar otra foto con mejor iluminación")
                    .foregroundStyle(AppTheme.textTertiary)
                    .font(.subheadline)
            }
            .padding(.vertical, 20)
        }
    }
    
    private func detectionCard(amount: Double) -> some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 6) {
                    Text("📸")
                    Text("Ticket")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(AppTheme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(AppTheme.accent.opacity(0.15)))
                
                Divider().overlay(.white.opacity(0.08))
                
                VStack(alignment: .leading, spacing: 14) {
                    detailRow(label: "Monto detectado", value: Formatters.currency.string(from: NSNumber(value: amount)) ?? "$0")
                    detailRow(label: "Fecha", value: Formatters.date.string(from: editedDate))
                    detailRow(label: "Categoría", value: editedCategory.title, icon: editedCategory.systemImage)
                    detailRow(label: "Descripción", value: editedTitle.isEmpty ? "Sin descripción" : editedTitle)
                }
            }
        }
    }
    
    private func detailRow(label: String, value: String, icon: String? = nil) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .foregroundStyle(AppTheme.textTertiary)
                .font(.caption)
                .frame(width: 80, alignment: .leading)
            
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Text(value)
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(.body, design: .rounded).weight(.semibold))
            }
            
            Spacer()
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Confirmar
            Button {
                confirmMovement()
            } label: {
                Text("Confirmar")
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.controlRadius)
                            .fill(AppTheme.accent)
                            .shadow(color: AppTheme.accent.opacity(0.25), radius: 18, x: 0, y: 10)
                    )
            }
            .buttonStyle(.plain)
            
            HStack(spacing: 12) {
                // Editar
                Button {
                    showEditSheet = true
                } label: {
                    Text("Editar")
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.controlRadius)
                                .fill(.ultraThinMaterial)
                                .overlay(RoundedRectangle(cornerRadius: AppTheme.controlRadius).fill(AppTheme.surface2.opacity(0.6)))
                                .overlay(RoundedRectangle(cornerRadius: AppTheme.controlRadius).strokeBorder(.white.opacity(0.08), lineWidth: 1))
                        )
                }
                .buttonStyle(.plain)
                
                // Descartar
                Button {
                    discardMovement()
                } label: {
                    Text("Descartar")
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundStyle(AppTheme.expense)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.controlRadius)
                                .fill(.ultraThinMaterial)
                                .overlay(RoundedRectangle(cornerRadius: AppTheme.controlRadius).fill(AppTheme.surface2.opacity(0.6)))
                                .overlay(RoundedRectangle(cornerRadius: AppTheme.controlRadius).strokeBorder(AppTheme.expense.opacity(0.3), lineWidth: 1))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func confirmMovement() {
        guard let amount = ticketVM.detectedAmount else { return }
        
        let movement = Movement(
            type: .expense,
            category: editedCategory,
            title: editedTitle.isEmpty ? "Ticket" : editedTitle,
            amount: parseAmount(editedAmount) ?? amount,
            date: editedDate
        )
        
        vm.add(movement)
        ticketVM.reset()
        dismiss()
    }
    
    private func discardMovement() {
        ticketVM.reset()
        dismiss()
    }
    
    private func parseAmount(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces))
    }
}

// Sheet para editar el movimiento detectado
private struct EditMovementSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var amount: String
    @Binding var title: String
    @Binding var category: Category
    @Binding var date: Date
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Editar movimiento")
                        .foregroundStyle(AppTheme.textPrimary)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .padding(.top, 8)
                    
                    field(title: "Monto") {
                        TextField("0", text: $amount)
                            .keyboardType(.numberPad)
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    
                    field(title: "Descripción") {
                        TextField("Ej: Supermercado...", text: $title)
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    
                    field(title: "Categoría") {
                        Picker("", selection: $category) {
                            ForEach(Category.allCases) { cat in
                                HStack {
                                    Image(systemName: cat.systemImage)
                                    Text(cat.title)
                                }
                                .tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppTheme.accent)
                    }
                    
                    field(title: "Fecha") {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                            .tint(AppTheme.accent)
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Guardar cambios")
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: AppTheme.controlRadius).fill(AppTheme.accent))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
        }
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
                    RoundedRectangle(cornerRadius: AppTheme.controlRadius)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: AppTheme.controlRadius).fill(AppTheme.surface2.opacity(0.6)))
                        .overlay(RoundedRectangle(cornerRadius: AppTheme.controlRadius).strokeBorder(.white.opacity(0.08), lineWidth: 1))
                )
        }
    }
}

#Preview {
    InboxView(ticketVM: TicketViewModel())
        .environmentObject(AppViewModel.preview)
}


