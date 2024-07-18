import SwiftUI
import FirebaseAuth

struct AdminProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var adminProfile: AdminProfile?
    @State private var isLoading = true
    
    var adminID: String
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else if let admin = adminProfile {
                profileContent(for: admin)
            } else {
                Text("Failed to load profile")
            }
        }
        .onAppear {
            fetchAdminProfile()
        }
        .background(Color.customBackground)
    }
    
    private func fetchAdminProfile() {
        print("Fetching admin profile for ID: \(adminID)")
        DataController.shared.fetchAdminProfile(adminID: adminID) { profile in
            if let profile = profile {
                print("Admin profile fetched successfully.")
                self.adminProfile = profile
            } else {
                print("Failed to fetch admin profile.")
            }
            self.isLoading = false
        }
    }
    
    @ViewBuilder
    private func profileContent(for admin: AdminProfile) -> some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                        .foregroundColor(Color.customPrimary)
                        .padding()
                }
            }
            .padding(.trailing)

            Text("Profile")
                .font(.title)
                .fontWeight(.bold)
                .padding(.trailing, 250)

            Spacer().frame(height: 60)

            Circle()
                .fill(Color.customPrimary)
                .frame(width: 100, height: 100)
                .overlay(
                    Text(admin.initials)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                )
                .padding(.trailing, 20)

            Text("\(admin.firstName) \(admin.lastName)")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 10)
                .padding(.trailing)

            VStack(alignment: .leading, spacing: 10) {
                AdminProfileRow(title: "First Name", value: admin.firstName)
                Divider()
                AdminProfileRow(title: "Last Name", value: admin.lastName)
                Divider()
                AdminProfileRow(title: "Email id", value: admin.email)
                Divider()
                AdminProfileRow(title: "Phone Number", value: admin.phone)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 20)

            Spacer()

            VStack {
                Button(action: {
                    logout()
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
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            navigateToScreen(screen: Authentication())
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    private func navigateToScreen<Screen: View>(screen: Screen) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(rootView: screen)
                window.makeKeyAndVisible()
            }
        }
    }
}

struct AdminProfileRow: View {
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
