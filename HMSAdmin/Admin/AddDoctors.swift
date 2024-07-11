import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift
import MessageUI

struct DoctorFormView: View {
    @Binding var isPresent: Bool
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
    @State private var zipCode = ""
    
    @State private var showMailError = false
    @State private var showingMailView = false
    @State private var newDoctorEmail: String = ""
    @State private var newPassword: String = ""
    @State private var isEditing = false
    
    var designations = DoctorDesignation.allCases
    
    // Form validation check
    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phone.isEmpty && !titles.isEmpty && !zipCode.isEmpty &&
        firstName.count <= 25 && lastName.count <= 25 && isValidEmail(email) && isValidPhone(phone) && isValidZipCode(zipCode) &&
        dob <= Calendar.current.date(byAdding: .year, value: -20, to: Date())!
    }
    
    // Initializer to set up the form with existing doctor details if editing
    init(isPresent: Binding<Bool>, doctors: Binding<[Doctor]>, doctorToEdit: Doctor?) {
        self._isPresent = isPresent
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
            _isEditing = State(initialValue: true)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Personal information section
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                        .onChange(of: firstName) { newValue in
                            if newValue.count > 25 {
                                firstName = String(newValue.prefix(25))
                            }
                        }
                        .overlay(
                            Text("\(firstName.count)/25")
                                .font(.caption)
                                .foregroundColor(firstName.count > 25 ? .red : .gray)
                                .padding(.trailing, 8),
                            alignment: .trailing
                        )
                    TextField("Last Name", text: $lastName)
                        .onChange(of: lastName) { newValue in
                            if newValue.count > 25 {
                                lastName = String(newValue.prefix(25))
                            }
                        }
                        .overlay(
                            Text("\(lastName.count)/25")
                                .font(.caption)
                                .foregroundColor(lastName.count > 25 ? .red : .gray)
                                .padding(.trailing, 8),
                            alignment: .trailing
                        )
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.numberPad)
                        .onChange(of: phone) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if phone != filtered {
                                phone = filtered
                            }
                            if phone.count > 10 {
                                phone = String(phone.prefix(10))
                            }
                        }
                        .overlay(
                            Text("\(phone.count)/10")
                                .font(.caption)
                                .foregroundColor(phone.count > 10 ? .red : .gray)
                                .padding(.trailing, 8),
                            alignment: .trailing
                        )
                    DatePicker("Date of Birth", selection: $dob, in: ...Calendar.current.date(byAdding: .year, value: -20, to: Date())!, displayedComponents: .date)
                    TextField("Zip Code", text: $zipCode)
                        .keyboardType(.numberPad)
                        .onChange(of: zipCode) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if zipCode != filtered {
                                zipCode = filtered
                            }
                            if zipCode.count > 6 {
                                zipCode = String(zipCode.prefix(6))
                            }
                        }
                        .overlay(
                            Text("\(zipCode.count)/6")
                                .font(.caption)
                                .foregroundColor(zipCode.count > 6 ? .red : .gray)
                                .padding(.trailing, 8),
                            alignment: .trailing
                        )
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
                    TextField("Qualifications", text: $titles)
                }
                VStack(alignment: .trailing) {
                    if doctorToEdit != nil {
                        Button(action: {
                            deleteDoctor(doctorToEdit!)
                        }) {
                            Text("Delete Doctor")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle(doctorToEdit == nil ? "Add Doctor" : "Edit Doctor") // Title based on add or edit mode
            .navigationBarItems(leading: Button("Cancel") {
                isPresent = false
            }, trailing: Button("Save") {
                saveDoctor()
            }
                .disabled(doctorToEdit == nil && !isFormValid)) // Disable save button if form is not valid for adding new doctor
            // Added alert for email error
            .alert(isPresented: $showMailError) {
                Alert(title: Text("Error"), message: Text("Unable to send email."), dismissButton: .default(Text("OK")))
            }
            
            // Added sheet for showing email composer
            .sheet(isPresented: $showingMailView) {
                MailView(recipient: email, subject: "Doctor Credentials", body: mailBody(), completion: { result in
                    if result == .sent {
                        performFirebaseSignup()
                    }
                    showingMailView = false
                    isPresent = false
                })
            }
        }
    }
    
    private func saveDoctor() {
        // Generate random email and password
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
        
        if let doctorToEdit = doctorToEdit {
            // If editing an existing doctor, update the doctor details
            if let index = doctors.firstIndex(where: { $0.id == doctorToEdit.id }) {
                doctors[index] = newDoctor
            }
        } else {
            // If adding a new doctor, append to the doctors array
            doctors.append(newDoctor)
        }
        
        showingMailView.toggle()
    }
    
    // Function to delete the doctor
    private func deleteDoctor(_ doctor: Doctor) {
        if let index = doctors.firstIndex(where: { $0.id == doctor.id }) {
            doctors.remove(at: index)
            isPresent = false
        }
    }
    
    // Function to construct email body
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
    
    // Function to generate random password
    private func generateRandomPassword(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    // Function to perform Firebase signup
    private func performFirebaseSignup() {
        Auth.auth().createUser(withEmail: newDoctorEmail, password: newPassword) { authResult, error in
            if let error = error {
                print("Error signing up: \(error.localizedDescription)")
            } else {
                print("User signed up successfully")
            }
        }
    }
    
    // Function to validate email
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    // Function to validate phone number
    private func isValidPhone(_ phone: String) -> Bool {
        let phoneRegEx = "^[0-9]{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: phone)
    }
    
    // Function to validate zip code
    private func isValidZipCode(_ zipCode: String) -> Bool {
        let zipCodeRegEx = "^[0-9]{6}$"
        let zipCodeTest = NSPredicate(format: "SELF MATCHES %@", zipCodeRegEx)
        return zipCodeTest.evaluate(with: zipCode)
    }
}

#Preview {
    DoctorFormView(isPresent: .constant(true), doctors: .constant([]), doctorToEdit: nil)
}
