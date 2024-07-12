import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ProfileViewModel()
    
    var doctor: Doctor?

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                        .foregroundColor(Color(hex: "006666"))
                        .padding()
                }
            }
            .padding(.trailing)
            .padding()
            
            Text("Profile")
                .font(.title)
                .fontWeight(.bold)
                .padding(.trailing, 250)
            
            Spacer().frame(height: 60)
            
            Image("profile_picture")
                .resizable()
                .scaledToFill()
                .frame(width: 130, height: 130)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(hex: "006666"), lineWidth: 2))
                .shadow(radius: 10)
                .padding(.trailing, 20)
            
            Text("\(doctor?.firstName ?? "N/A") \(doctor?.lastName ?? "N/A")")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 10)
                .padding(.trailing, 150)
            
            VStack(alignment: .leading, spacing: 10) {
                ProfileRow(title: "Qualification", value: doctor?.titles ?? "N/A")
                Divider()
                ProfileRow(title: "Department", value: doctor?.designation.title ?? "N/A")
                Divider()
                ProfileRow(title: "Email id", value: doctor?.email ?? "N/A")
                Divider()
                ProfileRow(title: "Phone Number", value: doctor?.phone ?? "N/A")
                Divider()
                ProfileRow(title: "Work Experience", value: "18+ yrs") // Placeholder for experience
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
            
            VStack {
                Button(action: {
                    // Logout action
                }) {
                    Text("Log out")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(6)
                        .foregroundColor(.red)
                        .font(.title)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .padding(.leading, 16)
                .padding(.trailing, 16)
            }
            
            Spacer().frame(height: 20)
        }
        .background(Color(.systemGray5))
    }
}

struct ProfileRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
                .font(.body)
        }
    }
}

class ProfileViewModel: ObservableObject {
    @Published var doctor: Doctor?
    
    func fetchDoctor(by id: String) {
        // Fetch the doctor from DataController
        if let doctor = DataController.shared.getDoctors().first(where: { $0.id == id }) {
            self.doctor = doctor
        }
    }
}
