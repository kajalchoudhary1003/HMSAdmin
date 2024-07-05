import SwiftUI

struct SuperAdminView: View {
    @State private var hospitals: [Hospital] = [
        Hospital(
            name: "Hospital A",
            email: "hospitala@example.com",
            phone: "123-456-7890",
            admins: [
                Admin(name: "Admin A", address: "Admin Address A", email: "admina@example.com", phone: "111-222-3333"),
                Admin(name: "Admin B", address: "Admin Address B", email: "adminb@example.com", phone: "444-555-6666")
            ],
            address: "123 Main St",
            city: "City A",
            country: "Country A",
            zipCode: "12345",
            type: "New"
        ),
        Hospital(
            name: "Hospital B",
            email: "hospitalb@example.com",
            phone: "987-654-3210",
            admins: [
                Admin(name: "Admin C", address: "Admin Address C", email: "adminc@example.com", phone: "777-888-9999")
            ],
            address: "456 Elm St",
            city: "City B",
            country: "Country B",
            zipCode: "54321",
            type: "Existing"
        )
    ]

    
    @State private var isPresentingAddHospital = false
//    @State private var selectedHospital: Hospital? // Track selected hospital for editing
    
    @State private var searchText = ""
    private var filteredHospitals: [Hospital] {
        hospitals.filter { hospital in
            searchText.isEmpty || hospital.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(filteredHospitals) { hospital in
                        NavigationLink(destination: 
                                        ShowHospital(hospital: hospital)) {
                            HospitalCardView(hospital: hospital)
                        }
                    }
                    .onDelete(perform: delete)
                }
                .navigationTitle("Hospitals")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: AddHospital(hospitals: $hospitals)) {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
                .searchable(text: $searchText) // Add searchable modifier for search functionality
//                .sheet(isPresented: $isPresentingAddHospital) {
//                                   AddHospital(hospitals: $hospitals)
//                               }
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        hospitals.remove(atOffsets: offsets)
    }
}

struct SuperAdminView_Previews: PreviewProvider {
    static var previews: some View {
        SuperAdminView()
    }
}
