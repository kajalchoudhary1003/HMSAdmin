import SwiftUI

struct ShowHospital: View {
    let hospital: Hospital // The hospital object to display

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
        }
        .navigationTitle(hospital.name)
    }
}


