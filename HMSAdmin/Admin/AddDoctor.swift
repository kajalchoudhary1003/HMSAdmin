//
//  AddDoctor.swift
//  HMSAdmin
//
//  Created by Madhav Sharma on 05/07/24.
//

import SwiftUI

struct Doctor: Identifiable { // Sample Doctor Data Structure
    let id = UUID()
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String
}

struct AddDoctor: View {
    @State private var isAddingDoctor = false
    @State private var doctors = [Doctor]() // Initialize with sample data or fetch from backend

    var body: some View {
        NavigationView {
            List {
                ForEach(doctors) { doctor in
                    Text("\(doctor.firstName) \(doctor.lastName)") // Display doctor name
                }
            }
            .navigationTitle("Doctors")
            .toolbar {
                Button(action: {
                    isAddingDoctor = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $isAddingDoctor) {
                AddDoctorView(isPresented: $isAddingDoctor, doctors: $doctors)
            }
        }
    }
}

struct AddDoctorView: View {
    @Binding var isPresented: Bool
    @Binding var doctors: [Doctor]

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phoneNumber = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                TextField("Email", text: $email)
                TextField("Phone Number", text: $phoneNumber)
            }
            .navigationTitle("Add Doctor")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newDoctor = Doctor(firstName: firstName, lastName: lastName,
                                               email: email, phoneNumber: phoneNumber)
                        doctors.append(newDoctor)
                        isPresented = false
                    }
                }
            }
        }
    }
}
#Preview{
    AddDoctor()
}
