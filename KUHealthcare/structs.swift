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

