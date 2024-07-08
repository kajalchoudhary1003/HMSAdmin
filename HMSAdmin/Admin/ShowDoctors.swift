import SwiftUI

struct ShowDoctors: View {
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
            }
                else if !doctors.isEmpty {
                    VStack {
                        Image(systemName: "stethoscope.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        Text("No Doctors Available")
                            .font(.title)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                        Text("Please add doctors to manage them here.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                    .navigationTitle("Doctors")
                    .padding(.vertical,10)
    //                .padding(.horizontal,0)
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
            } else {
                ScrollView {
                    ForEach(filteredDoctors, id: \.id) { doctor in
                        DoctorCard(doctor: doctor)
                            .onTapGesture {
                                selectedDoctor = doctor
                                showingDoctorModal = true
                            }
                            .listRowInsets(EdgeInsets())
                    }
                }
                .navigationTitle("Doctors")
                .padding(.vertical,10)
                .navigationBarItems(trailing: Button(action: {
                    selectedDoctor = nil
                    showingDoctorModal = true
                }) {
                    Image(systemName: "plus")
                })
                .searchable(text: $searchText, prompt: "Search")
                .sheet(isPresented: $showingDoctorModal) {
                    DoctorFormView(isPresent: $showingDoctorModal, doctors: $doctors, doctorToEdit: selectedDoctor)
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

struct ShowDoctors_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ShowDoctors()
        }
    }
}
