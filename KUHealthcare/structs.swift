//
//  structs.swift
//  KUHealthcare
//
//  Created by Abdulaziz Albastaki on 22/04/2025.
//
struct Patient: Identifiable, Codable {
    let id: String
    let first_name: String
    let last_name: String
    let email: String
}

struct MedicalStaff: Identifiable, Codable {
    let id: String
    let first_name: String
    let last_name: String
    let email: String
    let department: String
    let role: String
    let specialization: String
}

struct MedicalStaffScheduling: Identifiable, Codable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var role: String
    var specialization: String
    var schedule: [String: Bool]

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case role
        case specialization
        case schedule
    }
}

struct LoggedInPatient: Identifiable, Codable {
    let id: String
    let first_name: String
    let last_name: String
    let email: String
    let gender: String
    let date_of_birth: String
}

struct LoggedInStaff: Identifiable, Codable {
    let id: String
    let first_name: String
    let last_name: String
    let email: String
    let department: String
    let role: String
    let specialization: String
}

struct PatientResponse: Codable {
    let message: String
    let patient: LoggedInPatient
}

struct StaffResponse: Codable {
    let message: String
    let staff: LoggedInStaff
}


enum UserType: Identifiable {
    var id: String {
        switch self {
        case .admin: return "admin"
        case .patient(let p): return "patient-\(p.id)"
        case .staff(let s): return "staff-\(s.id)"
        }
    }

    case admin
    case patient(LoggedInPatient)
    case staff(LoggedInStaff)
}

struct EmergencyRequest: Identifiable, Codable {
    let id: String
    let title: String
    let location: String
    let urgency: String
    let patient_email: String
    var status: String
}


struct Appointment: Identifiable, Codable {
    let id: String
    let staff_id: String
    let date: String
    let time: String
    let reason: String
    let appointment_type: String
    let status: String
    
}
