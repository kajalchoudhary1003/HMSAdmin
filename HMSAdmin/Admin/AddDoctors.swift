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
    @State private var startTimeIndex = 0
    @State private var endTimeIndex = 1
    
    var designations = DoctorDesignation.allCases
    
    // Time slots array with AM and PM
    let timeSlots = (6...11).map { "\($0):00 AM" } + ["12:00 PM"] + (1...11).map { "\($0):00 PM" }
    
    // Computed property to get the minimum end time index
    var minimumEndTimeIndex: Int {
        return startTimeIndex + 1
    }
    
    // Computed property to get the maximum end time index (5 hours after start time)
    var maximumEndTimeIndex: Int {
        return min(startTimeIndex + 5, timeSlots.count - 1)
    }
    
    // Form validation check
    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phone.isEmpty && !titles.isEmpty &&
        firstName.count <= 25 && lastName.count <= 25 && isValidEmail(email) && isValidPhone(phone) &&
        dob <= Calendar.current.date(byAdding: .year, value: -20, to: Date())! && endTimeIndex >= minimumEndTimeIndex &&
        endTimeIndex <= maximumEndTimeIndex
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
            _dob = State(initialValue: doctor.dob)
            _designation = State(initialValue: doctor.designation)
            _titles = State(initialValue: doctor.titles)
            
            // Setting initial indices based on the doctor's existing start and end times
            if let startHour = Calendar.current.dateComponents([.hour], from: doctor.starts).hour,
               let endHour = Calendar.current.dateComponents([.hour], from: doctor.ends).hour {
                let startPeriod = startHour >= 12 ? "PM" : "AM"
                let endPeriod = endHour >= 12 ? "PM" : "AM"
                let startHour12 = startHour % 12 == 0 ? 12 : startHour % 12
                let endHour12 = endHour % 12 == 0 ? 12 : endHour % 12
                _startTimeIndex = State(initialValue: timeSlots.firstIndex(of: "\(startHour12):00 \(startPeriod)") ?? 0)
                _endTimeIndex = State(initialValue: timeSlots.firstIndex(of: "\(endHour12):00 \(endPeriod)") ?? 1)
            }
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
                    Picker("Start Time", selection: $startTimeIndex) {
                        ForEach(0..<timeSlots.count) { index in
                            Text(timeSlots[index])
                        }
                    }
                    .disabled(!isEditing)
                    .onChange(of: startTimeIndex) { newValue in
                        if endTimeIndex < minimumEndTimeIndex {
                            endTimeIndex = minimumEndTimeIndex
                        } else if endTimeIndex > maximumEndTimeIndex {
                            endTimeIndex = maximumEndTimeIndex
                            signupErrorMessage = "Shift cannot exceed 5 hours."
                            showSignupError = true
                        }
                    }
                    Picker("End Time", selection: $endTimeIndex) {
                        ForEach(minimumEndTimeIndex..<timeSlots.count) { index in
                            Text(timeSlots[index])
                        }
                    }
                    .disabled(!isEditing)
                    .onChange(of: endTimeIndex) { newValue in
                        if endTimeIndex < minimumEndTimeIndex {
                            endTimeIndex = minimumEndTimeIndex
                            signupErrorMessage = "End time should be at least 1 hour after start time."
                            showSignupError = true
                        } else if endTimeIndex > maximumEndTimeIndex {
                            endTimeIndex = maximumEndTimeIndex
                            signupErrorMessage = "Shift cannot exceed 5 hours."
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
            .background(Color.customBackground)
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
                Alert(title: Text("Email Error"), message: Text("Failed to send email"), dismissButton: .default(Text("OK")))
            }
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        // Add your email validation logic here
        return email.contains("@") && email.contains(".")
    }
    
    func isValidPhone(_ phone: String) -> Bool {
        // Add your phone validation logic here
        return phone.count == 10
    }
    
    func saveDoctor() {
        // Add your logic to save the doctor details here
    }
    
    func deleteDoctor(_ doctor: Doctor) {
        // Add your logic to delete the doctor here
    }
    
    func mailBody() -> String {
        return """
        Dear \(firstName),

        Your account has been created with the following credentials:
        Email: \(newDoctorEmail)
        Password: \(newPassword)

        Best regards,
        Admin Team
        """
    }
}

struct DoctorFormView_Previews: PreviewProvider {
    @State static var isPresent = true
    @State static var doctors: [Doctor] = []
    
    static var previews: some View {
        DoctorFormView(isPresent: $isPresent, doctors: $doctors, doctorToEdit: nil)
    }
}
