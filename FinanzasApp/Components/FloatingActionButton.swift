//
//  FloatingActionButton.swift
//  FinanzasApp
//
//  Botón flotante con microinteracción (escala + glow), acorde a estilo minimalista.
//

import SwiftUI

struct FloatingActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(.body, design: .rounded).weight(.semibold))
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule(style: .continuous)
                    .fill(AppTheme.accent)
                    .shadow(color: AppTheme.accent.opacity(0.35), radius: 18, x: 0, y: 10)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.snappy(duration: 0.18), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    ZStack {
        AppBackground()
        FloatingActionButton(title: "Añadir", systemImage: "plus") {}
    }
}


