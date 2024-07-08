import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift
import MessageUI

struct DoctorFormView: View {
    @Binding var isPresented: Bool
    @Binding var doctors: [Doctor]
    var doctorToEdit: Doctor?
    @Environment(\.presentationMode) var presentationMode
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var starts = Date()
    @State private var ends = Date()
    @State private var dob = Date()
    @State private var designation: DoctorDesignation = .generalPractitioner
    @State private var titles = ""
    
    @State private var showMailError = false
        @State private var showingMailView = false
        @State private var newDoctorEmail: String = ""
        @State private var newPassword: String = ""

    var designations = DoctorDesignation.allCases
    
    // Form validation check
    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phone.isEmpty && !titles.isEmpty
    }
    
    // Initializer to set up the form with existing doctor details if editing
    init(isPresented: Binding<Bool>, doctors: Binding<[Doctor]>, doctorToEdit: Doctor?) {
        self._isPresented = isPresented
        self._doctors = doctors
        self.doctorToEdit = doctorToEdit
        
        if let doctor = doctorToEdit {
            _firstName = State(initialValue: doctor.firstName)
            _lastName = State(initialValue: doctor.lastName)
            _email = State(initialValue: doctor.email)
            _phone = State(initialValue: doctor.phone)
            _starts = State(initialValue: doctor.starts)
            _ends = State(initialValue: doctor.ends)
            _dob = State(initialValue: doctor.dob)
            _designation = State(initialValue: doctor.designation)
            _titles = State(initialValue: doctor.titles)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Personal information section
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                    TextField("Phone Number", text: $phone)
                    DatePicker("Date of Birth", selection: $dob, displayedComponents: .date)
                }
                
                // Professional information section
                Section(header: Text("Professional Information")) {
                    Picker("Designation", selection: $designation) {
                        ForEach(designations, id: \.self) {
                            Text($0.title)
                        }
                    }
                    DatePicker("Starts", selection: $starts, displayedComponents: .hourAndMinute)
                    DatePicker("Ends", selection: $ends, displayedComponents: .hourAndMinute)
                    TextField("Titles", text: $titles)
                }
            }
            .navigationTitle(doctorToEdit == nil ? "Add Doctor" : "Edit Doctor") // Title based on add or edit mode
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            }, trailing: Button("Save") {
                saveDoctor()
                isPresented = false
            }
            .disabled(!isFormValid)) // Disable save button if form is not valid
        }
        // Added alert for email error
               .alert(isPresented: $showMailError) {
                   Alert(title: Text("Error"), message: Text("Unable to send email."), dismissButton: .default(Text("OK")))
               }
        
        // Added sheet for showing email composer
                .sheet(isPresented: $showingMailView) {
                    MailView(recipient: email, subject: "Doctor Credentials", body: mailBody(), completion: { result in
                        if result == .sent {
                            performFirebaseSignup()
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    })
                }
    }
    
    private func saveDoctor() {
        //  generate random email and password
               newDoctorEmail = "\(UUID().uuidString.prefix(6))@doctor.com"
               newPassword = generateRandomPassword(length: 6)
        
        let newDoctor = Doctor(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            starts: starts,
            ends: ends,
            dob: dob,
            designation: designation,
            titles: titles
        )
        
        // If editing an existing doctor, update the doctor details
        if let doctorToEdit = doctorToEdit, let index = doctors.firstIndex(where: { $0.id == doctorToEdit.id }) {
            var updatedDoctor = newDoctor
            updatedDoctor.id = doctorToEdit.id
            doctors[index] = updatedDoctor
            DataController.shared.addDoctor(updatedDoctor) { error in
                if let error = error {
                    print("Failed to save doctor: \(error.localizedDescription)")
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } else {
            // If adding a new doctor, append to the doctors list
            DataController.shared.addDoctor(newDoctor) { error in
                if let error = error {
                    print("Failed to save doctor: \(error.localizedDescription)")
                } else {
                    doctors.append(newDoctor)
                    showingMailView = true // to show email composer
                }
            }
        }
    }
    
    //function to compose email body
       private func mailBody() -> String {
           """
           Hello Dr. \(firstName) \(lastName),

           Here are your login credentials:

           Email: \(newDoctorEmail)
           Password: \(newPassword)

           Please use these credentials to access the doctor portal.

           Regards,
           Hospital Administration
           """
       }
    
    // function to generate random password
        private func generateRandomPassword(length: Int) -> String {
            let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<length).map { _ in characters.randomElement()! })
        }
    
    // function to perform Firebase signup
       private func performFirebaseSignup() {
           Auth.auth().createUser(withEmail: newDoctorEmail, password: newPassword) { authResult, error in
               if let error = error {
                   print("Error signing up: \(error.localizedDescription)")
               } else {
                   print("User signed up successfully")
               }
           }
       }
}
#Preview {
    DoctorFormView(isPresented: .constant(true), doctors: .constant([]), doctorToEdit: nil)
}
