import SwiftUI

struct PatientDashboardView: View {
    let patient: LoggedInPatient
    @Environment(\.dismiss) var dismiss

    enum Tab {
        case appointments
        case profile
    }

    @State private var selectedTab: Tab = .appointments

    // Emergency Form Fields
    @State private var emergencyTitle = ""
    @State private var emergencyLocation = ""
    @State private var emergencyUrgency = ""
    @State private var message: String?

    // Popup control
    @State private var showEmergencyForm = false

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: 24) {
                Text("Welcome, \(patient.first_name)")
                    .font(.headline)
                    .padding(.top)

                sidebarItem("Appointments", icon: "cross.case.fill", tab: .appointments)
                sidebarItem("Profile", icon: "person.fill", tab: .profile)

                Spacer()
            }
            .padding(24)
            .frame(width: 220)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Divider()

            // Main Content
            VStack {
                switch selectedTab {
                case .appointments:
                    appointmentsTab
                case .profile:
                    profileTab
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()
        }
        .frame(minWidth: 900, minHeight: 600)
    }

    // MARK: - Sidebar Item
    @ViewBuilder
    func sidebarItem(_ label: String, icon: String, tab: Tab) -> some View {
        let isSelected = selectedTab == tab

        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
            Text(label)
                .font(.body)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.blue.opacity(0.15) : Color.clear)
        .foregroundColor(isSelected ? .blue : .primary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            selectedTab = tab
        }
    }

    // MARK: - Appointments Tab
    var appointmentsTab: some View {
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
                //.frame(maxWidth: .infinity)
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

    // MARK: - Emergency Form (Sheet)
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
                    showEmergencyForm = false // Dismiss after submit
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("Cancel") {
                    showEmergencyForm = false // 👈 Dismiss manually
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

    // MARK: - Profile Tab
    var profileTab: some View {
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

    // MARK: - Submit Emergency Logic
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
