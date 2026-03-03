//
//  DoughnutChart.swift
//  
//
//  Created by Will Dale on 01/02/2021.
//

import SwiftUI

/**
 View for creating a doughnut chart.
 
 Uses `DoughnutChartData` data model.
 
 # Declaration
 ```
 DoughnutChart(chartData: data)
 ```
 
 # View Modifiers
 The order of the view modifiers is some what important
 as the modifiers are various types for stacks that wrap
 around the previous views.
 ```
 .touchOverlay(chartData: data)
 .infoBox(chartData: data)
 .floatingInfoBox(chartData: data)
 .headerBox(chartData: data)
 .legends(chartData: data)
 ```
 */
public struct DoughnutChart<ChartData, CenterContent>: View where ChartData: DoughnutChartData, CenterContent: View {

    @ObservedObject private var chartData: ChartData
    @State private var timer: Timer?
    private let centerContent: (PieChartDataPoint?) -> CenterContent

    /// Initialises a bar chart view.
    /// - Parameter chartData: Must be DoughnutChartData.
    public init(
        chartData: ChartData,
        @ViewBuilder centerContent: @escaping (PieChartDataPoint?) -> CenterContent
    ) {
        self.chartData = chartData
        self.centerContent = centerContent
    }


    @State private var startAnimation: Bool = false
    @State private var selected: PieChartDataPoint?

    public var body: some View {
        GeometryReader { geo in
              ZStack {
                  ForEach(chartData.dataSets.dataPoints.indices, id: \.self) { data in
                    let diameter    = min(geo.size.width, geo.size.height)
                    let outerRadius = diameter / 2.2
                    let n           = CGFloat(chartData.dataSets.dataPoints.count)

                    let maxStroke   = CGFloat(.pi * Double(outerRadius) / Double(n) * 0.6)
                    let strokeWidth = min(chartData.chartStyle.strokeWidth, maxStroke)
                    let meanRadius  = outerRadius - strokeWidth / 2

                    // Fixed gap: each segment loses this many radians from each end.
                    // Using a fixed angular gap ensures ALL segments have identical spacing
                    // regardless of their size. Cap overhang = strokeWidth/meanRadius,
                    // so we match that exactly with no multiplier — the 0.001 min in the
                    // shape prevents tiny segments vanishing.
                    let angularGap = Double(strokeWidth / meanRadius)

                    DoughnutSegmentShape(
                      id: chartData.dataSets.dataPoints[data].id,
                      startAngle: chartData.dataSets.dataPoints[data].startAngle,
                      amount: chartData.dataSets.dataPoints[data].amount,
                      insetAmount: strokeWidth / 2,   // arc draws at mean radius
                      angularGap: angularGap
                    )
                    .stroke(
                      chartData.dataSets.dataPoints[data].colour,
                      style: StrokeStyle(
                        lineWidth: strokeWidth,
                        lineCap: .round
                      )
                    )
                    .overlay(dataPoint: chartData.dataSets.dataPoints[data],
                             chartData: chartData,
                             rect: geo.frame(in: .local))
                    .scaleEffect(animationValue)
                    .opacity(Double(animationValue))
                    .animation(Animation.spring().delay(Double(data) * 0.06))
                    .if(selected == chartData.dataSets.dataPoints[data]) {
                        $0
                            .scaleEffect(1.12)
                            .zIndex(1)
                    }
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            if selected == chartData.dataSets.dataPoints[data] {
                                selected = nil
                            } else {
                                selected = chartData.dataSets.dataPoints[data]
                            }
                        }
                    }
                    .accessibilityLabel(chartData.metadata.title)
                    .accessibilityValue(chartData.dataSets.dataPoints[data].getCellAccessibilityValue(specifier: chartData.infoView.touchSpecifier,
                                                                                                      formatter: chartData.infoView.touchFormatter))
                }

                centerContent(selected)
                    .frame(
                        width: min(geo.size.width, geo.size.height) - chartData.chartStyle.strokeWidth * 2,
                        height: min(geo.size.width, geo.size.height) - chartData.chartStyle.strokeWidth * 2
                    )
            }
            .onTapGesture {
              selected = nil
            }
        }
        .animateOnAppear(disabled: chartData.disableAnimation, using: chartData.chartStyle.globalAnimation) {
            self.startAnimation = true
        }
        .animateOnDisappear(disabled: chartData.disableAnimation, using: chartData.chartStyle.globalAnimation) {
            self.startAnimation = false
        }
        .layoutNotifier(timer)
    }
    
    var animationValue: CGFloat {
        if chartData.disableAnimation {
            return 1
        } else {
            return startAnimation ? 1 : 0.001
        }
    }
}

#if DEBUG
struct DoughnutChart_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            DoughnutChart(chartData: mockData) { selected in
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

        }
        .frame(height: 250)
    }

    static var mockData: DoughnutChartData {

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
}
#endif
