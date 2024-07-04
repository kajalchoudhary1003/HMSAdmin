//
//  DataModel.swift
//  HMSAdmin
//
//  Created by Shekhar Patel on 05/07/24.
//
import Foundation
import Firebase
import FirebaseFirestoreSwift


//Patient Model
struct Patient: Hashable, Codable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var email: String
    var dob: Date
    var sex: String
    var bloodtype: String
    @ServerTimestamp var lastUpdated: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case email
        case dob
        case sex
        case bloodtype
        case lastUpdated
    }
    
    init(firstName: String, lastName: String, email: String, dob: Date, sex: String, bloodtype: String, lastUpdated: Timestamp? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.dob = dob
        self.sex = sex
        self.bloodtype = bloodtype
        self.lastUpdated = lastUpdated
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        firstName = try values.decode(String.self, forKey: .firstName)
        lastName = try values.decode(String.self, forKey: .lastName)
        email = try values.decode(String.self, forKey: .email)
        dob = try values.decode(Date.self, forKey: .dob)
        sex = try values.decode(String.self, forKey: .sex)
        bloodtype = try values.decode(String.self, forKey: .bloodtype)
        lastUpdated = try values.decodeIfPresent(Timestamp.self, forKey: .lastUpdated)
    }
}
enum DoctorDesignation: String, Codable {
    case generalPractitioner = "General Practitioner"
    case pediatrician = "Pediatrician"
    case cardiologist = "Cardiologist"
    case dermatologist = "Dermatologist"
    case neurologist = "Neurologist"

    var interval: String {
        switch self {
        case .generalPractitioner:
            return "15 minutes"
        case .pediatrician:
            return "20 minutes"
        case .cardiologist:
            return "30 minutes"
        case .dermatologist:
            return "25 minutes"
        case .neurologist:
            return "30 minutes"
        }
    }
    
    var fees: String {
        switch self  {
        case .generalPractitioner:
            return "600"
        case .pediatrician:
            return "400"
        case .cardiologist:
            return "600"
        case .dermatologist:
            return "300"
        case .neurologist:
            return "200"
        }
    }
}

struct Doctor: Hashable, Codable {
    @DocumentID var id: String?
    var name:String
    var email:String
    var address:String
    var phone:String
    var sex:String
    var starts:Date
    var ends:Date
    var interval: String {
            return designation.interval
        }
    var designation:DoctorDesignation
    var titles:String
    var fees: String {
        return designation.fees
    }
    init(id: String? = nil, name: String, email: String, address: String, phone: String, sex: String, starts: Date, ends: Date, designation: DoctorDesignation, titles: String) {
        self.id = id
        self.name = name
        self.email = email
        self.address = address
        self.phone = phone
        self.sex = sex
        self.starts = starts
        self.ends = ends
        self.designation = designation
        self.titles = titles
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.address = try container.decode(String.self, forKey: .address)
        self.phone = try container.decode(String.self, forKey: .phone)
        self.sex = try container.decode(String.self, forKey: .sex)
        self.starts = try container.decode(Date.self, forKey: .starts)
        self.ends = try container.decode(Date.self, forKey: .ends)
        self.designation = try container.decode(DoctorDesignation.self, forKey: .designation)
        self.titles = try container.decode(String.self, forKey: .titles)
    }
}

//struct Admin: String,Codable {
//    var name: String
//    var address: String
//    var email: String
//    var phone: String
//}
//
//struct Hospital: Hashable,Codable {
//    
//    @DocumentID var id: String?
//    var name:String
//    var email:String
//    var phone:String
//    var admins:[Admin]
//    var address:String
//    var city:String
//    var country:String
//    var zipcode:String
//    init(id: String? = nil, name: String, email: String, phone: String, admins: [Admin]) {
//        self.id = id
//        self.name = name
//        self.email = email
//        self.phone = phone
//        self.admins = admins
//    }
//    init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decodeIfPresent(String.self, forKey: .id)
//        self.name = try container.decode(String.self, forKey: .name)
//        self.email = try container.decode(String.self, forKey: .email)
//        self.phone = try container.decode(String.self, forKey: .phone)
//        self.admins = try container.decode([Admin].self, forKey: .admins)
//    }
//}

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
