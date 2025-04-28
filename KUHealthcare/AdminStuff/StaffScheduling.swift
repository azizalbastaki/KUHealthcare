//
//  StaffScheduling.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 27/04/2025.
//

import SwiftUI

struct StaffSchedulingView: View {
    @Binding var staff: [MedicalStaffScheduling]

    @State private var selectedDay: String = "Monday"
    @State private var selectedStaffEmail: String = ""
    @State private var showAddSheet: Bool = false

    let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Staff Scheduling")
                .font(.largeTitle)
                .bold()
                .padding(.bottom)

            ScrollView {
                ForEach(weekdays, id: \.self) { day in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(day)
                                .font(.title3)
                                .bold()
                            Spacer()
                            Button(action: {
                                selectedDay = day
                                showAddSheet = true
                            }) {
                                Text("Add")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)

                        ForEach(staffAssigned(to: day)) { staff in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(staff.firstName) \(staff.lastName)")
                                        .font(.headline)
                                    Text("\(staff.role) – \(staff.specialization)")
                                        .font(.subheadline)
                                        //.foregroundColor(.white)
                                }
                                Spacer()
                                Button("Unassign") {
                                    unassignStaffFromDay(email: staff.email, day: day)
                                }
                                .foregroundColor(.red)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            VStack {
                if staff.isEmpty {
                    ProgressView("Loading staff...")
                        .padding()
                } else {
                    Picker("Select Staff", selection: $selectedStaffEmail) {
                        ForEach(staff, id: \.email) { member in
                            Text("\(member.firstName) \(member.lastName)").tag(member.email)
                        }
                    }
                    .pickerStyle(.wheel)
                    .padding()

                    Button("Assign to \(selectedDay)") {
                        if !selectedStaffEmail.isEmpty {
                            assignStaffToDay(email: selectedStaffEmail, day: selectedDay)
                        }
                        showAddSheet = false
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()

                    Button("Cancel") {
                        showAddSheet = false
                    }
                    .padding()
                }
            }
            .presentationDetents([.fraction(0.4)])
            .onAppear {
                if let first = staff.first {
                    selectedStaffEmail = first.email
                }
            }
        }
    }

    func staffAssigned(to day: String) -> [MedicalStaffScheduling] {
        staff.filter { $0.schedule[day] == true }
    }

    func assignStaffToDay(email: String, day: String) {
        guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedDay = day.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://salemalkaabi.pythonanywhere.com/assign_staff_day?email=\(encodedEmail)&day=\(encodedDay)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if error == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // Very simple: Refresh the staff after assignment
                    fetchUpdatedStaff()
                }
            }
        }.resume()
    }
    
    func unassignStaffFromDay(email: String, day: String) {
        guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedDay = day.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://salemalkaabi.pythonanywhere.com/assign_staff_day?email=\(encodedEmail)&day=\(encodedDay)&is_available=false") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if error == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    fetchUpdatedStaff()
                }
            }
        }.resume()
    }

    func fetchUpdatedStaff() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/all_staff") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data {
                    if let decoded = try? JSONDecoder().decode([MedicalStaffScheduling].self, from: data) {
                        self.staff = decoded
                    }
                }
            }
        }.resume()
    }
}
