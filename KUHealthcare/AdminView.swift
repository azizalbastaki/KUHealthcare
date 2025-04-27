import SwiftUI

struct AdminDashboardView: View {
    enum AdminTab {
        case userManagement, emergencyDispatch
    }
    
    @State private var selectedTab: AdminTab = .userManagement
    
    @State private var patients: [Patient] = []
    @State private var staff: [MedicalStaff] = []
    @State private var emergencies: [EmergencyRequest] = []
    
    @State private var selectedEmergency: EmergencyRequest?
    @State private var newStatus: String = ""
    @State private var showStatusSheet = false
    @State private var showAddStaffForm = false
    
    @State private var isLoadingPatients = true
    @State private var isLoadingStaff = true
    @State private var isLoadingEmergencies = true
    
    @State private var message: String?
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: 24) {
                Text("Hello Admin")
                    .font(.headline)
                    .padding(.top)
                
                sidebarItem(icon: "person.3.fill", label: "User Management", tab: .userManagement)
                sidebarItem(icon: "cross.case.fill", label: "Emergency Dispatch", tab: .emergencyDispatch)
                
                Spacer()
            }
            .padding(24)
            .frame(width: 240)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Divider()
            
            // Main content area
            VStack(alignment: .leading, spacing: 24) {
                headerBar()
                
                switch selectedTab {
                case .userManagement:
                    userManagementContent()
                case .emergencyDispatch:
                    emergencyDispatchContent()
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
            fetchEmergencies()
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(Color.clear)
    }
    
    // MARK: - Sidebar item
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
        .onTapGesture {
            selectedTab = tab
        }
    }
    
    // MARK: - Header
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
    
    // MARK: - User Management View
    @ViewBuilder
    func userManagementContent() -> some View {
        VStack(alignment: .leading, spacing: 24) {
            // Patients
            VStack(alignment: .leading, spacing: 8) {
                Text("Patients")
                    .font(.title2)
                    .bold()
                
                if isLoadingPatients {
                    ProgressView("Loading patients...")
                } else if patients.isEmpty {
                    Text("No patients found.")
                        .foregroundColor(.secondary)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(patients) { patient in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ID: \(patient.id)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(patient.first_name) \(patient.last_name)")
                                        .font(.headline)
                                    Text(patient.email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(height: 250)
                }
            }
            
            // Staff
            VStack(alignment: .leading, spacing: 8) {
                Text("Medical Staff")
                    .font(.title2)
                    .bold()
                
                if isLoadingStaff {
                    ProgressView("Loading staff...")
                } else if staff.isEmpty {
                    Text("No staff found.")
                        .foregroundColor(.secondary)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(staff) { member in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ID: \(member.id)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(member.first_name) \(member.last_name) — \(member.role)")
                                        .font(.headline)
                                    Text(member.email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("\(member.department) | \(member.specialization)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(height: 250)
                }
            }
        }
    }
    
    // MARK: - Emergency Dispatch View
    @ViewBuilder
    func emergencyDispatchContent() -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Emergency Dispatch")
                .font(.title)
                .fontWeight(.bold)
            
            if isLoadingEmergencies {
                ProgressView("Loading emergencies...")
            } else if emergencies.isEmpty {
                Text("No emergencies available.")
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(emergencies) { emergency in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(emergency.title)
                                    .font(.headline)
                                Text("Urgency: \(emergency.urgency)")
                                    .font(.subheadline)
                                Text("Location: \(emergency.location)")
                                    .font(.subheadline)
                                Text("Status: \(emergency.status)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onTapGesture {
                                selectedEmergency = emergency
                                showStatusSheet = true
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Update Status Sheet
    func updateStatusSheet(for emergency: EmergencyRequest) -> some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Update Status")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Emergency: \(emergency.title)")
                    .font(.headline)
                
                TextField("New Status (e.g., pending, completed)", text: $newStatus)
                    .textFieldStyle(.roundedBorder)
                
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
    // MARK: - API
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
    // MARK: - Add Medical Staff Form View
    struct AddMedicalStaffView: View {
        @Environment(\.dismiss) var dismiss
        
        @State private var firstName = ""
        @State private var lastName = ""
        @State private var email = ""
        @State private var phone = ""
        @State private var password = ""
        @State private var department = ""
        @State private var role = ""
        @State private var specialization = ""
        @State private var message = ""
        @State private var messageColor: Color = .green
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Add Medical Staff")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Group {
                        field("First Name", text: $firstName)
                        field("Last Name", text: $lastName)
                        field("Email", text: $email)
                        field("Phone", text: $phone)
                        field("Password", text: $password)
                        field("Department", text: $department)
                        field("Role", text: $role)
                        field("Specialization", text: $specialization)
                    }
                    
                    if !message.isEmpty {
                        Text(message)
                            .foregroundColor(messageColor)
                            .font(.footnote)
                    }
                    
                    Button("Submit") {
                        submitStaff()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
                }
                .padding()
            }
        }
        
        func field(_ placeholder: String, text: Binding<String>) -> some View {
            TextField(placeholder, text: text)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        
        func submitStaff() {
            var components = URLComponents(string: "https://salemalkaabi.pythonanywhere.com/add_staff")!
            components.queryItems = [
                .init(name: "first_name", value: firstName),
                .init(name: "last_name", value: lastName),
                .init(name: "email", value: email),
                .init(name: "phone", value: phone),
                .init(name: "password", value: password),
                .init(name: "department", value: department),
                .init(name: "role", value: role),
                .init(name: "specialization", value: specialization)
            ]
            
            guard let url = components.url else {
                message = "Invalid request"
                messageColor = .red
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        message = "Error: \(error.localizedDescription)"
                        messageColor = .red
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        message = "No server response"
                        messageColor = .red
                        return
                    }
                    
                    switch httpResponse.statusCode {
                    case 201:
                        message = "✅ Staff added successfully"
                        messageColor = .green
                    case 409:
                        message = "❌ Email already exists"
                        messageColor = .red
                    default:
                        message = "⚠️ Server error (\(httpResponse.statusCode))"
                        messageColor = .red
                    }
                }
            }.resume()
        }
    }
}
