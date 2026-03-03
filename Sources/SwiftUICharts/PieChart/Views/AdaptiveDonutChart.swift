//
//  AdaptiveDonutChart.swift
//  SwiftUICharts
//
//  Created by Ayatullah Ma'arif on 03/03/26.
//

import SwiftUI

public struct AdaptiveDonutChart<ChartData: DoughnutChartData, CenterContent: View>: View {

  @ObservedObject private var chartData: ChartData
  private let centerContent: (PieChartDataPoint?) -> CenterContent
  public init(
    chartData: ChartData,
    @ViewBuilder centerContent: @escaping (PieChartDataPoint?) -> CenterContent
  ) {
    self.chartData = chartData
    self.centerContent = centerContent
  }

  public var body: some View {
    if #available(iOS 17, *) {
      NativeDonutChart(
        chartData: chartData,
        centerContent: centerContent
      )
    } else {
      DoughnutChart(
        chartData: chartData,
        centerContent: centerContent
      )
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

  AdaptiveDonutChart(chartData: mockData) { selected in
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
    .transition(.opacity)
    .animation(.easeInOut, value: selected)
  }
  .frame(height: 250)
}
