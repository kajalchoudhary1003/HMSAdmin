import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Patient: Identifiable, Codable {
    let id: String
    let firstName: String
    let lastName: String
    let bloodGroup: String
    let dateOfBirth: Date
    let emergencyPhone: String
    let gender: String
    
    init?(from dictionary: [String: Any], id: String) {
        guard let firstName = dictionary["firstName"] as? String,
              let lastName = dictionary["lastName"] as? String,
              let bloodGroup = dictionary["bloodGroup"] as? String,
              let dateOfBirthString = dictionary["dateOfBirth"] as? String,
              let emergencyPhone = dictionary["emergencyPhone"] as? String,
              let gender = dictionary["gender"] as? String else {
            return nil
        }
        
        let dateFormatter = ISO8601DateFormatter()
        guard let dateOfBirth = dateFormatter.date(from: dateOfBirthString) else {
            return nil
        }
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.bloodGroup = bloodGroup
        self.dateOfBirth = dateOfBirth
        self.emergencyPhone = emergencyPhone
        self.gender = gender
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
struct Doctor: Codable, Identifiable, Equatable {
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
    //var appointments:[Appointment]
    
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
struct AdminProfile: Identifiable, Codable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String

    var initials: String {
        return "\(firstName.prefix(1))\(lastName.prefix(1))"
    }

    init(id: String, firstName: String, lastName: String, email: String, phone: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
    }

    init?(from dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let firstName = dictionary["firstName"] as? String,
              let lastName = dictionary["lastName"] as? String,
              let email = dictionary["email"] as? String,
              let phone = dictionary["phone"] as? String else {
            return nil
        }
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "phone": phone
        ]
    }
}



// Struct to represent a Hospital
struct Hospital: Codable, Identifiable, Equatable {
    var id: String?
    var name: String
    var email: String
    var phone: String
    var admins: [AdminProfile]
    var address: String
    var city: String
    var country: String
    var zipCode: String
    var type: String
    var latitude: Double
    var longitude: Double
    
    init(id: String? = nil, name: String, email: String, phone: String, admins: [AdminProfile], address: String, city: String, country: String, zipCode: String, type: String, latitude: Double, longitude: Double) {
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
        self.latitude = latitude
        self.longitude = longitude
    }

    static func == (lhs: Hospital, rhs: Hospital) -> Bool {
        return lhs.id == rhs.id
    }

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
            "latitude": latitude,
            "longitude": longitude,
            "admins": admins.map { $0.toDictionary() }
        ]
    }

    init?(from dictionary: [String: Any], id: String) {
        guard let name = dictionary["name"] as? String,
              let address = dictionary["address"] as? String,
              let phone = dictionary["phone"] as? String,
              let email = dictionary["email"] as? String,
              let type = dictionary["type"] as? String,
              let city = dictionary["city"] as? String,
              let country = dictionary["country"] as? String,
              let zipCode = dictionary["zipCode"] as? String,
              let latitude = dictionary["latitude"] as? Double,
              let longitude = dictionary["longitude"] as? Double,
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
        self.latitude = latitude
        self.longitude = longitude
        self.admins = adminsData.compactMap { AdminProfile(from: $0) }
    }
}


// Struct to represent an Appointment
struct Appointment: Hashable, Codable, Identifiable {
    @DocumentID var id: String?
    var patientID: String
    var doctorID: String
    var date: Date
    var timeSlotID: String
    var prescription: String?
    
    enum CodingKeys: String, CodingKey {
        case id, patientID, doctorID, date, timeSlotID, prescription
    }
    
    init(patientID: String, doctorID: String, date: Date, timeSlotID: String, id: String? = nil, prescription: String?) {
        self.id = id
        self.patientID = patientID
        self.doctorID = doctorID
        self.date = date
        self.timeSlotID = timeSlotID
        self.prescription = prescription
    }
}

//struct for staff
struct Staff: Identifiable, Codable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var phoneNumber: String
    var email: String
    var position: String
    var department: String
    var employmentStatus: String

    init(id: String? = nil, firstName: String, lastName: String, dateOfBirth: Date, phoneNumber: String, email: String, position: String, department: String, employmentStatus: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.phoneNumber = phoneNumber
        self.email = email
        self.position = position
        self.department = department
        self.employmentStatus = employmentStatus
    }
    
    var age: Int {
        let now = Date()
        let ageComponents = Calendar.current.dateComponents([.year], from: dateOfBirth, to: now)
        return ageComponents.year ?? 0
    }
}
