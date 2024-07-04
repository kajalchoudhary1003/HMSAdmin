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
                   let hospital = try? Hospital(from: hospitalData) {
                    self.hospitals[hospital.id] = hospital
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name("HospitalsUpdated"), object: nil)
        }
    }
    
    func addHospital(_ hospital: Hospital, completion: @escaping (Error?) -> Void) {
        let ref = database.child("hospitals").child(hospital.id)
        ref.setValue(hospital.toDictionary()) { error, _ in
            if let error = error {
                completion(error)
                return
            }
            self.hospitals[hospital.id] = hospital
            NotificationCenter.default.post(name: NSNotification.Name("HospitalsUpdated"), object: nil)
            completion(nil)
        }
    }
    
    func getHospitals() -> [Hospital] {
        return Array(hospitals.values)
    }
    
    func removeHospital(_ hospital: Hospital, completion: @escaping (Error?) -> Void) {
        let ref = database.child("hospitals").child(hospital.id)
        ref.removeValue { error, _ in
            if let error = error {
                completion(error)
                return
            }
            self.hospitals.removeValue(forKey: hospital.id)
            NotificationCenter.default.post(name: NSNotification.Name("HospitalsUpdated"), object: nil)
            completion(nil)
        }
    }
}

extension Hospital {
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "address": address,
            "phone": phone,
            "email": email,
            "type": type
        ]
    }
    
    init?(from dictionary: [String: Any]) throws {
        guard let id = dictionary["id"] as? String,
              let name = dictionary["name"] as? String,
              let address = dictionary["address"] as? String,
              let phone = dictionary["phone"] as? String,
              let email = dictionary["email"] as? String,
              let type = dictionary["type"] as? String else {
            return nil
        }
        self.init(id: id, name: name, address: address, phone: phone, email: email, type: type)
    }
}
