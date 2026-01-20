//
//  DonutChartView.swift
//  FinanzasApp
//
//  Gráfico donut simple y animado (SwiftUI nativo) para distribución por categoría.
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
    
    // Cachear el total para evitar recálculos
    private var total: Double {
        max(slices.reduce(0) { $0 + $1.value }, 0.0001)
    }
    
    // Pre-calcular ángulos para mejor rendimiento
    private var angleData: [(start: Angle, end: Angle)] {
        slices.enumerated().map { index, _ in
            let prev = slices.prefix(index).reduce(0) { $0 + $1.value }
            let upTo = slices.prefix(index + 1).reduce(0) { $0 + $1.value }
            let startFrac = prev / total
            let endFrac = upTo / total
            return (
                start: .degrees(-90 + 360 * startFrac * (animate ? 1 : 0.001)),
                end: .degrees(-90 + 360 * endFrac * (animate ? 1 : 0.001))
            )
        }
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                ForEach(Array(slices.enumerated()), id: \.element.id) { index, slice in
                    let angles = angleData[index]
                    DonutArc(
                        start: angles.start,
                        end: angles.end,
                        thickness: size * 0.18
                    )
                    .stroke(slice.color, style: StrokeStyle(lineWidth: size * 0.18, lineCap: .round))
                    .opacity(0.95)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.03), value: animate)
                    .scaleEffect(animate ? 1 : 0.9, anchor: .center)
                    .opacity(animate ? 1 : 0.0)
                }

                Circle()
                    .fill(AppTheme.surface)
                    .frame(width: size * 0.62, height: size * 0.62)
                    .overlay(
                        Circle().strokeBorder(.white.opacity(0.06), lineWidth: 1)
                    )
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear { animate = true }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct DonutArc: Shape {
    var start: Angle
    var end: Angle
    var thickness: CGFloat

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(start.degrees, end.degrees) }
        set {
            start = .degrees(newValue.first)
            end = .degrees(newValue.second)
        }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let r = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        p.addArc(center: center, radius: r - thickness / 2, startAngle: start, endAngle: end, clockwise: false)
        return p
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


