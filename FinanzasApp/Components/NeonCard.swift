//
//  NeonCard.swift
//  FinanzasApp
//

import SwiftUI

struct NeonCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(AppTheme.surface.opacity(0.35))
                    .overlay(RoundedRectangle(cornerRadius: AppTheme.cardRadius).strokeBorder(.white.opacity(0.06), lineWidth: 1))
                    .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 8)
            )
    }
}

#Preview {
    ZStack {
        AppBackground()
        NeonCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Card de ejemplo")
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.headline)
                Text("Espacio en blanco, borde sutil y sombra suave.")
                    .foregroundStyle(AppTheme.textSecondary)
                    .font(.subheadline)
            }
        }
        .padding()
    }
}


