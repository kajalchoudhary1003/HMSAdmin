import SwiftUI

struct HospitalFormView: View {
    @Binding var hospitals: [Hospital]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var address: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var city: String = ""
    @State private var country: String = ""
    @State private var zipCode: String = ""
    
    @State private var adminName: String = ""
    @State private var adminEmail: String = ""
    @State private var adminPhone: String = ""
    @State private var selectedTypeIndex = 0
    @State private var selectedAdminIndex = 0
    
    @State private var isNameValid = false
    @State private var isAddressValid = false
    @State private var isPhoneValid = false
    @State private var isEmailValid = false
    @State private var isCityValid = false
    @State private var isCountryValid = false
    @State private var isZipCodeValid = false
    @State private var isAdminNameValid = false
    @State private var isAdminEmailValid = false
    @State private var isAdminPhoneValid = false
    
    let adminTypes = ["Select", "New", "Existing"]
    let existingAdmins = ["Select", "Ansh", "Madhav", "John", "Jane", "Michael", "Emily", "David", "Sarah", "Robert"]
    
    var isSaveDisabled: Bool {
        let isAdminDetailsValid = (selectedTypeIndex == 1 && isAdminNameValid && isAdminEmailValid && isAdminPhoneValid) || (selectedTypeIndex == 2 && selectedAdminIndex != 0)
        return selectedTypeIndex == 0 || !isNameValid || !isAddressValid || !isPhoneValid || !isEmailValid || !isCityValid || !isCountryValid || !isZipCodeValid || (selectedTypeIndex != 0 && !isAdminDetailsValid)
    }
    
    // Initialize form fields with selected hospital details if editing
    init(hospitals: Binding<[Hospital]>, hospital: Hospital?) {
        self._hospitals = hospitals
        if let hospital = hospital {
            _name = State(initialValue: hospital.name)
            _address = State(initialValue: hospital.address)
            _phone = State(initialValue: hospital.phone)
            _email = State(initialValue: hospital.email)
            _city = State(initialValue: hospital.city)
            _country = State(initialValue: hospital.country)
            _zipCode = State(initialValue: hospital.zipCode)
            
            if let admin = hospital.admin {
                _adminName = State(initialValue: admin.name)
                _adminEmail = State(initialValue: admin.email)
                _adminPhone = State(initialValue: admin.phone)
                _selectedTypeIndex = State(initialValue: 1) // Assuming existing admin
            } else {
                _selectedTypeIndex = State(initialValue: 0)
            }
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Hospital Details")) {
                TextField("Name", text: $name)
                    .onChange(of: name) { newValue in
                        isNameValid = !newValue.isEmpty
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
                TextField("Address", text: $address)
                    .onChange(of: address) { newValue in
                        isAddressValid = !newValue.isEmpty
                    }
                TextField("City", text: $city)
                    .onChange(of: city) { newValue in
                        isCityValid = !newValue.isEmpty
                    }
                TextField("Country", text: $country)
                    .onChange(of: country) { newValue in
                        isCountryValid = !newValue.isEmpty
                    }
                TextField("Zip Code", text: $zipCode)
                    .keyboardType(.numberPad)
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
                .pickerStyle(MenuPickerStyle())
                
                if selectedTypeIndex == 1 {
                    TextField("Admin Name", text: $adminName)
                        .onChange(of: adminName) { newValue in
                            isAdminNameValid = !newValue.isEmpty
                        }
                    TextField("Admin Email", text: $adminEmail)
                        .keyboardType(.emailAddress)
                        .onChange(of: adminEmail) { newValue in
                            isAdminEmailValid = !newValue.isEmpty
                        }
                    TextField("Admin Phone Number", text: $adminPhone)
                        .keyboardType(.phonePad)
                        .onChange(of: adminPhone) { newValue in
                            isAdminPhoneValid = !newValue.isEmpty
                        }
                    
                    // Integrate AdminPickerView here
                    AdminPickerView(existingAdmins: existingAdmins, selectedAdminIndex: $selectedAdminIndex)
                } else if selectedTypeIndex == 2 {
                    NavigationLink(destination: AdminPickerView(existingAdmins: existingAdmins, selectedAdminIndex: $selectedAdminIndex)) {
                        Text(selectedAdminIndex == 0 ? "Select Admin" : existingAdmins[selectedAdminIndex])
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: saveHospital) {
                    Text("Save")
                }
                .disabled(isSaveDisabled)
            }
        }
        .navigationTitle("Hospital")
    }
    
    private func saveHospital() {
        let newHospital = Hospital(name: name, address: address, city: city, country: country, zipCode: zipCode, phone: phone, email: email, type: "", admin: nil)
        
        if let index = hospitals.firstIndex(where: { $0.name == newHospital.name }) {
            // Update existing hospital
            hospitals[index] = newHospital
        } else {
            // Add new hospital
            hospitals.append(newHospital)
        }
        
        // Dismiss the form
        presentationMode.wrappedValue.dismiss()
    }
}
