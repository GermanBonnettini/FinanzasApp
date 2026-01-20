//
//  MovementsListView.swift
//  FinanzasApp
//
//  Pantalla 2: lista de ingresos y gastos con animación al aparecer/desaparecer.
//

import SwiftUI

struct MovementsListView: View {
    @EnvironmentObject private var vm: AppViewModel
    let namespace: Namespace.ID

    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                
                if vm.monthMovements.isEmpty {
                    ScrollView {
                        NeonCard {
                            emptyState
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                    }
                } else {
                    List {
                        ForEach(vm.monthMovements) { m in
                            NeonCard {
                                MovementRowView(movement: m, namespace: namespace)
                                    .padding(.vertical, 4)
                            }
                            .listRowInsets(EdgeInsets(top: 7, leading: 16, bottom: 7, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .scale(scale: 0.96).combined(with: .opacity)
                            ))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    vm.delete(id: m.id)
                                } label: {
                                    Label("Eliminar", systemImage: "trash.fill")
                                }
                                .tint(AppTheme.expense)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    // Opción para editar en el futuro
                                } label: {
                                    Label("Editar", systemImage: "pencil")
                                }
                                .tint(AppTheme.accent)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.monthMovements)
                }
            }
        }
        .navigationTitle("")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Movimientos")
                .foregroundStyle(AppTheme.textPrimary)
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
            Text(vm.monthTitle)
                .foregroundStyle(AppTheme.textTertiary)
                .font(.subheadline)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Sin movimientos este mes", systemImage: "sparkles")
                .foregroundStyle(AppTheme.textPrimary)
                .font(.system(.body, design: .rounded).weight(.semibold))
            Text("Toca “Añadir” para registrar tu primer ingreso o gasto.")
                .foregroundStyle(AppTheme.textSecondary)
                .font(.subheadline)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    MovementsListView(namespace: Namespace().wrappedValue)
        .environmentObject(AppViewModel.preview)
}


