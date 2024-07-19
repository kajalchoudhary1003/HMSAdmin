import Foundation
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

class DataController: ObservableObject {
    
    // Singleton instance of DataController
    static let shared = DataController()
    
    private var database: DatabaseReference
    private var hospitals: [String: Hospital] = [:]
    private var doctors: [String: Doctor] = [:]
    @Published var patients: [String: Patient] = [:]
    @Published var appointments: [Appointment] = []
    @Published var staffs: [String: Staff] = [:]
    
    private init() {
        // Initialize the Firebase database reference
        self.database = Database.database(url: "https://hms-hospital-management-system-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
        fetchHospitals()
        fetchDoctors()
        fetchPatients()
        fetchAppointments()
        fetchStaffs()
    }
    
    // Fetch hospitals data from Firebase
    func fetchHospitals() {
        let ref = database.child("hospitals")
        ref.observe(.value) { snapshot in
            self.hospitals = [:]
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let hospitalData = childSnapshot.value as? [String: Any],
                   let hospital = Hospital(from: hospitalData, id: childSnapshot.key) {
                    self.hospitals[hospital.id ?? UUID().uuidString] = hospital
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name("HospitalsUpdated"), object: nil)
        }
    }
    
    // Fetch patients data from Firebase
    func fetchPatients() {
        let ref = database.child("patient_users")
        ref.observe(.value) { snapshot in
            self.patients = [:]
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let patientData = childSnapshot.value as? [String: Any],
                   let patient = Patient(from: patientData, id: childSnapshot.key) {
                    self.patients[patient.id ?? UUID().uuidString] = patient
                    print("Added patient with ID: \(patient.id ?? "unknown")")
                } else {
                    print("Failed to parse patient data from snapshot.")
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name("PatientsUpdated"), object: nil)
        }
    }
    
    // Fetch doctors data from Firebase
    func fetchDoctors() {
        let ref = database.child("doctors")
        ref.observe(.value) { snapshot in
            self.doctors = [:]
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let doctorData = childSnapshot.value as? [String: Any],
                   let doctor = Doctor(from: doctorData, id: childSnapshot.key) {
                    self.doctors[doctor.id ?? UUID().uuidString] = doctor
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name("DoctorsUpdated"), object: nil)
        }
    }
    
    
    //fetch staff details
    func fetchStaffs() {
        let ref = database.child("staffs")
        ref.observe(.value) { snapshot in
            self.staffs = [:]
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let staffData = childSnapshot.value as? [String: Any],
                   let staff = Staff(from: staffData, id: childSnapshot.key) {
                    self.staffs[staff.id ?? UUID().uuidString] = staff
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name("StaffsUpdated"), object: nil)
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
    
    //add staff
    func addStaff(_ staff: Staff, completion: @escaping (Error?) -> Void) {
        let id = staff.id ?? database.child("staffs").childByAutoId().key ?? UUID().uuidString
        var staffWithID = staff
        staffWithID.id = id
        
        let ref = database.child("staffs").child(id)
        ref.setValue(staffWithID.toDictionary()) { error, _ in
            if let error = error {
                completion(error)
                return
            }
            self.staffs[id] = staffWithID
            NotificationCenter.default.post(name: NSNotification.Name("StaffsUpdated"), object: nil)
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
    
    // Delete a doctor from Firebase
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
    
    
    func addPrescription(_ prescription: String, forAppointment appointment: Appointment, completion: @escaping(Error?)-> Void){
        let appointmentID = appointment.id
        let ref = database.child("appointments").child(appointmentID).child("prescription")
        ref.setValue(prescription){
            error, _ in
            if let error = error {
                completion(error)
            } else {
                self.fetchAppointments()
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
    
    func geocodeAddress(address: String, city: String, country: String, zipCode: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        let fullAddress = "\(address), \(city), \(country), \(zipCode)"
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(fullAddress) { placemarks, error in
            if let error = error {
                completion(.failure(error))
            } else if let coordinate = placemarks?.first?.location?.coordinate {
                completion(.success(coordinate))
            } else {
                completion(.failure(NSError(domain: "GeocodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get coordinates"])))
            }
        }
    }
    
    func fetchAppointments() {
        database.child("appointments").observe(.value) { snapshot in
            var newAppointments: [Appointment] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let appointmentData = childSnapshot.value as? [String: Any],
                   let appointment = Appointment(from: appointmentData, id: childSnapshot.key) {
                    newAppointments.append(appointment)
                }
            }
            DispatchQueue.main.async {
                self.appointments = newAppointments
            }
        }
    }
    
    func fetchAppointmentsById(for doctorID: String) {
        database.child("appointments").queryOrdered(byChild: "doctorID").queryEqual(toValue: doctorID).observe(.value) { snapshot in
            var newAppointments: [Appointment] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let appointmentData = childSnapshot.value as? [String: Any],
                   let appointment = Appointment(from: appointmentData, id: childSnapshot.key) {
                    newAppointments.append(appointment)
                }
            }
            DispatchQueue.main.async {
                print("Fetched \(newAppointments.count) appointments")
                self.appointments = newAppointments
            }
        }
    }
}



extension Doctor {
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


extension Staff {
    func toDictionary() -> [String: Any] {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "dateOfBirth": ISO8601DateFormatter().string(from: dateOfBirth),
            "phoneNumber": phoneNumber,
            "email": email,
            "position": position,
            "department": department,
            "employmentStatus": employmentStatus
        ]
    }

    init?(from dictionary: [String: Any], id: String) {
        guard let firstName = dictionary["firstName"] as? String,
              let lastName = dictionary["lastName"] as? String,
              let dateOfBirthString = dictionary["dateOfBirth"] as? String,
              let dateOfBirth = ISO8601DateFormatter().date(from: dateOfBirthString),
              let phoneNumber = dictionary["phoneNumber"] as? String,
              let email = dictionary["email"] as? String,
              let position = dictionary["position"] as? String,
              let department = dictionary["department"] as? String,
              let employmentStatus = dictionary["employmentStatus"] as? String else {
            return nil
        }
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.phoneNumber = phoneNumber
        self.email = email
        self.position = position
        self.department = department
        self.employmentStatus = employmentStatus
    }
}
