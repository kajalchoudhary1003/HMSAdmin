import SwiftUI

struct SuperAdminView: View {
    @State private var hospitals: [Hospital] = []
    @State private var isPresentingAddHospital = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach($hospitals) { $hospital in
                    VStack(alignment: .leading) {
                        TextField("Name", text: $hospital.name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Address", text: $hospital.address)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Phone", text: $hospital.phone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                        TextField("Email", text: $hospital.email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                    }
                    .padding(.vertical, 5)
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
            .background(
                NavigationLink(destination: AddHospital(hospitals: $hospitals), isActive: $isPresentingAddHospital) {
                    EmptyView()
                }
                .hidden()
            )
        }
        .onAppear(perform: fetchHospitals)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HospitalsUpdated"))) { _ in
            self.hospitals = DataController.shared.getHospitals()
        }
    }
    
    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let hospital = hospitals[index]
            DataController.shared.removeHospital(hospital) { error in
                if let error = error {
                    print("Failed to delete hospital: \(error.localizedDescription)")
                } else {
                    hospitals.remove(atOffsets: offsets)
                }
            }
        }
    }
    
    private func fetchHospitals() {
        hospitals = DataController.shared.getHospitals()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SuperAdminView()
    }
}

#Preview {
    SuperAdminView()
}
