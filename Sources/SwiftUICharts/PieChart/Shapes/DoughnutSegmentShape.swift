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

// DoughnutSegmentShape.swift

import SwiftUI

internal struct DoughnutSegmentShape: InsettableShape, Identifiable {

    var id: UUID
    var startAngle: Double
    var amount: Double
    var insetAmount: CGFloat = 0
    var angularGap: Double = 0.0

    func inset(by amount: CGFloat) -> some InsettableShape {
      var arc = self
      arc.insetAmount += amount
      return arc
    }

    internal func path(in rect: CGRect) -> Path {
      let radius = min(rect.width, rect.height) / 2 - insetAmount
      let center = CGPoint(x: rect.width / 2, y: rect.height / 2)

      let adjustedStart = startAngle + angularGap / 2
      // ✅ Clamp to 0.001 so tiny segments still render as a round dot
      // instead of completely disappearing
      let adjustedAmount = max(amount - angularGap, 0.001)

      var path = Path()
      path.addRelativeArc(
        center: center,
        radius: radius,
        startAngle: Angle(radians: adjustedStart),
        delta: Angle(radians: adjustedAmount)
      )
      return path
    }
}
