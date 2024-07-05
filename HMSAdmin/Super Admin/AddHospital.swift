import SwiftUI
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
    
    @State private var recipentEmail: String = ""
    
    let adminTypes = ["Select", "New", "Existing"]
    let existingAdmins = ["Select", "Ansh", "Madhav", "John", "Jane", "Michael", "Emily", "David", "Sarah", "Robert"]
    
    var isSaveDisabled: Bool {
        return !isNameValid || !isAddressValid || !isPhoneValid || !isEmailValid || !isCityValid || !isCountryValid || !isZipCodeValid
           }
    
    var body: some View {
        Form {
            Section(header: Text("Hospital Details")) {
                TextField("Name", text: $name)
                    .onChange(of: name) { newValue in
                        isNameValid = !newValue.isEmpty
                    }
                TextField("Address", text: $address)
                    .onChange(of: address) { newValue in
                        isAddressValid = !newValue.isEmpty
                    }
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                    .onChange(of: phone) { newValue in
                        isPhoneValid = !newValue.isEmpty
                    }
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .onChange(of: email) { newValue in
                        isEmailValid = !newValue.isEmpty
                    }
                
            }
            
            Section(){
                TextField("City", text: $city)
                    .onChange(of: city) { newValue in
                        isCityValid = !newValue.isEmpty
                    }
                TextField("Country", text: $country)
                    .onChange(of: country) { newValue in
                        isCountryValid = !newValue.isEmpty
                    }
                TextField("Zip Code", text: $zipCode)
                    .onChange(of: zipCode) { newValue in
                        isZipCodeValid = !newValue.isEmpty
                    }
            }
            
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
                                        TextField("Email", text: $recipentEmail)
                                        TextField("Phone Number", text: .constant(""))
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {saveHospital()}) {
                    Text("Save")
                }
                .disabled(isSaveDisabled)
            }
        }
        .navigationTitle("New Hospital")
    }
    
    func saveHospital() {
            var admins: [Admin] = []
            if selectedTypeIndex == 1 {
                
                let newAdminEmail = "\(UUID().uuidString.prefix(6))@admin.com"
                           let newPassword = generateRandomPassword(length: 6)
                // Handle new admin creation
                let newAdmin = Admin(name: "New Admin", address: "Admin Address", email: "admin@example.com", phone: "1234567890")
                admins.append(newAdmin)
                
                // Send email with admin credentials
                            sendCustomMail(to: recipentEmail, newAdminEmail: newAdminEmail, newPassword: newPassword)
            } else if selectedTypeIndex == 2 && selectedAdminIndex > 0 {
                // Handle existing admin selection
                let selectedAdminName = existingAdmins[selectedAdminIndex]
                let existingAdmin = Admin(name: selectedAdminName, address: "Admin Address", email: "admin@example.com", phone: "1234567890")
                admins.append(existingAdmin)
            }
            
            let newHospital = Hospital(name: name, email: email, phone: phone, admins: admins, address: address, city: city, country: country, zipCode: zipCode, type: adminTypes[selectedTypeIndex])
            
            hospitals.append(newHospital) // Assuming hospitals is correctly bound and updated
        
        
            
            DataController.shared.addHospital(newHospital) { error in
                if let error = error {
                    print("Failed to save hospital: \(error.localizedDescription)")
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    
    func sendCustomMail(to recipient: String, newAdminEmail: String? = nil, newPassword: String? = nil){
        guard MFMailComposeViewController.canSendMail() else {
                   // Handle inability to send mail
                   return
               }
               
               let mail = MFMailComposeViewController()
               mail.setToRecipients([recipient])
               mail.setSubject("Admin Credentials for New Hospital")
               
               // Generate and include the admin credentials in the email body
               if let newAdminEmail = newAdminEmail, let newPassword = newPassword {
                   let messageBody = """
                   Hello,
                   
                   Here are the login credentials for the new admin:
                   Email: \(newAdminEmail)
                   Password: \(newPassword)
                   
                   Please use these credentials to access the admin portal.
                   
                   Regards,
                   Your Hospital Team
                   """
                   
                   mail.setMessageBody(messageBody, isHTML: false)
               } else {
                   // Handle other cases if needed
                   mail.setMessageBody("Hello,\n\nAdmin credentials for the existing admin.\n\nRegards,\nYour Hospital Team", isHTML: false)
               }
               
               // Present the view controller modally
               UIApplication.shared.windows.first?.rootViewController?.present(mail, animated: true)
           
    }
    
    func generateRandomPassword(length: Int) -> String {
            let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<length).map{ _ in characters.randomElement()! })
        }
}
