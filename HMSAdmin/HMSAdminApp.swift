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
    
   
     
     var body: some Scene {
         WindowGroup {
             if isLoggedIn {
                 Home()
             } else {
                 Authentication()
             }
         }
     }
 }
