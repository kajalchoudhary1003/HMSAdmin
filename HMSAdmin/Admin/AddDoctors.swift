import SwiftUI
import FirebaseFirestoreSwift

struct AddDoctors: View {
    @State private var doctors: [Doctor] = []
    @State private var searchText = ""
    @State private var showingDoctorModal = false
    @State private var selectedDoctor: Doctor?

    var body: some View {
        List {
            ForEach(doctors) { doctor in
                DoctorRow(doctor: doctor)
                    .onTapGesture {
                        selectedDoctor = doctor
                        showingDoctorModal = true
                    }
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

struct DoctorRow: View {
    let doctor: Doctor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("\(doctor.firstName) \(doctor.lastName)")
                    .font(.largeTitle)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            Text(doctor.designation.title)
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack {
                Spacer()
                Text(doctor.interval)
                    .font(.subheadline)
                    .foregroundColor(.teal)
            }
        }
        .padding(.vertical, 8)
    }
}

struct DoctorFormView: View {
    @Binding var isPresented: Bool
    @Binding var doctors: [Doctor]
    var doctorToEdit: Doctor?
    @Environment(\.presentationMode) var presentationMode
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var starts = Date()
    @State private var ends = Date()
    @State private var dob = Date()
    @State private var designation: DoctorDesignation = .generalPractitioner
    @State private var titles = ""

    var designations = DoctorDesignation.allCases
    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phone.isEmpty && !titles.isEmpty
    }
    
    init(isPresented: Binding<Bool>, doctors: Binding<[Doctor]>, doctorToEdit: Doctor?) {
        self._isPresented = isPresented
        self._doctors = doctors
        self.doctorToEdit = doctorToEdit
        
        if let doctor = doctorToEdit {
            _firstName = State(initialValue: doctor.firstName)
            _lastName = State(initialValue: doctor.lastName)
            _email = State(initialValue: doctor.email)
            _phone = State(initialValue: doctor.phone)
            _starts = State(initialValue: doctor.starts)
            _ends = State(initialValue: doctor.ends)
            _dob = State(initialValue: doctor.dob)
            _designation = State(initialValue: doctor.designation)
            _titles = State(initialValue: doctor.titles)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                    TextField("Phone Number", text: $phone)
                    DatePicker("Date of Birth", selection: $dob, displayedComponents: .date)
                }
                
                Section(header: Text("Professional Information")) {
                    Picker("Designation", selection: $designation) {
                        ForEach(designations, id: \.self) {
                            Text($0.title)
                        }
                    }
                    DatePicker("Starts", selection: $starts, displayedComponents: .hourAndMinute)
                    DatePicker("Ends", selection: $ends, displayedComponents: .hourAndMinute)
                    TextField("Titles", text: $titles)
                }
            }
            .navigationTitle(doctorToEdit == nil ? "Add Doctor" : "Edit Doctor")
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            }, trailing: Button("Save") {
                saveDoctor()
                isPresented = false
            }
            .disabled(!isFormValid))
        }
    }
    
    private func saveDoctor() {
            let newDoctor = Doctor(
                firstName: firstName,
                lastName: lastName,
                email: email,
                phone: phone,
                starts: starts,
                ends: ends,
                dob: dob,
                designation: designation,
                titles: titles
            )
            
            if let doctorToEdit = doctorToEdit, let index = doctors.firstIndex(where: { $0.id == doctorToEdit.id }) {
                var updatedDoctor = newDoctor
                updatedDoctor.id = doctorToEdit.id
                doctors[index] = updatedDoctor
                DataController.shared.addDoctor(updatedDoctor) { error in
                    if let error = error {
                        print("Failed to save doctor: \(error.localizedDescription)")
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } else {
                DataController.shared.addDoctor(newDoctor) { error in
                    if let error = error {
                        print("Failed to save doctor: \(error.localizedDescription)")
                    } else {
                        doctors.append(newDoctor)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
}

struct AddDoctors_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddDoctors()
        }
    }
}


