import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import MessageUI

struct AddHospital: View {
    @Binding var hospitals: [Hospital]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var address: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var zipCode: String = ""
    @State private var country: String = ""
    @State private var city: String = ""
    @State private var selectedTypeIndex = 0
    @State private var selectedAdminIndex = 0
    
    @State private var showMailError = false
    @State private var showingMailView = false
    @State private var newAdminEmail: String = ""
    @State private var newPassword: String = ""
    
    @State private var newAdminName: String = ""
    @State private var newAdminPhone: String = ""
    
    // Admin types and existing admins for selection
    let adminTypes = ["Select", "New", "Existing"]
    let existingAdmins = ["Select", "Ansh", "Madhav", "John", "Jane", "Michael", "Emily", "David", "Sarah", "Robert"]
    
    // Check if all fields are valid to enable Save button
    var isSaveDisabled: Bool {
        !isFormValid || (selectedTypeIndex == 1 && (!isNewAdminNameValid || !isNewAdminEmailValid || !isNewAdminPhoneValid))
    }
    
    var isFormValid: Bool {
        !name.isEmpty && !address.isEmpty && !email.isEmpty && !phone.isEmpty && !city.isEmpty && !country.isEmpty && !zipCode.isEmpty &&
        name.count <= 25 && address.count <= 100 && isValidEmail(email) && isValidPhone(phone) && isValidZipCode(zipCode)
    }
    
    var isNewAdminNameValid: Bool {
        !newAdminName.isEmpty && newAdminName.count <= 25
    }
    
    var isNewAdminEmailValid: Bool {
        isValidEmail(newAdminEmail)
    }
    
    var isNewAdminPhoneValid: Bool {
        isValidPhone(newAdminPhone)
    }
    
    var body: some View {
        Form {
            // Section for hospital details
            Section(header: Text("Hospital Details")) {
                TextField("Name", text: $name)
                    .onChange(of: name) { newValue in
                        if newValue.count > 25 {
                            name = String(newValue.prefix(25))
                        }
                    }
                    .overlay(
                        Text("\(name.count)/25")
                            .font(.caption)
                            .foregroundColor(name.count > 25 ? .red : .gray)
                            .padding(.trailing, 8),
                        alignment: .trailing
                    )
                TextField("Address", text: $address)
                    .onChange(of: address) { newValue in
                        if newValue.count > 100 {
                            address = String(newValue.prefix(100))
                        }
                    }
                    .overlay(
                        Text("\(address.count)/100")
                            .font(.caption)
                            .foregroundColor(address.count > 100 ? .red : .gray)
                            .padding(.trailing, 8),
                        alignment: .trailing
                    )
                TextField("Phone", text: $phone)
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
                if !isValidPhone(phone) && !phone.isEmpty {
                    Text("Phone number should be 10 digits")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                    .onChange(of: email) { newValue in
                        if newValue.count > 100 {
                            email = String(newValue.prefix(100))
                        }
                    }
                if !isValidEmail(email) && !email.isEmpty {
                    Text("Invalid email format")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                TextField("City", text: $city)
                TextField("Country", text: $country)
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
                if !isValidZipCode(zipCode) && !zipCode.isEmpty {
                    Text("Zip Code should be 6 digits")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            // Section for admin details
            Section(header: Text("Admin Details")) {
                Picker(selection: $selectedTypeIndex, label: Text("Type")) {
                    ForEach(0 ..< adminTypes.count) { index in
                        Text(self.adminTypes[index])
                    }
                }
                .pickerStyle(.menu)
                
                if selectedTypeIndex > 0 {
                    if adminTypes[selectedTypeIndex] == "New" {
                        TextField("Name", text: $newAdminName)
                            .onChange(of: newAdminName) { newValue in
                                if newValue.count > 25 {
                                    newAdminName = String(newValue.prefix(25))
                                }
                            }
                            .overlay(
                                Text("\(newAdminName.count)/25")
                                    .font(.caption)
                                    .foregroundColor(newAdminName.count > 25 ? .red : .gray)
                                    .padding(.trailing, 8),
                                alignment: .trailing
                            )
                        if !isNewAdminNameValid && !newAdminName.isEmpty {
                            Text("Name should not exceed 25 characters")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        TextField("Email", text: $newAdminEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)
                            .onChange(of: newAdminEmail) { newValue in
                                if newValue.count > 100 {
                                    newAdminEmail = String(newValue.prefix(100))
                                }
                            }
                        if !isNewAdminEmailValid && !newAdminEmail.isEmpty {
                            Text("Invalid email format")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        TextField("Phone Number", text: $newAdminPhone)
                            .keyboardType(.numberPad)
                            .onChange(of: newAdminPhone) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if newAdminPhone != filtered {
                                    newAdminPhone = filtered
                                }
                                if newAdminPhone.count > 10 {
                                    newAdminPhone = String(newAdminPhone.prefix(10))
                                }
                            }
                            .overlay(
                                Text("\(newAdminPhone.count)/10")
                                    .font(.caption)
                                    .foregroundColor(newAdminPhone.count > 10 ? .red : .gray)
                                    .padding(.trailing, 8),
                                alignment: .trailing
                            )
                        if !isNewAdminPhoneValid && !newAdminPhone.isEmpty {
                            Text("Phone number should be 10 digits")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    } else if adminTypes[selectedTypeIndex] == "Existing" {
                        Picker(selection: $selectedAdminIndex, label: Text("Select")) {
                            ForEach(0 ..< existingAdmins.count) { index in
                                Text(self.existingAdmins[index])
                            }
                        }
                    }
                }
            }
        }
        .toolbar { // Toolbar with Save button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { saveHospital() }) {
                    Text("Save")
                }
                .disabled(isSaveDisabled)
            }
        }
        // Alert for mail error
        .alert(isPresented: $showMailError) {
            Alert(title: Text("Error"), message: Text("Unable to send email."), dismissButton: .default(Text("OK")))
        }
        // Sheet for showing email composer
        .sheet(isPresented: $showingMailView) {
            MailView(recipient: newAdminEmail, subject: "Admin Credentials for New Hospital", body: mailBody(), completion: { result in
                if result == .sent {
                    performFirebaseSignup()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
        .navigationTitle("New Hospital")
    }
    
    // Function to save hospital details
    func saveHospital() {
        var admins: [Admin] = []
        if selectedTypeIndex == 1 {
            newAdminEmail = "\(UUID().uuidString.prefix(6))@admin.com"
            newPassword = generateRandomPassword(length: 6)
            let newAdmin = Admin(name: newAdminName, address: "Admin Address", email: newAdminEmail, phone: newAdminPhone)
            admins.append(newAdmin)
            
            showingMailView = true
        } else if selectedTypeIndex == 2 && selectedAdminIndex > 0 {
            let selectedAdminName = existingAdmins[selectedAdminIndex]
            let existingAdmin = Admin(name: selectedAdminName, address: "Admin Address", email: "admin@example.com", phone: "1234567890")
            admins.append(existingAdmin)
        }
        
        let newHospital = Hospital(name: name, email: email, phone: phone, admins: admins, address: address, city: city, country: country, zipCode: zipCode, type: adminTypes[selectedTypeIndex])
        
        hospitals.append(newHospital)
        
        DataController.shared.addHospital(newHospital) { error in
            if let error = error {
                print("Failed to save hospital: \(error.localizedDescription)")
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    // Function to generate email body
    func mailBody() -> String {
        """
        Hello,

        Here are the login credentials for the new admin:
        
        Email: \(newAdminEmail)
        Password: \(newPassword)
        
        Hospital Details:
        Name: \(name)
        Address: \(address)
        Phone: \(phone)
        Email: \(email)
        City: \(city)
        Country: \(country)
        Zip Code: \(zipCode)
        
        Please use these credentials to access the admin portal.
        
        Regards,
        Your Hospital Team
        """
    }
    
    // Function to generate random password
    func generateRandomPassword(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    // Function to perform Firebase signup for new admin
    func performFirebaseSignup() {
        Auth.auth().createUser(withEmail: newAdminEmail, password: newPassword) { authResult, error in
            if let error = error {
                print("Error signing up: \(error.localizedDescription)")
            } else {
                print("User signed up successfully")
            }
        }
    }
    
    // Validation functions
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func isValidPhone(_ phone: String) -> Bool {
        let phoneRegEx = "^[0-9]{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: phone)
    }
    
    func isValidZipCode(_ zipCode: String) -> Bool {
        let zipCodeRegEx = "^[0-9]{6}$"
        let zipCodeTest = NSPredicate(format: "SELF MATCHES %@", zipCodeRegEx)
        return zipCodeTest.evaluate(with: zipCode)
    }
}

#Preview {
    // Provide a sample data binding for preview
    AddHospital(hospitals: .constant([Hospital(name: "Sample Hospital", email: "sample@hospital.com", phone: "1234567890", admins: [], address: "123 Sample Street", city: "Sample City", country: "Sample Country", zipCode: "123456", type: "New")]))
}
