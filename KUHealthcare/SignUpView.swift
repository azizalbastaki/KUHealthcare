import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var gender: String = "Male"
    @State private var dob: Date = Date()

    @State private var message: String = ""
    @State private var messageColor: Color = .green

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("New Patient Registration")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)

                    Group {
                        TextField("First Name", text: $firstName)
                        TextField("Last Name", text: $lastName)
                        TextField("Email Address", text: $email)
                            .keyboardType(.emailAddress)
                        TextField("Phone Number", text: $phone)
                            .keyboardType(.phonePad)
                        TextField("Password", text: $password) 
                        TextField("Verify Password", text: $confirmPassword)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gender")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Picker("", selection: $gender) {
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date of Birth")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        DatePicker("", selection: $dob, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }

                    if !message.isEmpty {
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(messageColor)
                            .transition(.opacity)
                    }

                    Button(action: {
                        submitSignUp()
                    }) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                }
                .padding(32)
            }
        }
    }

    // MARK: - Submit to Backend
    func submitSignUp() {
        guard password == confirmPassword else {
            message = "Passwords do not match"
            messageColor = .red
            return
        }

        var components = URLComponents(string: "https://salemalkaabi.pythonanywhere.com/add_patient")!

        components.queryItems = [
            URLQueryItem(name: "first_name", value: firstName),
            URLQueryItem(name: "last_name", value: lastName),
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "phone", value: phone),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "gender", value: gender),
            URLQueryItem(name: "date_of_birth", value: iso8601(from: dob))
        ]

        guard let url = components.url else {
            message = "Failed to create URL"
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
                    message = "No response from server"
                    messageColor = .red
                    return
                }

                switch httpResponse.statusCode {
                case 201:
                    message = "✅ Patient registered successfully!"
                    messageColor = .green
                case 409:
                    message = "❌ Email already exists."
                    messageColor = .red
                default:
                    message = "⚠️ Unexpected error occurred (code \(httpResponse.statusCode))"
                    messageColor = .red
                }
            }
        }.resume()
    }

    // MARK: - Format date for backend
    func iso8601(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
