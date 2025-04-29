//
//  PrescriptionView.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 29/04/2025.
//

import SwiftUI

struct PatientPrescriptionsView: View {
    let patient: LoggedInPatient

    @State private var prescriptions: [Prescription] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Prescriptions")
                .font(.title)
                .bold()
                .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(prescriptions) { presc in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(presc.medication_name)
                                .font(.headline)
                            Text("Dosage: \(presc.dosage)")
                                .font(.body)
                            Text("Instructions: \(presc.instructions)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .padding()
        .onAppear {
            fetchPrescriptions()
        }
    }

    func fetchPrescriptions() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/get_patient_prescriptions?patient_id=\(patient.id)") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([Prescription].self, from: data) {
                DispatchQueue.main.async {
                    self.prescriptions = decoded
                }
            }
        }.resume()
    }
}
