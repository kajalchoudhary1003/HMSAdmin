import Foundation
import Firebase
import FirebaseFirestoreSwift


struct Patient: Codable, Identifiable{
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var age: Int
    var type: String
    var appointmentDate: Date
    
    init(id: String? = nil, firstName: String, lastName: String, age: Int, type: String, appointmentDate: Date) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.type = type
        self.appointmentDate = appointmentDate
    }
    
    init?(from dictionary: [String: Any], id: String){
        guard let firstName = dictionary["firstName"] as? String,
              let lastName = dictionary["lastName"] as? String,
              let age = dictionary["age"] as? Int,
              let type = dictionary["type"] as? String,
                            let appointmentDate = dictionary["appointmentDate"] as? Date else {
                          return nil
                      }
        self.id = id
               self.firstName = firstName
        self.lastName = lastName
               self.age = age
               self.type = type
               self.appointmentDate = appointmentDate
    }
    
    // Function to convert Patient to dictionary for Firebase
        func toDictionary() -> [String: Any] {
            return [
                "id": id ?? UUID().uuidString,
                "firstName" : firstName,
                "lastName" : lastName,
                "age": age,
                "type": type,
                "appointmentDate": appointmentDate
            ]
        }
}

// Enumeration for Doctor's Designation with associated properties
enum DoctorDesignation: String, Codable, CaseIterable {
    case generalPractitioner = "General Practitioner"
    case pediatrician = "Pediatrician"
    case cardiologist = "Cardiologist"
    case dermatologist = "Dermatologist"

    // Returns the title of the designation
    var title: String {
        return self.rawValue
    }

    // Returns the fees associated with the designation
    var fees: String {
        switch self {
        case .generalPractitioner: return "$100"
        case .pediatrician: return "$120"
        case .cardiologist: return "$150"
        case .dermatologist: return "$130"
        }
    }

    // Returns the consultation interval associated with the designation
    var interval: String {
        switch self {
        case .generalPractitioner: return "9:00 AM - 11:00 AM"
        case .pediatrician: return "11:00 AM - 1:00 PM"
        case .cardiologist: return "2:00 PM - 4:00 PM"
        case .dermatologist: return "4:00 PM - 6:00 PM"
        }
    }
}

// Struct to represent a Doctor
struct Doctor: Codable, Identifiable,Equatable {
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
    
    // Computed property to return the consultation interval based on the designation
    var interval: String {
        return designation.interval
    }
    
    // Computed property to return the fees based on the designation
    var fees: String {
        return designation.fees
    }

    init(id: String?, firstName: String, lastName: String, email: String, phone: String, starts: Date, ends: Date, dob: Date, designation: DoctorDesignation, titles: String) {
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
    
    static func == (lhs: Doctor, rhs: Doctor) -> Bool {
        return lhs.id == rhs.id
    }
}

// Struct to represent an Admin
struct Admin: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var address: String
    var email: String
    var phone: String
}

// Struct to represent a Hospital
struct Hospital: Codable, Identifiable, Equatable {
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
    
    
    // Initializer for the Hospital struct
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

    // Equatable conformance to compare two Hospital instances
    static func == (lhs: Hospital, rhs: Hospital) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Converts the Hospital instance to a dictionary
    func toDictionary() -> [String: Any] {
        return [
            "id": id ?? UUID().uuidString,
            "name": name,
            "address": address,
            "phone": phone,
            "email": email,
            "type": type,
            "city": city,
            "country": country,
            "zipCode": zipCode,
            "admins": admins.map { $0.toDictionary() }
        ]
    }
    
    // Initializes a Hospital instance from a dictionary
    init?(from dictionary: [String: Any], id: String) {
        guard let name = dictionary["name"] as? String,
              let address = dictionary["address"] as? String,
              let phone = dictionary["phone"] as? String,
              let email = dictionary["email"] as? String,
              let type = dictionary["type"] as? String,
              let city = dictionary["city"] as? String,
              let country = dictionary["country"] as? String,
              let zipCode = dictionary["zipCode"] as? String,
              let adminsData = dictionary["admins"] as? [[String: Any]] else {
            return nil
        }
        self.id = id
        self.name = name
        self.address = address
        self.phone = phone
        self.email = email
        self.type = type
        self.city = city
        self.country = country
        self.zipCode = zipCode
        self.admins = adminsData.compactMap { Admin(from: $0) }
    }
}

// Struct to represent an Appointment
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
    
    // Initializer for the Appointment struct
    init(patientID: String, doctorID: String, date: Date, startTime: Date, endTime: Date, id: String? = nil) {
        self.id = id
        self.patientID = patientID
        self.doctorID = doctorID
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
    }
    
    // Initializer to decode Appointment instance from a decoder
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

// Extension to convert Admin instances to dictionary and initialize from dictionary
extension Admin {
    // Converts the Admin instance to a dictionary
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "address": address,
            "email": email,
            "phone": phone
        ]
    }
    
    // Initializes an Admin instance from a dictionary
    init?(from dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
              let address = dictionary["address"] as? String,
              let email = dictionary["email"] as? String,
              let phone = dictionary["phone"] as? String else {
            return nil
        }
        self.name = name
        self.address = address
        self.email = email
        self.phone = phone
    }
}
