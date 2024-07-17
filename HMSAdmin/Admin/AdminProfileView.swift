import SwiftUI
import FirebaseAuth

struct AdminProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    var admin1: AdminProfile

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

            Text("Profile")
                .font(.title)
                .fontWeight(.bold)
                .padding(.trailing, 250)

            Spacer().frame(height: 60)

            Circle()
                .fill(Color(hex: "006666"))
                .frame(width: 100, height: 100)
                .overlay(
                    Text(admin1.initials)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                )
                .padding(.trailing, 20)

            Text("\(admin1.firstName) \(admin1.lastName)")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 10)
                .padding(.trailing)

            VStack(alignment: .leading, spacing: 10) {
                AdminProfileRow(title: "First Name", value: admin1.firstName)
                Divider()
                AdminProfileRow(title: "Last Name", value: admin1.lastName)
                Divider()
                AdminProfileRow(title: "Email id", value: admin1.email)
                Divider()
                AdminProfileRow(title: "Phone Number", value: admin1.phone)
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
        .background(Color(.systemGray5))
    }
    
    // Function to handle logout
      func logout() {
          do {
              try Auth.auth().signOut()
              isLoggedIn = false
              navigateToScreen(screen: Authentication())
          } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
          }
      }


    // Function to navigate to different screens
     func navigateToScreen<Screen: View>(screen: Screen) {
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

struct AdminProfile {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String

    var initials: String {
        return "\(firstName.prefix(1))\(lastName.prefix(1))"
    }
}
#Preview {
    AdminProfileView(admin1: AdminProfile(id: "1", firstName: "Subhash", lastName: "Ghai", email: "subhash.ghai@example.com", phone: "1234567890"))
}
