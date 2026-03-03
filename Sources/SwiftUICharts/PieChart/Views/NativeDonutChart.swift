//
//  NativeDonutChart.swift
//  SwiftUICharts
//
//  Created by Ayatullah Ma'arif on 03/03/26.
//

import SwiftUI
import Charts

@available(iOS 17, *)
public struct NativeDonutChart<ChartData: DoughnutChartData, CenterContent: View>: View {

  @ObservedObject var chartData: ChartData
  let centerContent: (PieChartDataPoint?) -> CenterContent

  @State var selected: PieChartDataPoint?

  public var body: some View {
    Chart(chartData.dataSets.dataPoints, id: \.id) { point in
      SectorMark(
        angle: .value("Value", point.value),
        innerRadius: .ratio(selected?.id == point.id ? 0.50 : 0.62),  // bigger inward expansion
        outerRadius: .ratio(selected?.id == point.id ? 1.0 : 0.9),
        angularInset: selected?.id == point.id ? 2 : 4
      )
      .cornerRadius(6)
      .foregroundStyle(point.colour)
    }
    .chartOverlay { proxy in
      GeometryReader { geo in
        Color.clear
          .contentShape(Rectangle())
          .onTapGesture { location in
            handleTap(at: location, in: geo, proxy: proxy)
          }
      }
    }
    .chartBackground { _ in
      GeometryReader { geo in
        let frame = geo.frame(in: .local)
        let innerSize = min(frame.width, frame.height) * 0.6 - chartData.chartStyle.strokeWidth * 2
        centerContent(selected)
          .frame(width: innerSize, height: innerSize)
          .position(x: frame.midX, y: frame.midY)
          .animation(.easeInOut(duration: 0.18), value: selected?.id)
      }
    }
    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selected?.id)
    .modifier(WheelAppearModifier())
  }

  private func handleTap(at location: CGPoint, in geo: GeometryProxy, proxy: ChartProxy) {
    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

    // Get angle of tap relative to center (0° = right, going clockwise)
    let dx = location.x - center.x
    let dy = location.y - center.y

    // Convert to 0–360° starting from top (12 o'clock), clockwise
    var angle = atan2(dy, dx) * 180 / .pi + 90
    if angle < 0 { angle += 360 }

    // Check tap is within the donut ring
    let distance = sqrt(dx * dx + dy * dy)
    let outerR   = min(geo.size.width, geo.size.height) / 2
    let innerR   = outerR * 0.6
    guard distance >= innerR && distance <= outerR else {
      withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
        selected = nil
      }
      return
    }

    // Find which segment was tapped
    let points = chartData.dataSets.dataPoints
    let total  = points.map(\.value).reduce(0, +)
    guard total > 0 else { return }

    var cumulative = 0.0
    for point in points {
      cumulative += (point.value / total) * 360
      if angle <= cumulative {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
          selected = (selected?.id == point.id) ? nil : point
        }
        return
      }
    }
    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
      selected = nil
    }
  }
}

// MARK: - Wheel appear animation

struct WheelAppearModifier: ViewModifier {
  @State private var appeared = false

  func body(content: Content) -> some View {
    content
      .rotationEffect(.degrees(appeared ? 0 : -180))
      .scaleEffect(appeared ? 1 : 0.3)
      .opacity(appeared ? 1 : 0)
      .onAppear {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
          appeared = true
        }
      }
      .onDisappear{
        withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
          appeared = false
        }
      }
  }
}

#Preview {

  var mockData: DoughnutChartData {

    let points = [
      PieChartDataPoint(
        value: 800,
        description: "Food",
        colour: .red,
        label: .none
      ),
      PieChartDataPoint(
        value: 450,
        description: "Shopping",
        colour: .blue,
        label: .none
      ),
      PieChartDataPoint(
        value: 250,
        description: "Transport",
        colour: .green,
        label: .none
      ),
      PieChartDataPoint(
        value: 140,
        description: "Transport9",
        colour: .purple,
        label: .none
      ),
      PieChartDataPoint(
        value: 290,
        description: "Transport8",
        colour: .yellow,
        label: .none
      ),
      PieChartDataPoint(
        value: 490,
        description: "Transport7",
        colour: .black,
        label: .none
      ),
      PieChartDataPoint(
        value: 180,
        description: "Transport6",
        colour: .gray,
        label: .none
      ),
      PieChartDataPoint(
        value: 260,
        description: "Transport5",
        colour: .black.opacity(0.1),
        label: .none
      ),
      PieChartDataPoint(
        value: 280,
        description: "Transport4",
        colour: .black.opacity(0.8),
        label: .none
      ),
      PieChartDataPoint(
        value: 850,
        description: "Transport3",
        colour: .red.opacity(0.7),
        label: .none
      ),
      PieChartDataPoint(
        value: 290,
        description: "Transport1",
        colour: .green.opacity(0.5),
        label: .none
      ),
      PieChartDataPoint(
        value: 1000,
        description: "Transport2",
        colour: .yellow.opacity(0.3),
        label: .none
      )
    ]

    let dataSet = PieDataSet(
      dataPoints: points,
      legendTitle: "Total Spending"
    )

    let metadata = ChartMetadata(
      title: "Total Spending",
      subtitle: "$ 1,500.00"
    )

    let style = DoughnutChartStyle(
      infoBoxPlacement: .floating,
      strokeWidth: 42 // controls thickness
    )

    return DoughnutChartData(
      dataSets: dataSet,
      metadata: metadata,
      chartStyle: style,
      noDataText: Text("No data")
    )
  }

  if #available(iOS 26.0, *) {
    NativeDonutChart(chartData: mockData) { selected in
      VStack {
        if let selected {
          Text(selected.description ?? "")
            .font(.headline)
          Text("\(selected.value)")
            .font(.subheadline)
        } else {
          Text("Total")
            .font(.headline)
          Text("$1,500")
            .font(.subheadline)
        }
      }
      .animation(.easeInOut, value: selected)
    }
    .frame(height: 300)
  }
}
