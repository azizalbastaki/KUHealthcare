//
//  ResourceManagementView.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 29/04/2025.
//
import SwiftUI

struct AdminResourceManagementView: View {
    enum ResourceTab {
        case medication, equipment, consumable
    }
    
    @State private var selectedTab: ResourceTab = .medication
    @State private var medications: [Medication] = []
    @State private var equipment: [Equipment] = []
    @State private var consumables: [Consumable] = []
    
    @State private var showAddSheet = false
    
    var body: some View {
        VStack {
            // Top Picker
            Picker("Select Resource", selection: $selectedTab) {
                Text("Medications").tag(ResourceTab.medication)
                Text("Equipment").tag(ResourceTab.equipment)
                Text("Consumables").tag(ResourceTab.consumable)
            }
            .pickerStyle(.segmented)
            .padding()
            
            Divider()
            
            HStack {
                Spacer()
                Button(action: {
                    showAddSheet = true
                }) {
                    Label("Add Resource", systemImage: "plus.circle.fill")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch selectedTab {
                    case .medication:
                        medicationsView
                    case .equipment:
                        equipmentView
                    case .consumable:
                        consumablesView
                    }
                }
                .padding()
            }
        }
        .onAppear {
            fetchMedications()
            fetchEquipment()
            fetchConsumables()
        }
        .sheet(isPresented: $showAddSheet) {
            addResourceForm()
        }
    }
    
    // MARK: - Add Resource Form
    @ViewBuilder
    func addResourceForm() -> some View {
        switch selectedTab {
        case .medication:
            AddMedicationView { fetchMedications() }
        case .equipment:
            AddEquipmentView { fetchEquipment() }
        case .consumable:
            AddConsumableView { fetchConsumables() }
        }
    }
    
    // MARK: - Resource Views
    var medicationsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Medications")
                .font(.title2)
                .bold()
            ForEach(medications) { med in
                VStack(alignment: .leading, spacing: 6) {
                    Text(med.name)
                        .font(.headline)
                    Text("Quantity: \(med.quantity)")
                        .font(.subheadline)
                    Text("Expiration: \(med.expiration_date)")
                        .font(.subheadline)
                    Text("Status: \(med.status)")
                        .font(.subheadline)
                        .foregroundColor(med.status.lowercased() == "in stock" ? .green : .red)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    var equipmentView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Equipment")
                .font(.title2)
                .bold()
            ForEach(equipment) { eq in
                VStack(alignment: .leading, spacing: 6) {
                    Text(eq.name)
                        .font(.headline)
                    Text("Maintenance Due: \(eq.maintenance_due_date)")
                        .font(.subheadline)
                        .foregroundColor(isMaintenanceSoon(dateString: eq.maintenance_due_date) ? .red : .secondary)
                    
                    if isMaintenanceSoon(dateString: eq.maintenance_due_date) {
                        Text("⚠️ Maintenance due soon!")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    var consumablesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Consumables")
                .font(.title2)
                .bold()
            ForEach(consumables) { con in
                VStack(alignment: .leading, spacing: 6) {
                    Text(con.name)
                        .font(.headline)
                    Text("Quantity: \(con.quantity)")
                        .font(.subheadline)
                    Text("Status: \(con.status)")
                        .font(.subheadline)
                        .foregroundColor(con.status.lowercased() == "in stock" ? .green : .red)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    // MARK: - Fetch Functions
    func fetchMedications() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/get_medications") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([Medication].self, from: data) {
                DispatchQueue.main.async {
                    self.medications = decoded
                }
            }
        }.resume()
    }
    
    func fetchEquipment() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/get_equipment") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([Equipment].self, from: data) {
                DispatchQueue.main.async {
                    self.equipment = decoded
                }
            }
        }.resume()
    }
    
    func fetchConsumables() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/get_consumables") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([Consumable].self, from: data) {
                DispatchQueue.main.async {
                    self.consumables = decoded
                }
            }
        }.resume()
    }
    
    // MARK: - Helpers
    func isMaintenanceSoon(dateString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let dueDate = formatter.date(from: dateString) {
            let today = Date()
            let diff = Calendar.current.dateComponents([.day], from: today, to: dueDate).day ?? 0
            return diff >= 0 && diff <= 7
        }
        return false
    }
}

struct AddMedicationView: View {
    @Environment(\.dismiss) var dismiss
    var refresh: () -> Void

    @State private var name = ""
    @State private var quantityString = ""  // ← String input
    @State private var expirationDate = Date()

    @State private var message: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Medication")
                    .font(.title)
                    .fontWeight(.bold)

                TextField("Medication Name", text: $name)
                    .textFieldStyle(.roundedBorder)

                TextField("Quantity", text: $quantityString)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)

                if let msg = message {
                    Text(msg)
                        .foregroundColor(.red)
                }

                Button("Submit") {
                    submitMedication()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button("Cancel") {
                    dismiss()
                }
                .padding()
            }
            .padding()
            .navigationTitle("New Medication")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func submitMedication() {
        guard let quantity = Int(quantityString), !name.isEmpty else {
            message = "⚠️ Please fill all fields correctly."
            return
        }

        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/add_medication") else {
            message = "⚠️ Invalid server URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let body: [String: Any] = [
            "name": name,
            "quantity": quantity,
            "expiration_date": formatter.string(from: expirationDate)
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                   let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if responseJSON["message"] != nil {
                        refresh()
                        dismiss()
                    } else if let errorMsg = responseJSON["error"] as? String {
                        message = "❌ \(errorMsg)"
                    } else {
                        message = "❌ Unknown server error"
                    }
                } else {
                    message = "❌ Failed to connect to server"
                }
            }
        }.resume()
    }
}

struct AddEquipmentView: View {
    @Environment(\.dismiss) var dismiss
    var refresh: () -> Void

    @State private var name = ""
    @State private var maintenanceDue = Date()
    @State private var message: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Equipment")
                    .font(.title)
                    .fontWeight(.bold)

                TextField("Equipment Name", text: $name)
                    .textFieldStyle(.roundedBorder)

                DatePicker("Maintenance Due", selection: $maintenanceDue, displayedComponents: .date)

                if let msg = message {
                    Text(msg).foregroundColor(.red)
                }

                Button("Submit") {
                    submitEquipment()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button("Cancel") {
                    dismiss()
                }
                .padding()
            }
            .padding()
            .navigationTitle("New Equipment")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func submitEquipment() {
        guard !name.isEmpty else {
            message = "⚠️ Fill all fields."
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let body: [String: Any] = [
            "name": name,
            "maintenance_due_date": formatter.string(from: maintenanceDue)
        ]

        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/add_equipment") else {
            message = "⚠️ Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   json["message"] != nil {
                    refresh()
                    dismiss()
                } else {
                    message = "❌ Failed to add equipment"
                }
            }
        }.resume()
    }
}


struct AddConsumableView: View {
    @Environment(\.dismiss) var dismiss
    var refresh: () -> Void

    @State private var name = ""
    @State private var quantityString = ""
    @State private var message: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Consumable")
                    .font(.title)
                    .fontWeight(.bold)

                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)

                TextField("Quantity", text: $quantityString)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                if let msg = message {
                    Text(msg)
                        .foregroundColor(.red)
                }

                Button("Submit") {
                    submitConsumable()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button("Cancel") {
                    dismiss()
                }
            }
            .padding()
            .navigationTitle("New Consumable")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func submitConsumable() {
        guard let quantity = Int(quantityString), !name.isEmpty else {
            message = "⚠️ Please fill all fields correctly."
            return
        }

        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/add_consumable") else {
            message = "⚠️ Invalid server URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "name": name,
            "quantity": quantity,
            "status": "In Stock"  // 🔥 Always hardcoded here
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if json["message"] != nil {
                        refresh()
                        dismiss()
                    } else if let error = json["error"] as? String {
                        message = "❌ \(error)"
                    } else {
                        message = "❌ Unknown server error"
                    }
                } else {
                    message = "❌ Failed to connect to server"
                }
            }
        }.resume()
    }
}
