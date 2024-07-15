import SwiftUI

struct StaffsView: View {
    @State private var searchText = ""
    @State private var selectedFilter = "Nurse"

    
    @State private var staffs = [Staff]()
    @State private var isPresentingAddStaffView = false
    
    var filteredStaffs: [Staff] {
        staffs.filter { staff in
            (selectedFilter == "Nurse" || selectedFilter == "Caretakers") &&
            (searchText.isEmpty || staff.firstName.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
            VStack {
                Picker("Filter", selection: $selectedFilter) {
                    Text("Nurse").tag("Nurse")
                    Text("Caretakers").tag("Caretakers")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredStaffs) { staff in
                            NavigationLink(destination: Text("Staff Details View for \(staff.firstName)")) {
                                StaffCard(staff: staff)
                            }
                        }
                    }
                    .searchable(text: $searchText)
                    .padding(.horizontal)
                }
            }
            .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
            .navigationTitle("Staffs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresentingAddStaffView.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddStaffView) {
                AddStaffsView(staffs: $staffs, isPresentingAddStaffView: $isPresentingAddStaffView)
            }
            .onAppear{
                DataController.shared.fetchStaffs()
            }
            .onReceive(DataController.shared.$staffs) {
                newStaffs in
                staffs = Array(newStaffs.values)
            }
        }
        //.navigationViewStyle(StackNavigationViewStyle())
    }


struct StaffCard: View {
    var staff: Staff
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(staff.firstName)
                .font(.headline)
                .foregroundColor(.black)
            Text(staff.position)
                .font(.subheadline)
                .foregroundColor(.black)
            HStack {
                Text("Age: \(staff.age)")
                    .font(.caption)
                    .foregroundColor(.black)
                Spacer()
                Text(staff.department)
                    .font(.body)
                    .foregroundColor(Color(red: 0.0, green: 0.49, blue: 0.45))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
    }
}

struct AddStaffsView: View {
    @Binding var staffs: [Staff]
    @Binding var isPresentingAddStaffView: Bool
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth = Date()
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var selectedPosition: String = ""
    @State private var selectedDepartment: String = ""
    @State private var selectedEmploymentStatus: String = ""
    
    let positions = ["Nurse", "Care Taker"]
    let departments = ["General Ward", "ICU", "Emergency"]
    let employmentStatuses = ["Full-Time", "Part-Time", "Contractor"]
    
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("DETAILS")) {
                    TextField("First name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    
                    DatePicker("Date Of Birth", selection: $dateOfBirth, displayedComponents: .date)
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }
                
                Picker("Position", selection: $selectedPosition) {
                    ForEach(positions, id: \.self) { position in
                        Text(position)
                    }
                }
                
                Picker("Department", selection: $selectedDepartment) {
                    ForEach(departments, id: \.self) { department in
                        Text(department)
                    }
                }
                
                Picker("Employment Status", selection: $selectedEmploymentStatus) {
                    ForEach(employmentStatuses, id: \.self) { status in
                        Text(status)
                    }
                }
            }
            .navigationTitle("Add Staffs")
            .navigationBarItems(trailing: Button("Done") {
                saveStaff()
                isPresentingAddStaffView = false
            })
        }
    }
    
    func saveStaff() {
        let newStaff = Staff(
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth,
            phoneNumber: phoneNumber,
            email: email,
            position: selectedPosition,
            department: selectedDepartment,
            employmentStatus: selectedEmploymentStatus
        )
        
        DataController.shared.addStaff(newStaff) { error in
            if let error = error {
                print("Error adding staff: \(error.localizedDescription)")
            } else {
                self.staffs.append(newStaff)
            }
        }
        
        resetForm()
    }
    
    func resetForm() {
        firstName = ""
        lastName = ""
        dateOfBirth = Date()
        phoneNumber = ""
        email = ""
        selectedPosition = ""
        selectedDepartment = ""
        selectedEmploymentStatus = ""
    }
    
    func calculateAge(from date: Date) -> Int {
        let now = Date()
        let ageComponents = Calendar.current.dateComponents([.year], from: date, to: now)
        return ageComponents.year ?? 0
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StaffsView()
    }
}


