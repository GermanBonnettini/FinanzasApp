//
//  ContentView.swift
//  FinanzasApp
//
//  Created by H4MM3R-9 on 16/12/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appVM = AppViewModel()

    var body: some View {
        RootTabView()
            .environmentObject(appVM)
            // Forzamos el look oscuro para evitar fondos “system” claros en ciertas jerarquías.
            .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
