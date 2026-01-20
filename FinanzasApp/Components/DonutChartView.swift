//
//  DonutChartView.swift
//  FinanzasApp
//
//  Gráfico donut 3D con divisiones lineales.
//

import SwiftUI

struct DonutSlice: Identifiable {
    let id = UUID()
    let category: Category
    let value: Double
    let color: Color
}

struct DonutChartView: View {
    let slices: [DonutSlice]
    @State private var animate = false
    
    private var total: Double {
        max(slices.reduce(0) { $0 + $1.value }, 0.0001)
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size * 0.4
            let thickness = size * 0.18
            
            ZStack {
                // Segmentos del donut con efecto 3D
                ForEach(Array(slices.enumerated()), id: \.element.id) { index, slice in
                    let angles = calculateAngles(for: index)
                    DonutArc(start: angles.start, end: angles.end, radius: radius, thickness: thickness)
                        .fill(
                            LinearGradient(
                                colors: [
                                    slice.color,
                                    slice.color.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: slice.color.opacity(0.4), radius: 8, x: 2, y: 2)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: -1, y: -1)
                        .opacity(animate ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: animate)
                }
                
                // Centro del donut
                Circle()
                    .fill(AppTheme.surface)
                    .frame(width: radius * 1.55, height: radius * 1.55)
                    .overlay(Circle().strokeBorder(.white.opacity(0.06), lineWidth: 1))
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear { animate = true }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func calculateAngles(for index: Int) -> (start: Angle, end: Angle) {
        let prev = slices.prefix(index).reduce(0) { $0 + $1.value }
        let upTo = slices.prefix(index + 1).reduce(0) { $0 + $1.value }
        let startFrac = prev / total
        let endFrac = upTo / total
        let progress = animate ? 1.0 : 0.001
        return (
            start: .degrees(-90 + 360 * startFrac * progress),
            end: .degrees(-90 + 360 * endFrac * progress)
        )
    }
}

private struct DonutArc: Shape {
    var start: Angle
    var end: Angle
    var radius: CGFloat
    var thickness: CGFloat

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(start.degrees, end.degrees) }
        set {
            start = .degrees(newValue.first)
            end = .degrees(newValue.second)
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let innerRadius = radius - thickness / 2
        let outerRadius = radius + thickness / 2
        
        // Punto inicial en el arco exterior
        let startOuterX = center.x + cos(start.radians) * outerRadius
        let startOuterY = center.y + sin(start.radians) * outerRadius
        path.move(to: CGPoint(x: startOuterX, y: startOuterY))
        
        // Arco exterior
        path.addArc(center: center, radius: outerRadius, startAngle: start, endAngle: end, clockwise: false)
        
        // Línea recta hacia adentro (división lineal)
        let endInnerX = center.x + cos(end.radians) * innerRadius
        let endInnerY = center.y + sin(end.radians) * innerRadius
        path.addLine(to: CGPoint(x: endInnerX, y: endInnerY))
        
        // Arco interior (hacia atrás)
        path.addArc(center: center, radius: innerRadius, startAngle: end, endAngle: start, clockwise: true)
        
        // Cerrar con línea recta (división lineal)
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        AppBackground()
        NeonCard {
            DonutChartView(
                slices: [
                    DonutSlice(category: .comida, value: 18, color: AppTheme.accent),
                    DonutSlice(category: .transporte, value: 8, color: AppTheme.accent2),
                    DonutSlice(category: .ocio, value: 5, color: AppTheme.expense),
                ]
            )
            .frame(height: 180)
        }
        .padding()
    }
}


