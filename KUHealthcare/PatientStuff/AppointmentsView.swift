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
    
    @State private var appointments: [Appointment] = []
    @State private var showAddAppointmentForm = false

    // New appointment form fields
    @State private var appointmentDate = Date()
    @State private var appointmentHour: Int = 7 // default to 7 AM
    @State private var appointmentReason = ""
    @State private var appointmentType = ""
    
    @State private var staffList: [MedicalStaff] = []
    @State private var selectedStaffId: String = ""
    
    var availableHours: [Int] {
        Array(7...19)
    }
    
    var filteredStaffList: [MedicalStaff] {
        let selectedDay = weekdayFromDate(appointmentDate).capitalized
        return staffList.filter { staff in
            staff.schedule[selectedDay] ?? false
        }
    }

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
                
                Button("New Appointment") {
                    showAddAppointmentForm = true
                }
                .padding()
                .background(.green)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Upcoming Appointments")
                        .font(.headline)

                    ForEach(upcomingAppointments) { appointment in
                        AppointmentRow(appointment: appointment)
                    }
                    
                    Divider().padding(.vertical)
                    
                    Text("Past Appointments")
                        .font(.headline)

                    ForEach(pastAppointments) { appointment in
                        AppointmentRow(appointment: appointment)
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .sheet(isPresented: $showEmergencyForm) {
            emergencyForm
        }
        .sheet(isPresented: $showAddAppointmentForm) {
            addAppointmentForm
        }
        .onAppear {
            loadAppointments()
            loadStaff()

        }
        .sheet(isPresented: $showEmergencyForm) {
            emergencyForm
        }
    }
    
    var addAppointmentForm: some View {
        NavigationView {
            ScrollView {
            VStack(spacing: 20) {
                Text("New Appointment")
                    .font(.title2)
                    .fontWeight(.bold)
                if (((message?.isEmpty) == false)) {
                    Text(message!)
                }
                DatePicker("Date", selection: $appointmentDate, displayedComponents: .date)
                
                Picker("Select Time", selection: $appointmentHour) {
                    ForEach(availableHours, id: \.self) { hour in
                        Text(formatHour(hour)).tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .padding()
                .frame(height: 100)
                //.background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
              
                if filteredStaffList.isEmpty {
                    Text("No available staff for the selected date.")
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Picker("Select Staff", selection: $selectedStaffId) {
                        ForEach(filteredStaffList) { staff in
                            Text("\(staff.first_name) \(staff.last_name) - \(staff.specialization)").tag(staff.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    //.background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                TextField("Type (Consultation, Test, etc.)", text: $appointmentType)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Description", text: $appointmentReason)
                    .textFieldStyle(.roundedBorder)
                
                
                Button("Submit Appointment") {
                    submitAppointment()
                    //showAddAppointmentForm = false
                }
                .disabled(filteredStaffList.isEmpty) // <--- NEW
                .padding()
                .frame(maxWidth: .infinity)
                .background(filteredStaffList.isEmpty ? Color.gray : Color.green)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Button("Cancel") {
                    showAddAppointmentForm = false
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
            .navigationTitle("Add Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !availableHours.contains(appointmentHour) {
                    appointmentHour = availableHours.first ?? 7
                }
            }
        }
    }
    }
    
    struct AppointmentRow: View {
        let appointment: Appointment

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(appointment.appointment_type): \(appointment.reason)")
                    .font(.headline)
                Text("Date: \(appointment.date) at \(appointment.time)")
                    .font(.subheadline)
                Text("Status: \(appointment.status)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
    
    func submitAppointment() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: appointmentDate)

        guard !appointmentReason.isEmpty,
              !appointmentType.isEmpty else {
            message = "⚠️ Please fill in all fields."
            return
        }

        let timeString = String(format: "%02d:00", appointmentHour)

        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/add_appointment") else {
            message = "⚠️ Could not create request"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let body: [String: Any] = [
            "patient_id": patient.id,
            "staff_id": selectedStaffId,
            "date": dateString,
            "time": timeString,
            "reason": appointmentReason,
            "appointment_type": appointmentType
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    if let responseMessage = json["message"] as? String {
                        message = "✅ \(responseMessage)"
                        appointmentReason = ""
                        appointmentType = ""
                        loadAppointments()
                    } else if let errorMessage = json["error"] as? String {
                        message = "⚠️ \(errorMessage)"
                    } else {
                        message = "❌ Unexpected server response."
                    }
                    
                } else {
                    message = "❌ Failed to submit appointment"
                }
            }
        }.resume()

        appointmentReason = ""
        appointmentType = ""
        selectedStaffId = ""
    }
    func loadAppointments() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/patient_appointments?patient_id=\(patient.id)") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([Appointment].self, from: data) {
                DispatchQueue.main.async {
                    self.appointments = decoded
                }
            }
        }.resume()
    }
    var upcomingAppointments: [Appointment] {
        appointments.filter { appointment in
            guard let appointmentDate = appointmentDateOnly(appointment.date) else { return false }
            return appointmentDate >= Date()
        }
    }

    var pastAppointments: [Appointment] {
        appointments.filter { appointment in
            guard let appointmentDate = appointmentDateOnly(appointment.date) else { return false }
            return appointmentDate < Date()
        }
    }

    func appointmentDateOnly(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    func loadStaff() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/all_staff") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([MedicalStaff].self, from: data) {
                DispatchQueue.main.async {
                    self.staffList = decoded
                }
            }
        }.resume()
    }
    
    func weekdayFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Full day name like "Monday"
        return formatter.string(from: date)
    }
    
    func convertTo24HourFormat(_ timeString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "h a" // Input: "1 PM", "2 PM", etc.
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm" // Output: "13:00", "14:00"
        
        if let date = inputFormatter.date(from: timeString) {
            return outputFormatter.string(from: date)
        } else {
            return ""
        }
    }
    func formatHour(_ hour: Int) -> String {
        if hour == 12 {
            return "12 PM"
        } else if hour == 0 {
            return "12 AM"
        } else if hour > 12 {
            return "\(hour - 12) PM"
        } else {
            return "\(hour) AM"
        }
    }
    
}
