//
//  StaffDashboardView.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 22/04/2025.
//

import SwiftUI

struct StaffDashboardView: View {
    let staff: LoggedInStaff
    @Environment(\.dismiss) var dismiss

    @State private var selectedTab: Int = 0

    var body: some View {
        VStack {
            Picker("Tabs", selection: $selectedTab) {
                Text("Schedule").tag(0)
                Text("Profile").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            if selectedTab == 0 {
                scheduleTab
            } else {
                profileTab
            }
        }
        .padding()
    }

    var scheduleTab: some View {
        VStack {
            Text("Schedule view coming soon.")
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    var profileTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Name: \(staff.first_name) \(staff.last_name)")
            Text("Email: \(staff.email)")
            Text("Department: \(staff.department)")
            Text("Role: \(staff.role)")
            Text("Specialization: \(staff.specialization)")

            Spacer()

            Button("Log Out") {
                dismiss()
            }
            .padding()
            .background(.red)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
