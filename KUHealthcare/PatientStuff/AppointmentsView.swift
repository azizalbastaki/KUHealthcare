//
//  AppointmentsView.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 27/04/2025.
//

import SwiftUI

struct PatientAppointmentsView: View {
    let patient: LoggedInPatient

    @Binding var emergencyTitle: String
    @Binding var emergencyLocation: String
    @Binding var emergencyUrgency: String
    @Binding var message: String?
    @Binding var showEmergencyForm: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Appointments")
                .font(.title)
                .fontWeight(.semibold)
            
            HStack {
                Spacer()
                Button("Request Emergency") {
                    showEmergencyForm = true
                }
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
            }
            Spacer()
        }
        .sheet(isPresented: $showEmergencyForm) {
            emergencyForm
        }
    }

    var emergencyForm: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("New Emergency Request")
                    .font(.title2)
                    .fontWeight(.bold)

                TextField("Title", text: $emergencyTitle)
                    .textFieldStyle(.roundedBorder)

                TextField("Location", text: $emergencyLocation)
                    .textFieldStyle(.roundedBorder)

                TextField("Urgency (e.g. high, medium, low)", text: $emergencyUrgency)
                    .textFieldStyle(.roundedBorder)

                Button("Submit Request") {
                    submitEmergency()
                    showEmergencyForm = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("Cancel") {
                    showEmergencyForm = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.gray)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                if let msg = message {
                    Text(msg)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("Emergency")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func submitEmergency() {
        guard !emergencyTitle.isEmpty,
              !emergencyLocation.isEmpty,
              !emergencyUrgency.isEmpty else {
            message = "⚠️ Please fill in all fields."
            return
        }

        var components = URLComponents(string: "https://salemalkaabi.pythonanywhere.com/add_emergency")!
        components.queryItems = [
            .init(name: "patient_email", value: patient.email),
            .init(name: "title", value: emergencyTitle),
            .init(name: "location", value: emergencyLocation),
            .init(name: "urgency", value: emergencyUrgency)
        ]

        guard let url = components.url else {
            message = "⚠️ Could not create request"
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let responseMessage = json["message"] as? String {
                    message = "✅ \(responseMessage)"
                    emergencyTitle = ""
                    emergencyLocation = ""
                    emergencyUrgency = ""
                } else {
                    message = "❌ Failed to submit emergency"
                }
            }
        }.resume()
    }
}
