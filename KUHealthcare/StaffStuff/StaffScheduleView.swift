//
//  StaffScheduleView.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 29/04/2025.
//
import SwiftUI

struct StaffScheduleView: View {
    let staff: LoggedInStaff

    var body: some View {
        VStack(spacing: 20) {
            Text("Your Schedule")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Coming Soon: View your assigned appointments, shifts, and duties.")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
