import SwiftUI
import Firebase

struct Authentication: View {
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading) {
                    Text("Welcome to")
                        .font(.title3)
                        .padding(.top, 10)
                    Text("Mediflex")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color(red: 0.0, green: 0.49, blue: 0.45))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)

                Spacer()

                Image("Doctor 3D")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400) // Adjust the height as needed
                    .padding(.bottom, 10)

                VStack(alignment: .leading) {
                    Text("Enter your credentials")
                        .font(.headline)
                        .padding(.bottom, 5)

                    Text("Please enter your email and password to proceed")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)

                VStack(spacing: 15) {
                    VStack(alignment: .leading) {
                        TextField("Email", text: $username)
                            .padding()
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(10)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    .padding(.horizontal, 30)
                    
                    VStack(alignment: .leading) {
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 20)
               
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
