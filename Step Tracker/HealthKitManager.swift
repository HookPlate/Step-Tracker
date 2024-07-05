//
//  HealthKitManager.swift
//  Step Tracker
//
//  Created by robin tetley on 04/07/2024.
//

import Foundation
import HealthKit
import Observation

@Observable class HealthKitManager {
    
    let store = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
}
