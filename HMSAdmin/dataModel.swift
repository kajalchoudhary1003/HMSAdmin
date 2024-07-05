//  DataModel.swift
//  HMSAdmin
//
//  Created by Shekhar Patel on 05/07/24.
//
import Foundation
import Firebase
import FirebaseFirestoreSwift


//Patient Model
//struct Patient: Hashable, Codable, Identifiable {
//    @DocumentID var id: String?
//    var firstName: String
//    var lastName: String
//    var email: String
//    var dob: Date
//    var sex: String
//    var bloodtype: String
//    @ServerTimestamp var lastUpdated: Timestamp?
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case firstName
//        case lastName
//        case email
//        case dob
//        case sex
//        case bloodtype
//        case lastUpdated
//    }
//    
//    init(firstName: String, lastName: String, email: String, dob: Date, sex: String, bloodtype: String, lastUpdated: Timestamp? = nil) {
//        self.firstName = firstName
//        self.lastName = lastName
//        self.email = email
//        self.dob = dob
//        self.sex = sex
//        self.bloodtype = bloodtype
//        self.lastUpdated = lastUpdated
//    }
//    
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        id = try values.decodeIfPresent(String.self, forKey: .id)
//        firstName = try values.decode(String.self, forKey: .firstName)
//        lastName = try values.decode(String.self, forKey: .lastName)
//        email = try values.decode(String.self, forKey: .email)
//        dob = try values.decode(Date.self, forKey: .dob)
//        sex = try values.decode(String.self, forKey: .sex)
//        bloodtype = try values.decode(String.self, forKey: .bloodtype)
//        lastUpdated = try values.decodeIfPresent(Timestamp.self, forKey: .lastUpdated)
//    }
//}
enum DoctorDesignation: String, Codable, CaseIterable {
    case generalPractitioner = "General Practitioner"
    case pediatrician = "Pediatrician"
    case cardiologist = "Cardiologist"
    case dermatologist = "Dermatologist"

    var title: String {
        return self.rawValue
    }

    var fees: String {
        switch self {
        case .generalPractitioner: return "$100"
        case .pediatrician: return "$120"
        case .cardiologist: return "$150"
        case .dermatologist: return "$130"
        }
    }

    var interval: String {
        switch self {
        case .generalPractitioner: return "9:00 AM - 11:00 AM"
        case .pediatrician: return "11:00 AM - 1:00 PM"
        case .cardiologist: return "2:00 PM - 4:00 PM"
        case .dermatologist: return "4:00 PM - 6:00 PM"
        }
    }
}

struct Doctor: Hashable, Codable, Identifiable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var starts: Date
    var ends: Date
    var dob: Date
    var designation: DoctorDesignation
    var titles: String
    var interval: String {
        return designation.interval
    }
    var fees: String {
        return designation.fees
    }

    init(id: String? = nil, firstName: String, lastName: String, email: String, phone: String, starts: Date, ends: Date, dob: Date, designation: DoctorDesignation, titles: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.starts = starts
        self.ends = ends
        self.dob = dob
        self.designation = designation
        self.titles = titles
    }

}

struct Admin: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var address: String
    var email: String
    var phone: String
}

struct Hospital: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var phone: String
    var admins: [Admin]
    var address: String
    var city: String
    var country: String
    var zipCode: String
    var type: String
    
    init(id: String? = nil, name: String, email: String, phone: String, admins: [Admin], address: String, city: String, country: String, zipCode: String, type: String) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.admins = admins
        self.address = address
        self.city = city
        self.country = country
        self.zipCode = zipCode
        self.type = type
    }
}

struct Appointment: Hashable, Codable {
    @DocumentID var id: String?
    var patientID: String
    var doctorID: String
    var date: Date
    var startTime: Date
    var endTime: Date
    
    enum CodingKeys: String, CodingKey {
        case id, patientID, doctorID, date, startTime, endTime
    }
    
    init(patientID: String, doctorID: String, date: Date, startTime: Date, endTime: Date, id: String? = nil) {
        self.id = id
        self.patientID = patientID
        self.doctorID = doctorID
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.patientID = try container.decode(String.self, forKey: .patientID)
        self.doctorID = try container.decode(String.self, forKey: .doctorID)
        self.date = try container.decode(Date.self, forKey: .date)
        self.startTime = try container.decode(Date.self, forKey: .startTime)
        self.endTime = try container.decode(Date.self, forKey: .endTime)
    }
}
