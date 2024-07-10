import SwiftUI

struct ShowHospital: View {
    let hospital: Hospital // The hospital object to display
    @State private var showDeleteConfirmation = false
    @State private var isEditing = false
    @State private var editedHospital = Hospital(id: nil, name: "", email: "", phone: "", admins: [], address: "", city: "", country: "", zipCode: "", type: "")
    
    init(hospital: Hospital) {
        self.hospital = hospital
        self._editedHospital = State(initialValue: hospital)
    }
    
    var body: some View {
        Form {
            // Section to display hospital details
            Section(header: Text("Hospital Details")) {
                if isEditing {
                    HStack {
                        Text("Name:")
                        Spacer()
                        TextField("", text: $editedHospital.name)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Email:")
                        Spacer()
                        TextField("", text: $editedHospital.email)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Phone:")
                        Spacer()
                        TextField("", text: $editedHospital.phone)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Address:")
                        Spacer()
                        TextField("", text: $editedHospital.address)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("City:")
                        Spacer()
                        TextField("", text: $editedHospital.city)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Country:")
                        Spacer()
                        TextField("", text: $editedHospital.country)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Zip Code:")
                        Spacer()
                        TextField("", text: $editedHospital.zipCode)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.gray)
                    }
                } else {
                    HStack {
                        Text("Name:")
                        Spacer()
                        Text(hospital.name)
                    }
                    HStack {
                        Text("Email:")
                        Spacer()
                        Text(hospital.email)
                    }
                    HStack {
                        Text("Phone:")
                        Spacer()
                        Text(hospital.phone)
                    }
                    HStack {
                        Text("Address:")
                        Spacer()
                        Text(hospital.address)
                    }
                    HStack {
                        Text("City:")
                        Spacer()
                        Text(hospital.city)
                    }
                    HStack {
                        Text("Country:")
                        Spacer()
                        Text(hospital.country)
                    }
                    HStack {
                        Text("Zip Code:")
                        Spacer()
                        Text(hospital.zipCode)
                    }
                }
            }
                
            // Section to display admin details
            Section(header: Text("Admin Details")) {
                ForEach(hospital.admins) { admin in
                    HStack {
                        Text("Name:")
                        Spacer()
                        Text(admin.name)
                    }
                    HStack {
                        Text("Address:")
                        Spacer()
                        Text(admin.address)
                    }
                    HStack {
                        Text("Phone:")
                        Spacer()
                        Text(admin.phone)
                    }
                    HStack {
                        Text("Email:")
                        Spacer()
                        Text(admin.email)
                    }
                }
            }
            
            // Delete Hospital Button
            Section {
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Text("Delete Hospital")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle(hospital.name)
        .navigationBarItems(trailing: Button(action: {
            isEditing.toggle()
        }) {
            Text(isEditing ? "Save" : "Edit")
        })
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Confirm Deletion"),
                message: Text("Are you sure you want to delete this hospital?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteHospital()
                },
                secondaryButton: .cancel()
            )
        }
        .onChange(of: isEditing) { newValue in
            if !newValue {
                // Save changes when editing is done
                // You need to implement the updateHospital function in your DataController
                // DataController.shared.updateHospital(editedHospital) { error in
                //     if let error = error {
                //         print("Failed to update hospital: \(error.localizedDescription)")
                //     } else {
                //         NotificationCenter.default.post(name: NSNotification.Name("HospitalsUpdated"), object: nil)
                //         print("Updated hospital: \(hospital.name) with ID: \(hospital.id)")
                //     }
                // }
            }
        }
    }
    
    func deleteHospital() {
        DataController.shared.removeHospital(hospital) { error in
            if let error = error {
                print("Failed to delete hospital: \(error.localizedDescription)")
            } else {
                NotificationCenter.default.post(name: NSNotification.Name("HospitalsUpdated"), object: nil)
                // Optionally, you can navigate back or perform any additional UI updates
                print("Deleted hospital: \(hospital.name) with ID: \(hospital.id)")
            }
        }
    }
}
