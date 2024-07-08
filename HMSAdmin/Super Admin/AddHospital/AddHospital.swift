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
    
    @State private var isNameValid = false
    @State private var isAddressValid = false
    @State private var isPhoneValid = false
    @State private var isEmailValid = false
    @State private var isCityValid = false
    @State private var isCountryValid = false
    @State private var isZipCodeValid = false
    
    @State private var nameError = ""
    @State private var addressError = ""
    @State private var emailError = ""
    @State private var cityError = ""
    @State private var countryError = ""
    
    @State private var recipientEmail: String = ""
    @State private var showMailError = false
    @State private var showingMailView = false
    @State private var newAdminEmail: String = ""
    @State private var newPassword: String = ""
    
    // Admin types and existing admins for selection
    let adminTypes = ["Select", "New", "Existing"]
    let existingAdmins = ["Select", "Ansh", "Madhav", "John", "Jane", "Michael", "Emily", "David", "Sarah", "Robert"]
    
    // Check if all fields are valid to enable Save button
    var isSaveDisabled: Bool {
        return !isNameValid || !isAddressValid || !isPhoneValid || !isEmailValid || !isCityValid || !isCountryValid || !isZipCodeValid
    }
    
    var body: some View {
        Form {
            // Section for hospital details
            Section(header: Text("Hospital Details")) {
                TextField("Name", text: $name)
                    .keyboardType(.default)
                    .autocapitalization(.words)
                    .onChange(of: name) { newValue in
                        validateName(newValue)
                    }
                if !nameError.isEmpty {
                    Text(nameError).foregroundColor(.red)
                }
                
                TextField("Address", text: $address)
                    .keyboardType(.default)
                    .autocapitalization(.words)
                    .onChange(of: address) { newValue in
                        validateAddress(newValue)
                    }
                if !addressError.isEmpty {
                    Text(addressError).foregroundColor(.red)
                }
                
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                    .autocapitalization(.none)
                    .onChange(of: phone) { newValue in
                        if newValue.count <= 10 {
                            phone = newValue
                        }
                        validatePhone(newValue)
                    }
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .onChange(of: email) { newValue in
                        validateEmail(newValue)
                    }
                if !emailError.isEmpty {
                    Text(emailError).foregroundColor(.red)
                }
            }
            
            // Section for location details
            Section() {
                TextField("City", text: $city)
                    .keyboardType(.default)
                    .autocapitalization(.words)
                    .onChange(of: city) { newValue in
                        validateCity(newValue)
                    }
                if !cityError.isEmpty {
                    Text(cityError).foregroundColor(.red)
                }
                
                TextField("Country", text: $country)
                    .keyboardType(.default)
                    .autocapitalization(.words)
                    .onChange(of: country) { newValue in
                        validateCountry(newValue)
                    }
                if !countryError.isEmpty {
                    Text(countryError).foregroundColor(.red)
                }
                
                TextField("Zip Code", text: $zipCode)
                    .keyboardType(.numbersAndPunctuation)
                    .autocapitalization(.none)
                    .onChange(of: zipCode) { newValue in
                        if newValue.count <= 6 {
                            zipCode = newValue
                        }
                        validateZipCode(newValue)
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
                        TextField("Name", text: .constant(""))
                            .keyboardType(.default)
                            .autocapitalization(.words)
                        TextField("Email", text: $recipientEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        TextField("Phone Number", text: .constant(""))
                            .keyboardType(.phonePad)
                            .autocapitalization(.none)
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
            MailView(recipient: recipientEmail, subject: "Admin Credentials for New Hospital", body: mailBody(), completion: { result in
                if result == .sent {
                    saveHospitalData()
                } else {
                    showMailError = true
                }
            })
        }
        .navigationTitle("New Hospital")
    }
    
    // Function to save hospital details
    func saveHospital() {
        if selectedTypeIndex == 1 {
            newAdminEmail = "\(UUID().uuidString.prefix(6))@admin.com"
            newPassword = generateRandomPassword(length: 6)
            showingMailView = true
        } else {
            saveHospitalData()
        }
    }
    
    // Function to save hospital data
    func saveHospitalData() {
        var admins: [Admin] = []
        
        if selectedTypeIndex == 1 {
            let newAdmin = Admin(name: "New Admin", address: "Admin Address", email: newAdminEmail, phone: "1234567890")
            admins.append(newAdmin)
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
    
    // Validation functions
    func validateName(_ value: String) {
        if value.isEmpty {
            isNameValid = false
            nameError = "Name cannot be empty"
        } else if value.count > 25 {
            isNameValid = false
            nameError = "Name cannot exceed 25 characters"
        } else {
            isNameValid = true
            nameError = ""
        }
    }
    
    func validateAddress(_ value: String) {
        if value.isEmpty {
            isAddressValid = false
            addressError = "Address cannot be empty"
        } else {
            isAddressValid = true
            addressError = ""
        }
    }
    
    func validatePhone(_ value: String) {
        if value.count > 10 || Int(value) == nil {
            isPhoneValid = false
        } else {
            isPhoneValid = true
        }
    }
    
    func validateEmail(_ value: String) {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailPred.evaluate(with: value) {
            isEmailValid = false
            emailError = "Invalid email format"
        } else {
            isEmailValid = true
            emailError = ""
        }
    }
    
    func validateCity(_ value: String) {
        if value.isEmpty {
            isCityValid = false
            cityError = "City cannot be empty"
        } else {
            isCityValid = true
            cityError = ""
        }
    }
    
    func validateCountry(_ value: String) {
        if value.isEmpty {
            isCountryValid = false
            countryError = "Country cannot be empty"
        } else {
            isCountryValid = true
            countryError = ""
        }
    }
    
    func validateZipCode(_ value: String) {
        if value.count > 6 {
            isZipCodeValid = false
        } else {
            isZipCodeValid = true
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
}

#Preview {
    // Provide a sample data binding for preview
    AddHospital(hospitals: .constant([Hospital(name: "Sample Hospital", email: "sample@hospital.com", phone: "1234567890", admins: [], address: "123 Sample Street", city: "Sample City", country: "Sample Country", zipCode: "123456", type: "New")]))
}
