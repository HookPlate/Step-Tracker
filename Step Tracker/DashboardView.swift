//
//  ContentView.swift
//  Step Tracker
//
//  Created by robin tetley on 29/06/2024.
//

import SwiftUI
import Charts

enum HealthMetricContext: CaseIterable, Identifiable {
    case steps, weight
    var id: Self {self}
    
    var title: String {
        switch self {
        case .steps:
            return "Steps"
        case .weight:
            return "Weight"
        }
    }
}

struct DashboardView: View {
    
    @Environment(HealthKitManager.self) private var hkManager
    //is stashed in to userdefaults so it persists between app launches
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    @State private var isShowingPermissionPrimingSheet = false
    @State private var rawSelectedDate: Date?
    
    @State private var selectedStat: HealthMetricContext = .steps
    var isSteps: Bool { selectedStat == .steps }
    
    var avStepCount: Double {
        guard !hkManager.stepData.isEmpty else {return 0}
        let totalSteps = hkManager.stepData.reduce(0) {$0 + $1.value}
        return totalSteps/Double(hkManager.stepData.count)
    }
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else {return nil}
        return hkManager.stepData.first { Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                     
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) {
                            //$0 is possible since we're only iterating over 1 array
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented )
                    
                    VStack {
                        NavigationLink(value: selectedStat) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Label("Steps", systemImage: "figure.walk")
                                        .font(.title3.bold())
                                        .foregroundStyle(.pink)
                                    
                                    Text("Avg: \(Int(avStepCount)) steps")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 12)
                        
                        Chart {
                            //if they have their finger on the chart
                            if let selectedHealthMetric {
                                RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day))
                                    .foregroundStyle(Color.secondary.opacity(0.3))
                                    .offset(y: -10)
                                    .annotation(position: .top,
                                                spacing: 0,
                                                overflowResolution: .init(x: .fit(to:.chart), y: .disabled)) {
                                        annotationView
                                    }
                            }
                            //this is a viewbuilder, think of it as a zstack
                            RuleMark(y: .value("Average", avStepCount))
                                .foregroundStyle(Color.secondary)
                                .lineStyle(.init(lineWidth: 2, dash: [5]))
                            ForEach(hkManager.stepData) { steps in
                                BarMark(
                                    x: .value("Date", steps.date, unit: .day), 
                                    y: .value("Steps", steps.value)
                                )
                                .foregroundStyle(Color.pink.gradient)
                                //so when the finger is on the screen give the bar iunder it 1.0, of if nothing, give them all that.
                                .opacity(rawSelectedDate == nil || steps.date == selectedHealthMetric?.date ? 1.0 : 0.3)
                            }
                        }
                        .frame(height: 150)
                        //when this property changes we want to aniomate those changes. The modifier tracks where the person is dragging and gives us the date.
                        .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                        .chartXAxis {
                            AxisMarks {
                                AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                            }
                        }
                        .chartYAxis {
                            AxisMarks { value in
                                AxisGridLine()
                                    .foregroundStyle(Color.secondary.opacity(0.3))
                                AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Label("Averages", systemImage: "calendar")
                                .font(.title3.bold())
                                .foregroundStyle(.pink)
                            
                            Text("Last 28 Days")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 12)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 240)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                }
            }
            .navigationTitle("DashBoard")
            .padding()
            .task {
                await hkManager.fetchStepCount()
                isShowingPermissionPrimingSheet = !hasSeenPermissionPriming
            }
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPrimingSheet) {
                //fetch health data
            } content: {
                HealthKitPermissionPrimingView(hasSeen: $hasSeenPermissionPriming)
            }

        }
        .tint(isSteps ? .pink : .indigo)
    }
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedHealthMetric?.date ?? .now, format:
                    .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                    .font(.footnote.bold())
                    .foregroundStyle(.secondary)
            
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(0)))
                .fontWeight(.heavy)
                .foregroundStyle(.pink)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
