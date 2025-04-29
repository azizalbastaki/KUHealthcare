//
//  BillingView.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 30/04/2025.
//
import SwiftUI

struct PatientBillingView: View {
    let patient: LoggedInPatient
    
    @State private var appointments: [Appointment] = []
    @State private var outstandingBalance: Int = 0
    @State private var message: String?
    @State private var isLoading = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Billing")
                .font(.largeTitle)
                .bold()
            
            if isLoading {
                ProgressView()
                    .padding()
            } else {
                if appointments.isEmpty {
                    Text("No appointments found.")
                        .foregroundColor(.secondary)
                } else {
                    List(appointments) { appointment in
                        VStack(alignment: .leading) {
                            Text("Date: \(appointment.date) at \(appointment.time)")
                                .font(.headline)
                            Text("Reason: \(appointment.reason)")
                            Text("Status: \(appointment.status)")
                        }
                    }
                    
                    Divider()
                    
                    Text("Outstanding Balance: AED \(outstandingBalance)")
                        .font(.title2)
                        .padding(.top)
                    
                    HStack(spacing: 16) {
                        Button("Pay by Cash") {
                            settlePayments(method: "cash")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if let insurance = patientInsuranceProvider(), !insurance.isEmpty {
                            Button("Pay by \(insurance)") {
                                settlePayments(method: "insurance")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    
                    if let msg = message {
                        Text(msg)
                            .foregroundColor(.green)
                            .padding(.top)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            loadAppointments()
            loadOutstandingBalance()
        }
    }
    
    func loadAppointments() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/patient_appointments?patient_id=\(patient.id)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data,
                   let decoded = try? JSONDecoder().decode([Appointment].self, from: data) {
                    self.appointments = decoded
                }
                isLoading = false
            }
        }.resume()
    }
    
    func loadOutstandingBalance() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/get_outstanding_balance?patient_id=\(patient.id)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data,
                   let decoded = try? JSONDecoder().decode([String: Int].self, from: data),
                   let balance = decoded["outstanding_balance"] {
                    self.outstandingBalance = balance
                }
            }
        }.resume()
    }
    
    func settlePayments(method: String) {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/settle_payments") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let today = ISO8601DateFormatter().string(from: Date()).prefix(10)  // "2025-04-30"
        
        let body: [String: Any] = [
            "patient_id": patient.id,
            "payment_type": method.capitalized,   // Must be "Cash" or "Insurance" with capital C or I
            "date_paid": String(today)
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data,
                   let response = try? JSONDecoder().decode([String: String].self, from: data),
                   let msg = response["message"] {
                    message = msg
                    loadAppointments()
                    loadOutstandingBalance()
                }
            }
        }.resume()
    }
    
    func patientInsuranceProvider() -> String? {
        return nil  // 🔵 This can be updated later if your login returns insurance.
    }
}

