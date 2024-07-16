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
    @State private var showSignupError = false
    @State private var signupErrorMessage = ""
    @State private var showMailError = false
    @State private var showingMailView = false
    @State private var newDoctorEmail: String = ""
    @State private var newPassword: String = ""
    @State private var isEditing = true
    
    var designations = DoctorDesignation.allCases
    
    // Computed property to get the minimum end time (1 hour after start time)
    var minimumEndTime: Date {
        return Calendar.current.date(byAdding: .hour, value: 1, to: starts) ?? starts
    }

    // Form validation check
    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phone.isEmpty && !titles.isEmpty &&
        firstName.count <= 25 && lastName.count <= 25 && isValidEmail(email) && isValidPhone(phone) &&
        dob <= Calendar.current.date(byAdding: .year, value: -20, to: Date())! && ends >= minimumEndTime
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
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Personal information section
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                        .disabled(!isEditing)
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
                        .disabled(!isEditing)
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
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disabled(!isEditing)
                        .onChange(of: email) { newValue in
                            if !isValidEmail(newValue) {
                                showSignupError = true
                                signupErrorMessage = "Invalid email format."
                            } else {
                                showSignupError = false
                                signupErrorMessage = ""
                            }
                        }
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.numberPad)
                        .disabled(!isEditing)
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
                        .disabled(!isEditing)
                }

                // Professional information section
                Section(header: Text("Professional Information")) {
                    Picker("Designation", selection: $designation) {
                        ForEach(designations, id: \.self) {
                            Text($0.title)
                        }
                    }
                    .disabled(!isEditing)
                    DatePicker("Starts", selection: $starts, displayedComponents: .hourAndMinute)
                        .disabled(!isEditing)
                        .onChange(of: starts) { newValue in
                            if ends < minimumEndTime {
                                ends = minimumEndTime
                            }
                        }
                    DatePicker("Ends", selection: $ends, in: minimumEndTime..., displayedComponents: .hourAndMinute)
                        .disabled(!isEditing)
                        .onChange(of: ends) { newValue in
                            if ends < minimumEndTime {
                                ends = minimumEndTime
                                signupErrorMessage = "End time should be at least 1 hour after start time."
                                showSignupError = true
                            }
                        }
                    TextField("Qualifications", text: $titles)
                        .disabled(!isEditing)
                }
                if doctorToEdit != nil && isEditing {
                    Section {
                        Button(action: {
                            deleteDoctor(doctorToEdit!)
                        }) {
                            Text("Delete Doctor")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle(doctorToEdit == nil ? "Add Doctor" : "Edit Doctor")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresent = false
                },
                trailing: Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        if isFormValid {
                            saveDoctor()
                        } else {
                            showSignupError = true
                            signupErrorMessage = "Please fill all fields correctly."
                        }
                    } else {
                        isEditing.toggle()
                    }
                }
                .disabled(isEditing && !isFormValid)
            )
            .alert(isPresented: $showSignupError) {
                Alert(title: Text("Error"), message: Text(signupErrorMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showingMailView) {
                MailView(recipient: email, subject: "Doctor Credentials", body: mailBody(), completion: { result in
                    if result == .sent {
                        isPresent = false
                    } else {
                        showMailError = true
                    }
                    showingMailView = false
                })
            }
            .alert(isPresented: $showMailError) {
                Alert(title: Text("Email Error"), message: Text("Failed to send email with credentials. Please contact the doctor manually."), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func saveDoctor() {
        newDoctorEmail = "\(UUID().uuidString.prefix(6))@doctor.com"
        newPassword = generateRandomPassword(length: 6)
        
        performFirebaseSignup()
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
    
    // Email validation function
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
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
                showSignupError = true
                signupErrorMessage = error.localizedDescription
            } else if let authResult = authResult {
                let newDoctor = Doctor(
                    id: authResult.user.uid,
                    firstName: firstName,
                    lastName: lastName,
                    email: newDoctorEmail,
                    phone: phone,
                    starts: starts,
                    ends: ends,
                    dob: dob,
                    designation: designation,
                    titles: titles
                )
                addNewDoctorToDatabase(newDoctor)
            }
        }
    }
    
    private func addNewDoctorToDatabase(_ doctor: Doctor) {
        DataController.shared.addDoctor(doctor) { error in
            if let error = error {
                print("Error saving doctor to database: \(error.localizedDescription)")
                showSignupError = true
                signupErrorMessage = "Failed to save doctor details. Please try again."
            } else {
                sendWelcomeEmail(to: doctor)
            }
        }
    }
    
    private func sendWelcomeEmail(to doctor: Doctor) {
        showingMailView = true
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
