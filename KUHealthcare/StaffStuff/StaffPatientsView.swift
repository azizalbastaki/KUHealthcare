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

    // States for Medical Record
    @State private var showAddRecordForm = false
    @State private var selectedPatientForRecord: Patient? = nil
    @State private var diagnosis = ""
    @State private var notes = ""

    // States for Prescription
    @State private var showAddPrescriptionForm = false
    @State private var selectedPatientForPrescription: Patient? = nil
    @State private var medicationName = ""
    @State private var dosage = ""
    @State private var instructions = ""
    @State private var medicationOptions: [String] = []  // Loaded from server
    @State private var selectedMedicationName: String = ""  // Selected name

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Patients")
                .font(.title)
                .padding(.top)

            List(patients) { patient in
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(patient.first_name) \(patient.last_name)")
                        .font(.headline)
                    Text("Email: \(patient.email)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack {
                        Button("Add Medical Record") {
                            selectedPatientForRecord = patient
                            showAddRecordForm = true
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Add Prescription") {
                            selectedPatientForPrescription = patient
                            showAddPrescriptionForm = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 4)
                }
                .padding(.vertical, 8)
            }
            .listStyle(.insetGrouped)
        }
        .padding()
        .onAppear {
            loadPatients()
        }
        // Medical Record Form Sheet
        .sheet(isPresented: $showAddRecordForm) {
            addMedicalRecordForm
        }
        // Prescription Form Sheet
        .sheet(isPresented: $showAddPrescriptionForm) {
            addPrescriptionForm
        }
    }

    // MARK: - Medical Record Form
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

    // MARK: - Prescription Form
    var addPrescriptionForm: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Prescription")
                    .font(.title2)
                    .fontWeight(.bold)

                // Dropdown picker for medications
                Picker("Select Medication", selection: $selectedMedicationName) {
                    ForEach(medicationOptions, id: \.self) { medName in
                        Text(medName)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

                TextField("Dosage (e.g. 500mg, 1 tablet)", text: $dosage)
                    .textFieldStyle(.roundedBorder)

                TextField("Instructions (e.g. after meals)", text: $instructions)
                    .textFieldStyle(.roundedBorder)

                Button("Submit") {
                    submitPrescription()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("Cancel") {
                    showAddPrescriptionForm = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            .onAppear {
                fetchMedications()
            }
            .navigationTitle("New Prescription")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Networking
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
        guard let selectedPatientForRecord else { return }
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/add_medical_record") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "patient_id": selectedPatientForRecord.id,
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

    func submitPrescription() {
        guard let selectedPatientForPrescription else { return }
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/add_prescription") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "patient_id": selectedPatientForPrescription.id,
            "staff_id": staff.id,
            "medication_name": selectedMedicationName,
            "dosage": dosage,
            "instructions": instructions
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                showAddPrescriptionForm = false
                selectedMedicationName = ""
                dosage = ""
                instructions = ""
            }
        }.resume()
    }
    
    func fetchMedications() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/get_medications") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([Medication].self, from: data) {
                DispatchQueue.main.async {
                    self.medicationOptions = decoded.map { $0.name }
                    if let first = medicationOptions.first {
                        self.selectedMedicationName = first  // Default selection
                    }
                }
            }
        }.resume()
    }
}
