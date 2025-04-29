import SwiftUI

struct StaffDashboardView: View {
    let staff: LoggedInStaff
    @Environment(\.dismiss) var dismiss

    enum Tab {
        case schedule
        case patients
        case profile
    }

    @State private var selectedTab: Tab = .schedule

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: 24) {
                Text("Welcome, \(staff.first_name)")
                    .font(.headline)
                    .padding(.top)

                sidebarItem("Schedule", icon: "calendar", tab: .schedule)
                sidebarItem("Patients", icon: "person.2.fill", tab: .patients)
                sidebarItem("Profile", icon: "person.fill", tab: .profile)

                Spacer()
            }
            .padding(24)
            .frame(width: 220)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Divider()

            // Main content
            VStack {
                switch selectedTab {
                case .schedule:
                    StaffScheduleView(staff: staff)
                case .patients:
                    StaffPatientsView(staff: staff)  
                case .profile:
                    StaffProfileView(staff: staff, dismiss: dismiss)
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
