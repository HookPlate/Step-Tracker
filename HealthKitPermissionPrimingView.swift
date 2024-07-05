//
//  HealthKitPermissionPrimingView.swift
//  Step Tracker
//
//  Created by robin tetley on 03/07/2024.
//

import SwiftUI
import HealthKitUI

struct HealthKitPermissionPrimingView: View {
    
    @State private var isShowingHealthKitPermissions = false
    @Environment(\.dismiss) private var dismiss
    
    @Environment(HealthKitManager.self) private var hkManager
    
    var description = """
    This app displays your step and weight data in interactive charts
    
    You can also add new step or weight data to Apple Helath from this app. Your data is provate and secured.
    """
    
    var body: some View {
        VStack(spacing: 130) {
            VStack(alignment: .leading, spacing: 12) {
                Image(.appleHealth)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .shadow(color: .gray.opacity(0.3), radius: 16)
                    .padding(.bottom, 12)
                Text("Apple Health Integration")
                    .font(.title2).bold()
                Text(description)
                    .foregroundStyle(.secondary)
            }
            
            Button("Connect Apple Watch") {
                isShowingHealthKitPermissions = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
        .padding(30)
        .healthDataAccessRequest(store: hkManager.store,
                                 shareTypes: hkManager.types,
                                 readTypes: hkManager.types,
                                 trigger: isShowingHealthKitPermissions) { result in
            switch result {
            case.success(_):
                dismiss()
            case .failure(_):
                //handle the error later
                dismiss()
            }
            
        }
    }
}

#Preview {
    HealthKitPermissionPrimingView()
        .environment(HealthKitManager())
}
