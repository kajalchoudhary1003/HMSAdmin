import SwiftUI
import FirebaseDatabase

struct AddHospital: View {
    @Binding var hospitals: [Hospital]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var address: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var selectedTypeIndex = 0
    @State private var selectedAdminIndex = 0
    
    @State private var isNameValid = false
    @State private var isAddressValid = false
    @State private var isPhoneValid = false
    @State private var isEmailValid = false
    

    let adminTypes = ["Select", "New", "Existing"]
    let existingAdmins = ["Select", "Ansh", "Madhav", "John", "Jane", "Michael", "Emily", "David", "Sarah", "Robert"]

   
    
    var isSaveDisabled: Bool {
        return !isNameValid || !isAddressValid || !isPhoneValid || !isEmailValid
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
            Section(header: Text("Admin Details")) {
                Picker(selection: $selectedTypeIndex, label: Text("Type")) {
                    ForEach(0 ..< adminTypes.count) { index in
                        Text(self.adminTypes[index])
                    }
                }
                .pickerStyle(.menu)
            }
            if selectedTypeIndex > 0 {
                Section {
                    if adminTypes[selectedTypeIndex] == "New" {
                        TextField("Name", text: .constant(""))
                        TextField("Email", text: .constant(""))
                        TextField("Phone Number", text: .constant(""))
                    } else if adminTypes[selectedTypeIndex] == "Existing" {
                        Picker(selection: $selectedAdminIndex, label: Text("Select")) {
                            ForEach(0 ..< existingAdmins.count) { index in
                                Text(self.existingAdmins[index])
                            }
                        }

                    
                    // Integrate AdminPickerView here
                    AdminPickerView(existingAdmins: existingAdmins, selectedAdminIndex: $selectedAdminIndex)
                } else if selectedTypeIndex == 2 {
                    NavigationLink(destination: AdminPickerView(existingAdmins: existingAdmins, selectedAdminIndex: $selectedAdminIndex)) {
                        Text(selectedAdminIndex == 0 ? "Select Admin" : existingAdmins[selectedAdminIndex])

                        .pickerStyle(.navigationLink)

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
        .navigationTitle("New Hospital")
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

        let newHospital = Hospital(name: name, address: address, phone: phone, email: email, type: adminTypes[selectedTypeIndex])
        DataController.shared.addHospital(newHospital) { error in
            if let error = error {
                print("Failed to save hospital: \(error.localizedDescription)")
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }

    }
}
