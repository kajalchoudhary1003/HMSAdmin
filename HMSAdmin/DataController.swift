import Foundation
import FirebaseDatabase

class DataController {
    
    // Singleton instance of DataController
    static let shared = DataController()
    
    private var database: DatabaseReference
    private var hospitals: [String: Hospital] = [:]
    private var doctors: [String: Doctor] = [:]
    
    private init() {
        // Initialize the Firebase database reference
        self.database = Database.database(url: "https://hms-team02-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
        fetchHospitals()
        fetchDoctors()
    }
    
    // Fetch hospitals data from Firebase
    func fetchHospitals() {
        let ref = database.child("hospitals")
        ref.observe(.value) { snapshot in
            self.hospitals = [:] // Clear the hospitals dictionary
            print("Snapshot has \(snapshot.childrenCount) children.")
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let hospitalData = childSnapshot.value as? [String: Any],
                   let hospital = Hospital(from: hospitalData, id: childSnapshot.key) {
                    self.hospitals[hospital.id ?? UUID().uuidString] = hospital
                    print("Added hospital: \(hospital.name) with ID: \(hospital.id ?? "unknown")")
                } else {
                    print("Failed to parse hospital data from snapshot.")
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name("HospitalsUpdated"), object: nil)
        }
    }
    
    // Add a hospital to Firebase
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
    
    // Add a doctor to Firebase
    func addDoctor(_ doctor: Doctor, completion: @escaping (Error?) -> Void) {
        let id = doctor.id ?? database.child("doctors").childByAutoId().key ?? UUID().uuidString
        var doctorWithID = doctor
        doctorWithID.id = id
        
        let ref = database.child("doctors").child(id)
        ref.setValue(doctorWithID.toDictionary()) { error, _ in
            if let error = error {
                completion(error)
                return
            }
            self.doctors[id] = doctorWithID
            NotificationCenter.default.post(name: NSNotification.Name("DoctorsUpdated"), object: nil)
            completion(nil)
        }
    }
    
    // Fetch doctors data from Firebase
    func fetchDoctors() {
        let ref = database.child("doctors")
        ref.observe(.value) { snapshot in
            self.doctors = [:] // Clear the doctors dictionary
            print("Snapshot has \(snapshot.childrenCount) children.")
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let doctorData = childSnapshot.value as? [String: Any],
                   let doctor = Doctor(from: doctorData, id: childSnapshot.key) {
                    self.doctors[doctor.id ?? UUID().uuidString] = doctor
                    print("Added doctor: \(doctor.firstName) \(doctor.lastName) with ID: \(doctor.id ?? "unknown")")
                } else {
                    print("Failed to parse doctor data from snapshot.")
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name("DoctorsUpdated"), object: nil)
        }
    }
    func deleteDoctor(_ doctor: Doctor, completion: @escaping (Error?) -> Void) {
            guard let doctorID = doctor.id else {
                completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Doctor ID is nil"]))
                return
            }
            let ref = database.child("doctors").child(doctorID)
            ref.removeValue { error, _ in
                if let error = error {
                    print("Error deleting doctor: \(error.localizedDescription)")
                    completion(error)
                } else {
                    self.doctors.removeValue(forKey: doctorID)
                    NotificationCenter.default.post(name: NSNotification.Name("DoctorsUpdated"), object: nil)
                    completion(nil)
                }
            }
        }
    
    // Get all hospitals
    func getHospitals() -> [Hospital] {
        return Array(hospitals.values)
    }
    
    // Get all doctors
    func getDoctors() -> [Doctor] {
        return Array(doctors.values)
    }
    
    // Remove a hospital from Firebase
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
    
    // Remove a doctor from Firebase (to be implemented)
    func removeDoctor(){
        
    }
}

extension Doctor {
    // Convert Doctor object to dictionary for Firebase
    func toDictionary() -> [String: Any] {
        return [
            "id": id ?? UUID().uuidString,
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "phone": phone,
            "starts": starts.timeIntervalSince1970,
            "ends": ends.timeIntervalSince1970,
            "dob": dob.timeIntervalSince1970,
            "designation": designation.rawValue,
            "titles": titles
        ]
    }
    
    // Initialize Doctor object from dictionary
    init?(from dictionary: [String: Any], id: String) {
        guard let firstName = dictionary["firstName"] as? String,
              let lastName = dictionary["lastName"] as? String,
              let email = dictionary["email"] as? String,
              let phone = dictionary["phone"] as? String,
              let starts = dictionary["starts"] as? TimeInterval,
              let ends = dictionary["ends"] as? TimeInterval,
              let dob = dictionary["dob"] as? TimeInterval,
              let designationRaw = dictionary["designation"] as? String,
              let designation = DoctorDesignation(rawValue: designationRaw),
              let titles = dictionary["titles"] as? String else {
            return nil
        }
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.starts = Date(timeIntervalSince1970: starts)
        self.ends = Date(timeIntervalSince1970: ends)
        self.dob = Date(timeIntervalSince1970: dob)
        self.designation = designation
        self.titles = titles
        self.id = id
    }
}
