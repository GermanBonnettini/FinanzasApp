//
//  TicketViewModel.swift
//  FinanzasApp
//
//  ViewModel para manejar el estado del ticket escaneado (mock, preparado para OCR futuro).
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class TicketViewModel: ObservableObject {
    @Published var scannedImage: UIImage?
    @Published var detectedMovement: DetectedMovement?
    @Published var isProcessing: Bool = false
    
    // Mock: simula procesamiento y detección de ticket.
    func processTicket(image: UIImage) {
        isProcessing = true
        
        // Simular delay de procesamiento (OCR futuro aquí).
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isProcessing = false
            // Datos mockeados.
            self.detectedMovement = DetectedMovement(
                amount: 18500.0,
                date: Date(),
                category: .comida,
                title: "Supermercado",
                source: .ticket
            )
        }
    }
    
    func reset() {
        scannedImage = nil
        detectedMovement = nil
        isProcessing = false
    }
}

// Modelo para el movimiento detectado del ticket.
struct DetectedMovement: Identifiable, Equatable {
    let id = UUID()
    let amount: Double
    let date: Date
    let category: Category
    let title: String
    let source: TicketSource
}

enum TicketSource: Equatable {
    case ticket
    
    var icon: String { "📸" }
    var label: String { "Ticket" }
}

