import SwiftUI

struct AdminDashboardView: View {
    enum AdminTab {
        case userManagement, emergencyDispatch, staffScheduling, resourceManagement, billingReports
    }
    
    @State var selectedTab: AdminTab = .userManagement
    @State var patients: [Patient] = []
    @State var staff: [MedicalStaff] = []
    @State var staffScheduling: [MedicalStaff] = []
    @State var emergencies: [EmergencyRequest] = []
    @State var selectedEmergency: EmergencyRequest?
    @State var newStatus: String = ""
    @State var showStatusSheet = false
    @State var showAddStaffForm = false
    @State var isLoadingPatients = true
    @State var isLoadingStaff = true
    @State var isLoadingEmergencies = true
    @State var message: String?
    @State private var showForecastSheet = false
    @State private var predictedAmbulanceCount: Int?
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 24) {
                Text("Hello Admin")
                    .font(.headline)
                    .padding(.top)
                
                sidebarItem(icon: "person.3.fill", label: "User Management", tab: .userManagement)
                sidebarItem(icon: "calendar.badge.clock", label: "Staff Scheduling", tab: .staffScheduling)
                sidebarItem(icon: "shippingbox.fill", label: "Resource Management", tab: .resourceManagement)
                sidebarItem(icon: "doc.plaintext.fill", label: "Billing Reports", tab: .billingReports)
                sidebarItem(icon: "cross.case.fill", label: "Emergency Dispatch", tab: .emergencyDispatch)
                
                Spacer()
            }
            .padding(24)
            .frame(width: 240)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Divider()
            
            VStack(alignment: .leading, spacing: 24) {
                headerBar()
                
                switch selectedTab {
                case .userManagement:
                    userManagementContent()
                case .emergencyDispatch:
                    EmergencyDispatchView(
                        emergencies: $emergencies,
                        selectedEmergency: $selectedEmergency,
                        newStatus: $newStatus,
                        showStatusSheet: $showStatusSheet,
                        showForecastSheet: $showForecastSheet,
                        isLoadingEmergencies: $isLoadingEmergencies,
                        message: $message
                    )
                case .staffScheduling:
                    StaffSchedulingView(staff: $staffScheduling)
                case .resourceManagement:
                    AdminResourceManagementView()
                case .billingReports:
                    AdminBillingReportsView() 
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()
        }
        .sheet(isPresented: $showAddStaffForm) {
            AddMedicalStaffView()
        }
        .sheet(item: $selectedEmergency) { emergency in
            updateStatusSheet(for: emergency)
        }
        
        .onAppear {
            fetchPatients()
            fetchStaff()
            fetchStaffScheduling()
            fetchEmergencies()
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(Color.clear)
    }
    
    @ViewBuilder
    func sidebarItem(icon: String, label: String, tab: AdminTab) -> some View {
        let isSelected = selectedTab == tab
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
            Text(label)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.blue.opacity(0.15) : Color.clear)
        .foregroundColor(isSelected ? .blue : .primary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture { selectedTab = tab }
    }
    
    @ViewBuilder
    func headerBar() -> some View {
        HStack {
            Text(selectedTab == .userManagement ? "User Management" : "Emergency Dispatch")
                .font(.largeTitle)
                .bold()
            
            Spacer()
            
            if selectedTab == .userManagement {
                Button(action: { showAddStaffForm = true }) {
                    Label("Add Medical Staff", systemImage: "plus.circle.fill")
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}


extension AdminDashboardView {
    
    func fetchPatients() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/all_patients") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                isLoadingPatients = false
                if let data = data {
                    if let decoded = try? JSONDecoder().decode([Patient].self, from: data) {
                        self.patients = decoded
                    }
                }
            }
        }.resume()
    }
    
    func fetchStaff() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/all_staff") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                isLoadingStaff = false
                if let data = data {
                    if let decoded = try? JSONDecoder().decode([MedicalStaff].self, from: data) {
                        self.staff = decoded
                    }
                }
            }
        }.resume()
    }
    
    func fetchEmergencies() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/get_emergencies") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                isLoadingEmergencies = false
                if let data = data {
                    if let decoded = try? JSONDecoder().decode([EmergencyRequest].self, from: data) {
                        self.emergencies = decoded
                    }
                }
            }
        }.resume()
    }
    
    func fetchStaffScheduling() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/all_staff") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data {
                    if let decoded = try? JSONDecoder().decode([MedicalStaff].self, from: data) {
                        self.staffScheduling = decoded
                    }
                }
            }
        }.resume()
    }
    
    @ViewBuilder
    func updateStatusSheet(for emergency: EmergencyRequest) -> some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Update Status")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Emergency: \(emergency.title)")
                    .font(.headline)

                Picker("New Status", selection: $newStatus) {
                    Text("Pending").tag("pending")
                    Text("Approved").tag("approved")
                    Text("Rejected").tag("rejected")
                }
                .pickerStyle(.segmented)
                .padding()

                Button("Submit Update") {
                    setEmergencyStatus(for: emergency.id)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("Cancel") {
                    selectedEmergency = nil
                    showStatusSheet = false
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
            .navigationTitle("Edit Status")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func setEmergencyStatus(for id: String) {
        guard !newStatus.isEmpty else {
            message = "⚠️ Please enter a status."
            return
        }
        
        var components = URLComponents(string: "https://salemalkaabi.pythonanywhere.com/set_emergency_status")!
        components.queryItems = [
            .init(name: "id", value: id),
            .init(name: "status", value: newStatus)
        ]
        
        guard let url = components.url else {
            message = "⚠️ Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let responseMessage = json["message"] as? String {
                    message = "✅ \(responseMessage)"
                    fetchEmergencies()
                    showStatusSheet = false
                } else {
                    message = "❌ Failed to update emergency"
                }
            }
        }.resume()
    }
}
