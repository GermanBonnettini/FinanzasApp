//
//  AppBackground.swift
//  FinanzasApp
//
//  Background oscuro minimalista con un glow sutil (sin recargar).
//

import SwiftUI

struct AppBackground: View {
    var body: some View {
        ZStack {
            // Base (simple): mantiene legibilidad y deja espacio al tornasolado.
            Color.black

            // Tornasolado simple (sin blend modes): visible y consistente en tabs.
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.08, blue: 0.12),
                    Color(red: 0.03, green: 0.04, blue: 0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [AppTheme.accent2.opacity(0.35), .clear],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 420
            )
            .blur(radius: 22)

            RadialGradient(
                colors: [AppTheme.accent.opacity(0.30), .clear],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 520
            )
            .blur(radius: 26)

            RadialGradient(
                colors: [Color(red: 0.78, green: 0.36, blue: 1.00).opacity(0.22), .clear],
                center: .center,
                startRadius: 10,
                endRadius: 620
            )
            .blur(radius: 34)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    AppBackground()
}


