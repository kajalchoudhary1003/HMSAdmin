import SwiftUI

struct SuperAdminView: View {
    @State private var hospitals: [Hospital] = [
        Hospital(name: "John Doe", address: "Address One", phone: "123-456-7890", email: "john@example.com", type: "New"),
        Hospital(name: "Jane Smith", address: "Address Two", phone: "987-654-3210", email: "jane@example.com", type: "Existing")
    ]
    
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
                            NavigationLink(destination: HospitalFormView(hospitals: $hospitals), isActive: $isPresentingAddHospital) {
                                EmptyView()
                            }
                            .hidden()
                        )
                    }
                }
    
    private func delete(at offsets: IndexSet) {
        hospitals.remove(atOffsets: offsets)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


#Preview {
    ContentView()
}
