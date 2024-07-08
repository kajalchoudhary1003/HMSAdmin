import SwiftUI

struct ShowHospital: View {
    let hospital: Hospital // The hospital object to display
    @State private var showDeleteConfirmation = false

    var body: some View {
        Form {
            // Section to display hospital details
            Section(header: Text("Hospital Details")) {
                Text("Name: \(hospital.name)")
                Text("Address: \(hospital.address)")
                Text("Phone: \(hospital.phone)")
                Text("Email: \(hospital.email)")
                Text("City: \(hospital.city)")
                Text("Country: \(hospital.country)")
                Text("Zip Code: \(hospital.zipCode)")
            }

            // Section to display admin details
            Section(header: Text("Admin Details")) {
                ForEach(hospital.admins) { admin in
                    VStack(alignment: .leading) {
                        Text("Name: \(admin.name)")
                        Text("Address: \(admin.address)")
                        Text("Phone: \(admin.phone)")
                        Text("Email: \(admin.email)")
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
    }

    private func deleteHospital() {
        DataController.shared.removeHospital(hospital) { error in
            if let error = error {
                print("Failed to delete hospital: \(error.localizedDescription)")
            } else {
                NotificationCenter.default.post(name: NSNotification.Name("HospitalsUpdated"), object: nil)
                // Optionally, you can navigate back or perform any additional UI updates
                print("Deleted hospital: \(hospital.name) with ID: \(hospital.id ?? "unknown")")
            }
        }
    }
}
