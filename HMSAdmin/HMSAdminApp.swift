import SwiftUI
import Firebase

@main
struct HMSAdminApp: App {
    
    // Initialize Firebase in the initializer
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Authentication()
        }
    }
}
