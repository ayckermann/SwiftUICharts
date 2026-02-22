//
//  DoughnutSegmentShape.swift
//  
//
//  Created by Will Dale on 23/02/2021.
//

import SwiftUI

/**
 Draws a doughnut segment.
 */
internal struct DoughnutSegmentShape: InsettableShape, Identifiable {

    var id: UUID
    var startAngle: Double
    var amount: Double
    var insetAmount: CGFloat = 0
    var angularGap: Double = 0.05  // radians to trim from each end

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }

    internal func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        var path = Path()

        // Shrink segment from both sides by half the gap
        let adjustedStart = startAngle + angularGap / 2
        let adjustedAmount = amount - angularGap

        // Don't draw if the segment is too small to be visible
        guard adjustedAmount > 0 else { return path }

        path.addRelativeArc(center: center,
                            radius: radius - insetAmount,
                            startAngle: Angle(radians: adjustedStart),
                            delta: Angle(radians: adjustedAmount))
        return path
    }
}
