import SwiftUI
import Firebase

struct SuperAdminView: View {
    @State private var hospitals: [Hospital] = []
    @State private var isPresentingAddHospital = false
    @State private var selectedHospital: Hospital? // Track selected hospital for editing
    @State private var showDeleteConfirmation = false
    @State private var searchText = ""
    @State private var isLoading = true
    
    private var filteredHospitals: [Hospital] {
        hospitals.filter { hospital in
            searchText.isEmpty || hospital.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading hospitals...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear {
                            fetchHospitals()
                        }
                } else if hospitals.isEmpty {
                    VStack {
                        Image(systemName: "building.2.crop.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        Text("No Hospitals Available")
                            .font(.title)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                        Text("Please add hospitals to manage them here.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                } else {
                    List {
                        ForEach(filteredHospitals) { hospital in
                            NavigationLink(destination: ShowHospital(hospital: hospital)) {
                                HospitalCardView(hospital: hospital)
                            }
                        }
                        .onDelete(perform: confirmDelete)
                    }
                    .searchable(text: $searchText)
                }
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
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Confirm Deletion"),
                    message: Text("Are you sure you want to delete this hospital?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let selectedHospital = selectedHospital {
                            delete(hospital: selectedHospital)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func fetchHospitals() {
        DataController.shared.fetchHospitals()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("HospitalsUpdated"), object: nil, queue: .main) { _ in
            self.hospitals = DataController.shared.getHospitals()
            print("Fetched \(self.hospitals.count) hospitals.")
            self.isLoading = false
        }
    }
    
    private func confirmDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            selectedHospital = hospitals[index]
            showDeleteConfirmation = true
        }
    }
    
    private func delete(hospital: Hospital) {
        DataController.shared.removeHospital(hospital) { error in
            if let error = error {
                print("Failed to delete hospital: \(error.localizedDescription)")
            } else {
                if let index = hospitals.firstIndex(of: hospital) {
                    hospitals.remove(at: index)
                    print("Deleted hospital: \(hospital.name) with ID: \(hospital.id ?? "unknown")")
                }
            }
        }
    }
}

struct SuperAdminView_Previews: PreviewProvider {
    static var previews: SuperAdminView {
        SuperAdminView()
    }
}
