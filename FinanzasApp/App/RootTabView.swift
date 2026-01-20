//
//  RootTabView.swift
//  FinanzasApp
//
//  Navegación principal (Dashboard + Movimientos) con estética oscura minimalista.
//

import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var vm: AppViewModel
    @Namespace private var ns

    @State private var selectedTab: Tab = .dashboard
    @State private var isPresentingAdd = false
    
    init() {
        // Usaremos una barra personalizada; ocultamos la TabBar nativa.
        UITabBar.appearance().isHidden = true
    }

    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case movements = "Movimientos"
        case statistics = "Estadísticas"
        case camera = "Cámara"

        var systemImage: String {
            switch self {
            case .dashboard: return "chart.pie.fill"
            case .movements: return "list.bullet"
            case .statistics: return "chart.bar.fill"
            case .camera: return "camera.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                DashboardView(namespace: ns)
                    .tag(Tab.dashboard)

                MovementsListView(namespace: ns)
                    .tag(Tab.movements)
                
                StatisticsView(namespace: ns)
                    .tag(Tab.statistics)
                
                CameraView(namespace: ns)
                    .tag(Tab.camera)
            }
            .tint(AppTheme.accent)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .safeAreaInset(edge: .bottom) {
            CustomBottomBar(
                selectedTab: $selectedTab,
                onAdd: { isPresentingAdd = true }
            )
            .padding(.horizontal, 18)
            .padding(.bottom, 10)
        }
        .fullScreenCover(isPresented: $isPresentingAdd) {
            AddMovementView()
                .environmentObject(vm)
                .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(AppViewModel.preview)
}

private struct CustomBottomBar: View {
    @Binding var selectedTab: RootTabView.Tab
    let onAdd: () -> Void
    
    @State private var isPressed = false

    var body: some View {
        ZStack {
            // Barra transparente con material ultra delgado
            HStack(spacing: 12) {
                tabButton(.dashboard)
                tabButton(.movements)
                addButton
                tabButton(.camera)
                tabButton(.statistics)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        }
    }

    private func tabButton(_ tab: RootTabView.Tab) -> some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        } label: {
            ZStack {
                // Indicador de selección con animación
                if selectedTab == tab {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.2))
                        .overlay(
                            Circle()
                                .strokeBorder(AppTheme.accent.opacity(0.5), lineWidth: 1.5)
                        )
                        .transition(.scale.combined(with: .opacity))
                }
                
                Image(systemName: tabIcon(for: tab, selected: selectedTab == tab))
                    .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .medium))
                    .foregroundStyle(selectedTab == tab ? AppTheme.accent : AppTheme.textTertiary)
                    .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
            }
            .frame(width: 44, height: 44)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.rawValue)
    }
    
    private var addButton: some View {
        Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
            onAdd()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(AppTheme.accent)
                        .shadow(color: AppTheme.accent.opacity(0.4), radius: 16, x: 0, y: 8)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Añadir movimiento")
    }

    private func tabIcon(for tab: RootTabView.Tab, selected: Bool) -> String {
        switch tab {
        case .dashboard:
            return selected ? "chart.pie.fill" : "chart.pie"
        case .movements:
            return selected ? "list.bullet.rectangle.fill" : "list.bullet.rectangle"
        case .statistics:
            return selected ? "chart.bar.fill" : "chart.bar"
        case .camera:
            return selected ? "camera.fill" : "camera"
        }
    }
}


