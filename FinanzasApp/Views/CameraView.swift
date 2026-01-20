//
//  CameraView.swift
//  FinanzasApp
//
//  Pantalla de cámara para escanear tickets usando PhotosUI (nativo SwiftUI).
//

import SwiftUI
import PhotosUI

struct CameraView: View {
    @EnvironmentObject private var vm: AppViewModel
    @StateObject private var ticketVM = TicketViewModel()
    let namespace: Namespace.ID
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showAddMovement = false
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 24) {
                header
                
                if ticketVM.isProcessing {
                    processingView
                } else if selectedImage == nil {
                    cameraPrompt
                } else {
                    previewView
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                    ticketVM.processTicket(image: image)
                }
            }
        }
        .onChange(of: ticketVM.isProcessing) { _, isProcessing in
            if !isProcessing && ticketVM.detectedAmount != nil {
                showAddMovement = true
            }
        }
        .fullScreenCover(isPresented: $showAddMovement) {
            AddMovementView(
                initialAmount: ticketVM.detectedAmount,
                initialTitle: "",
                initialCategory: .comida
            )
            .environmentObject(vm)
            .preferredColorScheme(.dark)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Escanear ticket")
                .foregroundStyle(AppTheme.textPrimary)
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
            Text("Toma una foto de tu ticket para detectar gastos automáticamente")
                .foregroundStyle(AppTheme.textTertiary)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var cameraPrompt: some View {
        NeonCard {
            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(AppTheme.accent.opacity(0.6))
                Text("Toca para abrir la cámara")
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                Text("O selecciona una imagen desde tu galería")
                    .foregroundStyle(AppTheme.textTertiary)
                    .font(.subheadline)
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                        Text("Abrir cámara o galería")
                    }
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: AppTheme.controlRadius).fill(AppTheme.accent))
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 20)
        }
    }
    
    private var previewView: some View {
        VStack(spacing: 16) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
            }
            
            Button {
                selectedImage = nil
                selectedItem = nil
                ticketVM.reset()
            } label: {
                Text("Tomar otra foto")
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.controlRadius)
                            .fill(AppTheme.surface2)
                            .overlay(RoundedRectangle(cornerRadius: AppTheme.controlRadius).strokeBorder(.white.opacity(0.08), lineWidth: 1))
                    )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var processingView: some View {
        NeonCard {
            VStack(spacing: 20) {
                ProgressView()
                    .tint(AppTheme.accent)
                    .scaleEffect(1.2)
                
                Text("Procesando ticket...")
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                
                Text("Reconociendo texto del ticket...")
                    .foregroundStyle(AppTheme.textTertiary)
                    .font(.caption)
            }
            .padding(.vertical, 40)
        }
    }
    
}

#Preview {
    CameraView(namespace: Namespace().wrappedValue)
        .environmentObject(AppViewModel.preview)
}

