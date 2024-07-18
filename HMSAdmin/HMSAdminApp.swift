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
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                switch userRole {
                case "superadmin":
                    NewHome()
                case "admin":
                    AdminView()
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
