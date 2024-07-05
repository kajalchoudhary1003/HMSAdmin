import SwiftUI
import Firebase

struct Authentication: View {
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: 100) // Adjust the height to position the entire VStack from the top
                
                VStack {
                    Image("HMSLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 190, height: 132) // Set the width and height to 190x132
                    
                    Spacer().frame(height: 10) // Adjust the height to create distance between the image and text
                    
                    Text("MediFlex")
                        .font(.system(size: 32))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#006666")) // Set the font color to hex: 006666
                    Spacer().frame(height: 50)
                    
                    VStack (spacing: 0){
                        TextField("Email", text: $username)
                            .padding()
                            .frame(width: 319, height: 45)
                            .background(Color.black.opacity(0.05))
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        Rectangle()
                            .frame(width:319, height: 1)
                            .foregroundColor(Color.black.opacity(0.2))

                        SecureField("Password", text: $password)
                            .padding()
                            .frame(width: 319, height: 45)
                            .background(Color.black.opacity(0.05))
                    }
                    .cornerRadius(14)
                   
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                    
                    Button("Login") {
                        if username.isEmpty || password.isEmpty {
                            errorMessage = "Please enter both email and password"
                        } else {
                            authenticateUser(email: username, password: password)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 317, height: 50)
                    .background(Color(hex: "#006666"))
                    .cornerRadius(14)
                    .fontWeight(.semibold)
                    .font(.system(size: 20))
                    .opacity(isValidEmail(username) && !password.isEmpty ? 1.0 : 0.6)
                    .disabled(!isValidEmail(username) || password.isEmpty)
                }
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
    
    func authenticateUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if error != nil {
                errorMessage = "Invalid credentials. Please try again."
                return
            }
            
            guard (authResult?.user) != nil else {
                errorMessage = "Authentication failed"
                return
            }
            
            // User role based on email domain
            let emailDomain = email.components(separatedBy: "@").last ?? ""
            
            switch emailDomain {
            case "superadmin.com":
                navigateToScreen(screen: SuperAdminView())
                
            case "admin.com":
                navigateToScreen(screen: AdminView())
                
            case "doctor.com":
                navigateToScreen(screen: DoctorView())
                
            default:
                errorMessage = "Invalid email domain"
            }
        }
    }
    
    func navigateToScreen<Screen: View>(screen: Screen) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(rootView: screen)
                window.makeKeyAndVisible()
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    Authentication()
}
