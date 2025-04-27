//
//  ProfileView.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 27/04/2025.
//

import SwiftUI

struct PatientProfileView: View {
    let patient: LoggedInPatient
    let dismiss: DismissAction

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Group {
                Text("Name: \(patient.first_name) \(patient.last_name)")
                Text("Email: \(patient.email)")
                Text("Gender: \(patient.gender)")
                Text("Date of Birth: \(patient.date_of_birth)")
            }
            .font(.body)

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
