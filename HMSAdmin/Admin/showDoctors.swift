import SwiftUI
import FirebaseFirestoreSwift

struct showDoctors: View {
    @State private var doctors: [Doctor] = []
    @State private var searchText = ""
    @State private var showingDoctorModal = false
    @State private var selectedDoctor: Doctor?
    @State private var isLoading = true

    private var filteredDoctors: [Doctor] {
        doctors.filter { doctor in
            searchText.isEmpty || doctor.firstName.localizedCaseInsensitiveContains(searchText) || doctor.lastName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading Doctors...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .onAppear {
                        fetchDoctors()
                    }
            } else {
                List(filteredDoctors) { doctor in
                    DoctorCard(doctor: doctor)
                        .onTapGesture {
                            selectedDoctor = doctor
                            showingDoctorModal = true
                        }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Doctors")
                .navigationBarItems(trailing: Button(action: {
                    selectedDoctor = nil
                    showingDoctorModal = true
                }) {
                    Image(systemName: "plus")
                })
                .searchable(text: $searchText, prompt: "Search")
                .sheet(isPresented: $showingDoctorModal) {
                    DoctorFormView(isPresented: $showingDoctorModal, doctors: $doctors, doctorToEdit: selectedDoctor)
                }
            }
        }
    }

    private func fetchDoctors() {
        isLoading = true
        DataController.shared.fetchDoctors()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("DoctorsUpdated"), object: nil, queue: .main) { _ in
            self.doctors = DataController.shared.getDoctors()
            print("Fetched \(self.doctors.count) doctors.")
            self.isLoading = false
        }
    }
}

struct AddDoctors_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            showDoctors()
        }
    }
}
