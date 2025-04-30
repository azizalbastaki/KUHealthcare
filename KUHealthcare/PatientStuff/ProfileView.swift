//
//  ProfileView.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 27/04/2025.
//
import SwiftUI

struct PatientProfileView: View {
    @State var patient: LoggedInPatient
    let dismiss: DismissAction

    @State private var showInsuranceSheet = false
    @State private var newInsuranceProvider = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Patient Profile")
                .font(.title)
                .bold()

            VStack(alignment: .leading, spacing: 8) {
                Text("Name: \(patient.first_name) \(patient.last_name)")
                Text("Email: \(patient.email)")
                Text("Gender: \(patient.gender)")
                Text("Date of Birth: \(patient.date_of_birth)")
                Text("Insurance Provider: \(patientInsuranceProvider())")
            }
            .font(.body)
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()

            Button("Update Insurance Provider") {
                showInsuranceSheet = true
            }
            .buttonStyle(.borderedProminent)

            Button("Log Out") {
                dismiss()
            }
            .padding(.top)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .sheet(isPresented: $showInsuranceSheet) {
            VStack(spacing: 16) {
                Text("Update Insurance Provider")
                    .font(.headline)

                TextField("Enter new insurance provider", text: $newInsuranceProvider)
                    .textFieldStyle(.roundedBorder)

                Button("Submit") {
                    updateInsuranceProvider()
                    showInsuranceSheet = false
                }
                .buttonStyle(.borderedProminent)

                Button("Cancel") {
                    showInsuranceSheet = false
                }
                .foregroundColor(.red)
            }
            .padding()
        }
    }

    func updateInsuranceProvider() {
        guard !newInsuranceProvider.isEmpty else { return }
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/update_insurance") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "patient_id": patient.id,
            "insurance_provider": newInsuranceProvider
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            fetchUpdatedProfile()
        }.resume()
    }

    func fetchUpdatedProfile() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/get_profile?id=\(patient.id)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let updatedPatient = try? JSONDecoder().decode(LoggedInPatient.self, from: data) {
                DispatchQueue.main.async {
                    self.patient = updatedPatient
                }
            }
        }.resume()
    }

    func patientInsuranceProvider() -> String {
        return patient.insurance_provider ?? "Unknown"
    }
}
