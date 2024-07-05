import SwiftUI

struct SuperAdminView: View {
    @State private var hospitals: [Hospital] = [
        Hospital(name: "City Hospital", address: "123 Main St", city: "Springfield", country: "USA", zipCode: "12345", phone: "123-456-7890", email: "info@cityhospital.com", type: "General", admin: Hospital.Admin(name: "John Doe", email: "john.doe@cityhospital.com", phone: "321-654-0987")),
        Hospital(name: "County Hospital", address: "456 Elm St", city: "Shelbyville", country: "USA", zipCode: "67890", phone: "987-654-3210", email: "contact@countyhospital.com", type: "Specialty", admin: Hospital.Admin(name: "Jane Smith", email: "jane.smith@countyhospital.com", phone: "654-321-0987"))
    ]
    
    @State private var isPresentingAddHospital = false
    @State private var selectedHospital: Hospital? // Track selected hospital for editing
    
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
                        NavigationLink(destination: HospitalFormView(hospitals: $hospitals, hospital: hospital)) {
                            HospitalCardView(hospital: hospital)
                                .onTapGesture {
                                    selectedHospital = hospital
                                }
                        }
                    }
                    .onDelete(perform: delete)
                }
                .navigationTitle("Hospitals")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isPresentingAddHospital = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
                .searchable(text: $searchText) // Add searchable modifier for search functionality
                .background(
                    NavigationLink(destination: HospitalFormView(hospitals: $hospitals, hospital: selectedHospital), isActive: $isPresentingAddHospital) {
                        EmptyView()
                    }
                    .hidden()
                )
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
