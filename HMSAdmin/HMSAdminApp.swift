import SwiftUI
import Firebase

@main
struct HMSAdminApp: App {
    
    // Initialize Firebase in the initializer
    init() {
        FirebaseApp.configure()
    }
    
    // Initialize Firebase in the initializer
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("userRole") var userRole: String = ""
    @AppStorage("userID") var userID: String = "" // Assuming you store the logged-in user's ID
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                switch userRole {
                case "superadmin":
                    NewHome()
                case "admin":
                    AdminView(loggedInAdminID: userID)
                case "doctor":
                    DoctorView()
                default:
                    Authentication()
                }
            } else {
                Authentication()
            }
        }
    }
}
