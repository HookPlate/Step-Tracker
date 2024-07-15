//
//  HealthMetric.swift
//  Step Tracker
//
//  Created by robin tetley on 15/07/2024.
//

import Foundation
struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    //made because fetching from healthkkit doesn't work in the preview.
    static var mockData: [HealthMetric] {
        var array: [HealthMetric] = []
        
        for i in 0..<28 {
            let metric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                      value: .random(in: 4_000...15_000))
            array.append(metric)
        }
        return array
    }
}
