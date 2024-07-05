import Foundation
import FirebaseDatabase

class DataController {
    
    static let shared = DataController()
    
    private var database: DatabaseReference
    private var hospitals: [String: Hospital] = [:]
    
    private init() {
        self.database = Database.database(url: "https://hms-team02-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
        fetchHospitals()
    }
    
    func fetchHospitals() {
        let ref = database.child("hospitals")
        ref.observe(.value) { snapshot in
            self.hospitals = [:]
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let hospitalData = childSnapshot.value as? [String: Any],
                   let hospital = Hospital(from: hospitalData) {
                    self.hospitals[hospital.id ?? UUID().uuidString] = hospital
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name("HospitalsUpdated"), object: nil)
        }
    }
    
    func addHospital(_ hospital: Hospital, completion: @escaping (Error?) -> Void) {
        let id = hospital.id ?? database.child("hospitals").childByAutoId().key ?? UUID().uuidString
        var hospitalWithID = hospital
        hospitalWithID.id = id
        
        let ref = database.child("hospitals").child(id)
        ref.setValue(hospitalWithID.toDictionary()) { error, _ in
            if let error = error {
                completion(error)
                return
            }
            self.hospitals[id] = hospitalWithID
            NotificationCenter.default.post(name: NSNotification.Name("HospitalsUpdated"), object: nil)
            completion(nil)
        }
    }
    
    func getHospitals() -> [Hospital] {
        return Array(hospitals.values)
    }
    
    func removeHospital(_ hospital: Hospital, completion: @escaping (Error?) -> Void) {
        guard let id = hospital.id else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Hospital ID is nil"]))
            return
        }
        
        let ref = database.child("hospitals").child(id)
        ref.removeValue { error, _ in
            if let error = error {
                completion(error)
                return
            }
            self.hospitals.removeValue(forKey: id)
            NotificationCenter.default.post(name: NSNotification.Name("HospitalsUpdated"), object: nil)
            completion(nil)
        }
    }
}

extension Hospital {
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
    
    init?(from dictionary: [String: Any]) {
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

extension Admin {
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "address": address,
            "email": email,
            "phone": phone
        ]
    }
    
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
