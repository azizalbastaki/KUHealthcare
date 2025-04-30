//
//  BillingReportView.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 30/04/2025.
//

import SwiftUI

struct AdminBillingReportsView: View {
    @State private var reports: [BillingReport] = []
    @State private var selectedReport: BillingReport?

    var body: some View {
        NavigationView {
            List(reports) { report in
                Button {
                    selectedReport = report
                } label: {
                    VStack(alignment: .leading) {
                        Text("Appointment ID: \(report.appointment_id)")
                        Text("Paid on \(report.date_paid)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Billing Reports")
            .onAppear {
                fetchBillingReports()
            }
            .sheet(item: $selectedReport) { report in
                BillingReportDetailView(report: report)
            }
        }
    }

    func fetchBillingReports() {
        guard let url = URL(string: "https://salemalkaabi.pythonanywhere.com/get_billing") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([BillingReport].self, from: data) {
                DispatchQueue.main.async {
                    self.reports = decoded
                }
            }
        }.resume()
    }
}

struct BillingReportDetailView: View {
    let report: BillingReport
    @Environment(\.dismiss) var dismiss  // ✅ Add this

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Billing Report Details")
                .font(.title2)
                .bold()

            Group {
                Text("ID: \(report.id)")
                Text("Patient ID: \(report.patient_id)")
                Text("Appointment ID: \(report.appointment_id)")
                Text("Payment Type: \(report.payment_type)")
                Text("Date Paid: \(report.date_paid)")
                Text("Cost: AED 120")
            }

            Spacer()

            Button("Dismiss") {
                dismiss()  // ✅ Use dismiss here
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
    }
}
