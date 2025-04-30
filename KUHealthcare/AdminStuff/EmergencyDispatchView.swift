import SwiftUI
import CoreML

struct EmergencyDispatchView: View {
    @Binding var emergencies: [EmergencyRequest]
    @Binding var selectedEmergency: EmergencyRequest?
    @Binding var newStatus: String
    @Binding var showStatusSheet: Bool
    @Binding var showForecastSheet: Bool
    @Binding var isLoadingEmergencies: Bool
    @Binding var message: String?
    
    var body: some View {
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
                                Text("Location: \(emergency.location)")
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

            Button("Predict Ambulance Demand") {
                showForecastSheet = true
            }
            .buttonStyle(.borderedProminent)
            
        }
        .padding()
    }
}

struct AmbulanceForecastView: View {
    @Environment(\.dismiss) var dismiss

    @State private var isMarathon = false
    @State private var isHoliday = false
    @State private var isFestival = false
    @State private var isWeekend = false
    @State private var isSportsEvent = false
    @State private var temperature: Double = 30.0

    @State private var prediction: Int?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Conditions")) {
                    Toggle("Marathon", isOn: $isMarathon)
                    Toggle("Holiday", isOn: $isHoliday)
                    Toggle("Festival", isOn: $isFestival)
                    Toggle("Weekend", isOn: $isWeekend)
                    Toggle("Sports Event", isOn: $isSportsEvent)
                }

                Section(header: Text("Weather")) {
                    HStack {
                        Text("Temperature")
                        Spacer()
                        Text("\(Int(temperature))°C")
                    }
                    Slider(value: $temperature, in: 15...50, step: 1)
                }

                Section {
                    Button("Predict Ambulances") {
                        prediction = 4  // 🔧 Hardcoded for now
                    }
                }

                if let result = prediction {
                    Section(header: Text("Forecast")) {
                        Text("Recommended Ambulances: \(result)")
                            .font(.title)
                            .bold()
                            .foregroundColor(.blue)
                    }
                }

                Button("Close") {
                    dismiss()
                }
                .foregroundColor(.red)
            }
            .navigationTitle("Forecast Ambulance Need")
        }
    }
}
