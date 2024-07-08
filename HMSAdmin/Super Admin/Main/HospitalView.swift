import SwiftUI
import Firebase

struct HospitalView: View {
    @State private var hospitals: [Hospital] = []
    @State private var isPresentingAddHospital = false
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
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredHospitals) { hospital in
                                NavigationLink(destination: ShowHospital(hospital: hospital)) {
                                    HospitalCardView(hospital: hospital)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color(hex: "ECEEEE"))
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Hospitals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddHospital(hospitals: $hospitals)) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HospitalsUpdated"))) { _ in
            // Refresh hospitals when notification received
            self.hospitals = DataController.shared.getHospitals()
            print("Fetched \(self.hospitals.count) hospitals.")
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
}

struct HospitalView_Previews: PreviewProvider {
    static var previews: some View {
        HospitalView()
    }
}
