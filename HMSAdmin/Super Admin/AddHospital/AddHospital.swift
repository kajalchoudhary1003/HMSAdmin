import SwiftUI
import MapKit
import FirebaseAuth

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
    @State private var selectedAdminName = "Select Admin"
    @State private var locationCoordinate = CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629) // Coordinates for India
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))

    @State private var showMailError = false
    @State private var showingMailView = false
    @State private var newAdminEmail: String = ""
    @State private var newPassword: String = ""

    @State private var newAdminName: String = ""
    @State private var newAdminPhone: String = ""
    
    // Admin types and existing admins for selection
    let adminTypes = ["Select", "New", "Existing"]
    @State private var existingAdmins = ["Select", "Michael", "Emily", "David", "Robert"]

    var isSaveDisabled: Bool {
        selectedTypeIndex == 0 ||
        !isFormValid ||
        (selectedTypeIndex == 1 && (!isNewAdminNameValid || !isNewAdminEmailValid || !isNewAdminPhoneValid)) ||
        (selectedTypeIndex == 2 && selectedAdminIndex == 0)
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
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
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
 
                TextField("Phone", text: $phone)
                    .keyboardType(.numberPad)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                        phone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
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
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
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
                
            }
            
            Section(){
                TextField("Address", text: $address, onCommit: geocodeAddress)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                        address = address.trimmingCharacters(in: .whitespacesAndNewlines)
                        geocodeAddress()
                    }
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
                
                TextField("City", text: $city)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                        city = city.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                TextField("Country", text: $country)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                        country = country.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                TextField("Zip Code", text: $zipCode)
                    .keyboardType(.numberPad)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                        zipCode = zipCode.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
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
            
            
            MapView(locationCoordinate: $locationCoordinate, region: $region)
                .frame(height: 300)
            
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
                            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                                newAdminName = newAdminName.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
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
                            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                                newAdminEmail = newAdminEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
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
                            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                                newAdminPhone = newAdminPhone.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
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
                    } else if selectedTypeIndex == 2 {
                        NavigationLink(destination: AdminPickerView(existingAdmins: $existingAdmins, selectedAdminIndex: $selectedAdminIndex)) {
                            Text(selectedAdminIndex == 0 ? "Select Admin" : existingAdmins[selectedAdminIndex])
                        }
                    }
                }
            }
        }
        .navigationTitle("New Hospital")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { saveHospital() }) {
                    Image(systemName: "plus")
                }
            }
        }
        .alert(isPresented: $showMailError) {
            Alert(title: Text("Error"), message: Text("Unable to send email."), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showingMailView) {
            MailView(recipient: newAdminEmail, subject: "Admin Credentials for New Hospital", body: mailBody(), completion: { result in
                if result == .sent {
                    performFirebaseSignup()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }
    
    // Function to save hospital details
    func saveHospital() {
        var admins: [Admin] = []
        if selectedTypeIndex == 1 {
            newAdminEmail = newAdminEmail.trimmingCharacters(in: .whitespacesAndNewlines)
            newPassword = generateRandomPassword(length: 8)
            let newAdmin = Admin(name: newAdminName, address: "Admin Address", email: newAdminEmail, phone: newAdminPhone)
            admins.append(newAdmin)
            
            // Add new admin to existing admins list
            existingAdmins.append(newAdminName)

            showingMailView = true
        } else if selectedTypeIndex == 2 && selectedAdminIndex > 0 {
            let selectedAdminName = existingAdmins[selectedAdminIndex]
            let existingAdmin = Admin(name: selectedAdminName, address: "Admin Address", email: "admin@example.com", phone: "1234567890")
            admins.append(existingAdmin)
        }

        let newHospital = Hospital(name: name, email: email, phone: phone, admins: admins, address: address, city: city, country: country, zipCode: zipCode, type: adminTypes[selectedTypeIndex], latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)

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
        Dear \(newAdminName),

        I hope this message finds you well. We are pleased to inform you that you have been appointed as an admin for our new hospital. Below, you will find your login credentials for accessing the admin portal:

        Email: \(newAdminEmail)
        Password: \(newPassword)

        Hospital Details: \(name), \(address), \(city), \(zipCode), \(country).
        Phone: \(phone)
        Email: \(email)

        Please use these credentials to log into the admin portal at your earliest convenience. If you encounter any issues or have any questions, feel free to reach out to our support team.

        We look forward to working with you and are confident that your contributions will greatly benefit our hospital.

        Best regards,

        \(name)
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

    func geocodeAddress() {
        DataController.shared.geocodeAddress(address: address, city: city, country: country, zipCode: zipCode) { result in
            switch result {
            case .success(let coordinate):
                locationCoordinate = coordinate
                region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            case .failure(let error):
                print("Geocoding error: \(error.localizedDescription)")
            }
        }
    }
}

struct AddHospital_Previews: PreviewProvider {
    static var previews: some View {
        AddHospital(hospitals: .constant([]))
    }
}
