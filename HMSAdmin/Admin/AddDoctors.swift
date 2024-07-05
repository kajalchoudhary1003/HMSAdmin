import SwiftUI

struct Doctor: Identifiable {
    let id = UUID()
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String
    var designation: String
    var timeSlot: String
    var age: Int
}

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
            Text(doctor.designation)
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack {
                Text("Age: \(doctor.age)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text(doctor.timeSlot)
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
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var designation = ""
    @State private var timeSlot = ""
    @State private var age = ""

    var designations = ["General Practitioner", "Pediatrician", "Cardiologist", "Dermatologist"]
    var timeSlots = ["9:00 AM - 11:00 AM", "11:00 AM - 1:00 PM", "2:00 PM - 4:00 PM", "4:00 PM - 6:00 PM"]
    
    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phoneNumber.isEmpty && !designation.isEmpty && !timeSlot.isEmpty && !age.isEmpty
    }

    init(isPresented: Binding<Bool>, doctors: Binding<[Doctor]>, doctorToEdit: Doctor?) {
        self._isPresented = isPresented
        self._doctors = doctors
        self.doctorToEdit = doctorToEdit
        
        if let doctor = doctorToEdit {
            _firstName = State(initialValue: doctor.firstName)
            _lastName = State(initialValue: doctor.lastName)
            _email = State(initialValue: doctor.email)
            _phoneNumber = State(initialValue: doctor.phoneNumber)
            _designation = State(initialValue: doctor.designation)
            _timeSlot = State(initialValue: doctor.timeSlot)
            _age = State(initialValue: String(doctor.age))
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                    TextField("Phone Number", text: $phoneNumber)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Professional Information")) {
                    Picker("Designation", selection: $designation) {
                        ForEach(designations, id: \.self) {
                            Text($0)
                        }
                    }
                    Picker("Time Slot", selection: $timeSlot) {
                        ForEach(timeSlots, id: \.self) {
                            Text($0)
                        }
                    }
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
            phoneNumber: phoneNumber,
            designation: designation,
            timeSlot: timeSlot,
            age: Int(age) ?? 0
        )
        
        if let index = doctors.firstIndex(where: { $0.id == doctorToEdit?.id }) {
            doctors[index] = newDoctor
        } else {
            doctors.append(newDoctor)
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
