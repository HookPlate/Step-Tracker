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
}
