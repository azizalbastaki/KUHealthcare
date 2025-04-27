import SwiftUI

extension AdminDashboardView {
    
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
}
