import SwiftUI

struct PatientDashboardView: View {
    let patient: LoggedInPatient
    @Environment(\.dismiss) var dismiss

    enum Tab {
        case appointments
        case profile
        case medicalHistory   // ✅ NEW
    }

    @State private var selectedTab: Tab = .appointments

    // Emergency Form Fields
    @State var emergencyTitle = ""
    @State var emergencyLocation = ""
    @State var emergencyUrgency = ""
    @State var message: String?

    // Popup control
    @State var showEmergencyForm = false

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 24) {
                Text("Welcome, \(patient.first_name)")
                    .font(.headline)
                    .padding(.top)

                sidebarItem("Appointments", icon: "cross.case.fill", tab: .appointments)
                sidebarItem("Medical History", icon: "doc.text.fill", tab: .medicalHistory)
                sidebarItem("Profile", icon: "person.fill", tab: .profile)

                Spacer()
            }
            .padding(24)
            .frame(width: 220)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Divider()

            VStack {
                switch selectedTab {
                case .appointments:
                    PatientAppointmentsView(patient: patient,
                                             emergencyTitle: $emergencyTitle,
                                             emergencyLocation: $emergencyLocation,
                                             emergencyUrgency: $emergencyUrgency,
                                             message: $message,
                                             showEmergencyForm: $showEmergencyForm)
                case .profile:
                    PatientProfileView(patient: patient, dismiss: dismiss)
                case .medicalHistory:
                    PatientMedicalHistoryView(patient: patient)  // ✅ NEW view
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
}
