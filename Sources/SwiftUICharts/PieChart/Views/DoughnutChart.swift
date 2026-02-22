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
                    let radius = min(geo.size.width, geo.size.height) / 2
                    let strokeWidth = chartData.chartStyle.strokeWidth
                    // Convert stroke width to radians so gap scales with chart size
                    let angularGap = Double(strokeWidth / radius) * 1.15  // 👈 tweak 1.5 multiplier

                    DoughnutSegmentShape(
                        id: chartData.dataSets.dataPoints[data].id,
                        startAngle: chartData.dataSets.dataPoints[data].startAngle,
                        amount: chartData.dataSets.dataPoints[data].amount,
                        angularGap: angularGap
                    )
                    .stroke(
                        chartData.dataSets.dataPoints[data].colour,
                        style: StrokeStyle(
                            lineWidth: chartData.chartStyle.strokeWidth,
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
                        withAnimation(.easeInOut) {
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
                colour: Color(red: 0.96, green: 0.42, blue: 0.36),
                label: .none
            ),
            PieChartDataPoint(
                value: 450,
                description: "Shopping",
                colour: Color(red: 0.95, green: 0.58, blue: 0.29),
                label: .none
            ),
            PieChartDataPoint(
                value: 250,
                description: "Transport",
                colour: Color(red: 0.95, green: 0.76, blue: 0.30),
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
