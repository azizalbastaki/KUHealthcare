//
//  StaffScheduleView.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 29/04/2025.
//
import SwiftUI

struct StaffScheduleView: View {
    let staff: LoggedInStaff

    @State private var appointments: [Appointment] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Appointments")
                .font(.largeTitle)
                .bold()

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else if appointments.isEmpty {
                Text("No appointments scheduled.")
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(appointments) { appointment in
                            appointmentCard(appointment)
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            loadAppointments()
        }
    }

    @ViewBuilder
    func appointmentCard(_ appointment: Appointment) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let patientName = appointment.patient_name {
                Text("Patient: \(patientName)")
            }
            Text("\(appointment.appointment_type): \(appointment.reason)")
                .font(.subheadline)
            Text("Date: \(appointment.date) at \(appointment.time)")
                .font(.footnote)
            Text("Status: \(appointment.status)")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    func loadAppointments() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/staff_appointments?staff_id=\(staff.id)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data {
                    if let decoded = try? JSONDecoder().decode([Appointment].self, from: data) {
                        self.appointments = decoded
                    } else {
                        self.errorMessage = "Failed to decode appointments"
                    }
                } else {
                    self.errorMessage = "No response from server"
                }
            }
        }.resume()
    }
}
