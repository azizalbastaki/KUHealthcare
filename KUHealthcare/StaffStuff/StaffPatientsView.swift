//
//  StaffPatientsView.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 29/04/2025.
//
import SwiftUI

struct StaffPatientsView: View {
    let staff: LoggedInStaff

    @State private var patients: [Patient] = []

    // New states
    @State private var showAddRecordForm = false
    @State private var selectedPatient: Patient? = nil

    // Form fields
    @State private var diagnosis = ""
    @State private var notes = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Patients")
                .font(.title)
                .padding(.top)

            List(patients) { patient in
                VStack(alignment: .leading) {
                    Text("\(patient.first_name) \(patient.last_name)")
                        .font(.headline)
                    Text("Email: \(patient.email)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Button("Add Medical Record") {
                        selectedPatient = patient
                        showAddRecordForm = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 5)
                }
                .padding(.vertical, 8)
            }
            .listStyle(.insetGrouped)
        }
        .padding()
        .onAppear {
            loadPatients()
        }
        .sheet(isPresented: $showAddRecordForm) {
            addMedicalRecordForm
        }
    }

    var addMedicalRecordForm: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Medical Record")
                    .font(.title2)
                    .fontWeight(.bold)

                TextField("Title", text: $diagnosis)
                    .textFieldStyle(.roundedBorder)

                TextField("Notes", text: $notes)
                    .textFieldStyle(.roundedBorder)

                Button("Submit") {
                    submitMedicalRecord()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("Cancel") {
                    showAddRecordForm = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            .navigationTitle("New Record")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func loadPatients() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/patients_of_staff?staff_id=\(staff.id)") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([Patient].self, from: data) {
                DispatchQueue.main.async {
                    self.patients = decoded
                }
            }
        }.resume()
    }

    func submitMedicalRecord() {
        guard let selectedPatient else { return }

        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/add_medical_record") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "patient_id": selectedPatient.id,
            "staff_id": staff.id,
            "title": diagnosis,
            "description": notes
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                showAddRecordForm = false
                diagnosis = ""
                notes = ""
            }
        }.resume()
    }
}
