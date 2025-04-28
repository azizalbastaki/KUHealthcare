import SwiftUI

extension AdminDashboardView {
    
    @ViewBuilder
    func userManagementContent() -> some View {
        VStack(alignment: .leading, spacing: 24) {
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
                                        //.foregroundColor(.secondary)
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
                                        //.foregroundColor(.gray)
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
}



import SwiftUI

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
