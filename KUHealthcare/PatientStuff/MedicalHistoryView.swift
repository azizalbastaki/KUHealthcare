//
//  MedicalHistoryView.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 29/04/2025.
//

import SwiftUI

struct PatientMedicalHistoryView: View {
    let patient: LoggedInPatient

    @State private var records: [MedicalRecord] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Medical History")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            List(records) { record in
                NavigationLink(destination: MedicalRecordDetailView(record: record)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Doctor: \(record.staff_name ?? "Unknown Doctor")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(record.title)
                            .font(.headline)

                        Text(record.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.insetGrouped)
        }
        .padding()
        .onAppear {
            loadMedicalRecords()
        }
    }

    func loadMedicalRecords() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/get_patient_medical_records?patient_id=\(patient.id)") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([MedicalRecord].self, from: data) {
                DispatchQueue.main.async {
                    self.records = decoded
                }
            }
        }.resume()
    }
}

struct MedicalRecordDetailView: View {
    let record: MedicalRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(record.title)
                .font(.largeTitle)
                .bold()

            Divider()

            if let staffName = record.staff_name {
                Text("Doctor: \(staffName)")
                    .font(.headline)
            }

            Text("Diagnosis:")
                .font(.headline)
                .padding(.top, 8)
            Text(record.title)
                .font(.body)

            Text("Notes:")
                .font(.headline)
                .padding(.top, 8)
            Text(record.description)
                .font(.body)

            Spacer()
        }
        .padding()
        .navigationTitle("Medical Record")
        .navigationBarTitleDisplayMode(.inline)
    }
}
