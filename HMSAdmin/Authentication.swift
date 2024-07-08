import SwiftUI
import Firebase

struct Authentication: View {
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var error = ""

    var body: some View {
        NavigationStack {
            VStack {
                // Title section
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

                // Image section
                Image("Doctor 3D")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400) // Adjust the height as needed
                    .padding(.bottom, 10)

                // Credential input instructions
                VStack(alignment: .leading) {
                    Text("Enter your credentials")
                        .font(.headline)
                        .padding(.bottom, 5)

                    Text("Please enter your email and password to proceed")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }
                .padding(.horizontal, 10)

                // Input fields and login button within ScrollView
                    VStack(spacing: 15) {
                        // Email input with validation
                        VStack(alignment: .leading) {
                            TextField("Email", text: $username)
                                .padding()
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(10)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                            Text(!isValidEmail(username) && !username.isEmpty ? "Please enter a valid email address" : " ")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 5)
                        }
                        .padding(.horizontal, 30)
                        
                        // Password input with validation
                        VStack(alignment: .leading) {
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(10)
                            Text(password.count < 6 && !password.isEmpty ? "Password must be at least 6 characters" : " ")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 5)
                        }
                        .padding(.horizontal, 30)
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.top, 5)
                        }

                        // Login button
                        Button("Login") {
                            // Validate inputs on button tap
                            validateInputs()
                        }
                        .foregroundColor(.white)
                        .frame(width: 317, height: 50)
                        .background(Color(hex: "#006666"))
                        .cornerRadius(14)
                        .font(.system(size: 20))
                    }
                    .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }

    // Function to validate inputs
    func validateInputs() {
        // Reset previous error message
        errorMessage = ""

        // Check if email is empty or invalid
        if username.isEmpty || !isValidEmail(username) {
            errorMessage = "Please enter a valid email address"
            return
        }

        // Check if password is empty or less than 6 characters
        if password.isEmpty || password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            return
        }

        // Proceed with authentication if inputs are valid
        authenticateUser(email: username, password: password)
    }

    // Function to authenticate user with Firebase
    func authenticateUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = "Invalid credentials. Check and try again..."
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
                navigateToScreen(screen: HospitalView())

            case "admin.com":
                navigateToScreen(screen: AdminView())

            case "doctor.com":
                navigateToScreen(screen: DoctorView())

            default:
                errorMessage = "Invalid email domain"
            }
        }
    }

    // Function to navigate to different screens based on user role
    func navigateToScreen<Screen: View>(screen: Screen) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(rootView: screen)
                window.makeKeyAndVisible()
            }
        }
    }

    // Function to validate email format
    func isValidEmail(_ email: String) -> Bool {
        // Updated regex to check for repetition of characters and specific domains
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@(?:(?:superadmin\\.com)|(?:admin\\.com)|(?:doctor\\.com))$"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct Authentication_Previews: PreviewProvider {
    static var previews: some View {
        Authentication()
    }
}
