import SwiftUI

// MARK: - Main View
struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showSignUp = false

    @State private var userType: UserType? = nil
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)

                Text("Healthcare System - Log In")
                    .font(.title3)
                    .fontWeight(.semibold)

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    TextField("Password", text: $password)
                        .padding()
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button("Log In") {
                    let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

                    if trimmedEmail == "admin" && trimmedPassword == "admin" {
                        userType = .admin
                        return
                    } else {
                            login()
                        }

                        // ✅ Then call the actual login() method for patient/staff
                        login()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                if let message = errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundColor(.red)
                }

                Button("Don't have an account? Sign Up") {
                    showSignUp = true
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            .padding()
            .frame(width: 400)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(radius: 20)
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
        .fullScreenCover(item: $userType) { user in
            switch user {
            case .admin:
                AdminDashboardView()
            case .patient(let patient):
                PatientDashboardView(patient: patient)
            case .staff(let staff):
                StaffDashboardView(staff: staff)
            }
        }
    }

    func login() {
        errorMessage = nil
        
        if email.lowercased() == "admin" && password == "admin" {
            userType = .admin
            return
        }
        
   
            guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let encodedPassword = password.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: "https://salemalkaabi.pythonanywhere.com/login?email=\(encodedEmail)&password=\(encodedPassword)") else {
                errorMessage = "Invalid login URL"
                return
            }
            
            print("[DEBUG] Sending request to:", url.absoluteString)
            
            URLSession.shared.dataTask(with: url) { data, _, _ in
                DispatchQueue.main.async {
                    guard let data = data else {
                        errorMessage = "No response from server"
                        return
                    }
                    
                    let responseString = String(data: data, encoding: .utf8) ?? "N/A"
                    print("[DEBUG] Raw response string:", responseString)
                    
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let _ = json["patient"] {
                            if let decoded = try? JSONDecoder().decode(PatientResponse.self, from: data) {
                                self.userType = .patient(decoded.patient)
                            } else {
                                errorMessage = "⚠️ Could not decode patient"
                            }
                        } else if let _ = json["staff"] {
                            if let decoded = try? JSONDecoder().decode(StaffResponse.self, from: data) {
                                self.userType = .staff(decoded.staff)
                            } else {
                                errorMessage = "⚠️ Could not decode staff"
                            }
                        } else if let err = json["error"] as? String {
                            errorMessage = err
                        } else {
                            errorMessage = "⚠️ Unknown response from server"
                        }
                    } else {
                        errorMessage = "⚠️ Failed to parse server response"
                    }
                }
            }.resume()
        }
    
}
