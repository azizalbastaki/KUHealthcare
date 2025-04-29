//
//  StaffProfileView.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 29/04/2025.
//

import SwiftUI

struct StaffProfileView: View {
    let staff: LoggedInStaff
    let dismiss: DismissAction

    var body: some View {
        VStack(spacing: 20) {
            Text("Profile")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Name: \(staff.first_name) \(staff.last_name)")
                Text("Email: \(staff.email)")
                Text("Department: \(staff.department)")
                Text("Role: \(staff.role)")
                Text("Specialization: \(staff.specialization)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()

            Button("Log Out") {
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
