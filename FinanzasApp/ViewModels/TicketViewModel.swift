//
//  TicketViewModel.swift
//  FinanzasApp
//

import Foundation
import SwiftUI
import Combine
import Vision

@MainActor
final class TicketViewModel: ObservableObject {
    @Published var scannedImage: UIImage?
    @Published var detectedText: String = ""
    @Published var detectedAmount: Double?
    @Published var isProcessing: Bool = false
    
    func processTicket(image: UIImage) {
        isProcessing = true
        scannedImage = image
        
        Task {
            await recognizeText(from: image)
        }
    }
    
    private func recognizeText(from image: UIImage) async {
        guard let cgImage = image.cgImage else {
            await MainActor.run {
                isProcessing = false
            }
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error en reconocimiento de texto: \(error.localizedDescription)")
                Task { @MainActor in
                    self.isProcessing = false
                }
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                Task { @MainActor in
                    self.isProcessing = false
                }
                return
            }
            
            var fullText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                fullText += topCandidate.string + "\n"
            }
            
            Task { @MainActor in
                self.detectedText = fullText
                self.detectedAmount = self.extractTotal(from: fullText)
                self.isProcessing = false
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Error al procesar imagen: \(error.localizedDescription)")
            await MainActor.run {
                isProcessing = false
            }
        }
    }
    
    private func extractTotal(from text: String) -> Double? {
        let lines = text.components(separatedBy: .newlines)
        
        // Buscar líneas que contengan palabras clave de total
        let totalKeywords = ["TOTAL", "TOT", "TOTAL A PAGAR", "TOTAL PAGAR", "SUBTOTAL", "IMPORTE"]
        
        for line in lines {
            let upperLine = line.uppercased().trimmingCharacters(in: .whitespaces)
            
            // Verificar si la línea contiene alguna palabra clave
            let containsKeyword = totalKeywords.contains { upperLine.contains($0) }
            
            if containsKeyword {
                let numbers = extractNumbers(from: line)
                // Tomar el último número de la línea (generalmente es el total)
                if let total = numbers.last, total > 0 {
                    return total
                }
            }
        }
        
        // Si no se encuentra "TOTAL", buscar el número más grande al final del texto
        // (los tickets suelen tener el total al final)
        let allNumbers = extractNumbers(from: text)
        if !allNumbers.isEmpty {
            // Filtrar números razonables (mayores a 10 para evitar precios individuales pequeños)
            let reasonableNumbers = allNumbers.filter { $0 >= 10 }
            if let largestNumber = reasonableNumbers.max() {
                // Si hay varios números grandes, tomar el último (probablemente el total)
                if let lastReasonable = reasonableNumbers.last, lastReasonable >= 100 {
                    return lastReasonable
                }
                return largestNumber
            }
        }
        
        return nil
    }
    
    private func extractNumbers(from text: String) -> [Double] {
        var numbers: [Double] = []
        
        // Patrón para encontrar números con o sin separadores de miles
        let pattern = #"(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?|\d+[.,]\d{2,})"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsString = text as NSString
        let results = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in results ?? [] {
            let matchString = nsString.substring(with: match.range)
            // Limpiar el string: quitar puntos de miles, convertir coma a punto
            let cleaned = matchString
                .replacingOccurrences(of: ".", with: "", options: [], range: nil)
                .replacingOccurrences(of: ",", with: ".")
            
            if let number = Double(cleaned) {
                numbers.append(number)
            }
        }
        
        return numbers
    }
    
    func reset() {
        scannedImage = nil
        detectedText = ""
        detectedAmount = nil
        isProcessing = false
    }
}

