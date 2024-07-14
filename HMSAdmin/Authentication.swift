import SwiftUI
import Firebase

struct Authentication: View {
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    @State private var clearFields = false
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    VStack(alignment: .leading) {
                        Text("Welcome to")
                            .font(.title3)
                            .padding(.top, 10)
                        Text("Mediflex")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color(hex: "006666"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    
                    Spacer() // Pushes VStack content to the top
                }
                VStack(alignment: .trailing){
                    Image("Doctor 3D")
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom,220)
                }

                // Login input section at the bottom
                VStack {
                    Spacer() // Pushes login section to the bottom
                    
                    VStack(alignment: .leading) {
                        Text("Enter your credentials")
                            .font(.headline)
                            .padding(5)
                            .padding(.top,8)
                            .padding(.horizontal,5)

                        
                        Text("Please enter your email and password to proceed")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "006666"))
                            .padding(5)
                            .padding(.bottom, 5)
                            .padding(.horizontal,5)

                        
                        VStack(alignment: .leading){
                            TextField("Email", text: $username)
                                .padding()
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(10)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .onChange(of: username) { newValue in
                                    if newValue.count > 100 {
                                        username = String(newValue.prefix(100))
                                    }
                                }
                                .onTapGesture {
                                    clearFields = false // Ensure fields are not cleared on tap
                                }
                            if username.isEmpty {
                                Text(" ")
                                    .font(.caption)
                                    .padding(.horizontal,5)

                            } else if isValidEmail(username) {
                                Text("Yeah, Looks Valid Email Address")
                                    .foregroundColor(Color(hex: "006666"))
                                    .font(.caption)
                                    .padding(.horizontal,5)

                            } else {
                                Text("Enter a valid email address")
                                    .foregroundColor(Color(UIColor.systemRed))
                                    .font(.caption)
                                    .padding(.horizontal,5)

                            }
                            
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(10)
                                .onTapGesture {
                                    clearFields = false
                                }
                            if password.isEmpty {
                                Text(" ")
                                    .padding(.horizontal,5)
                                    .font(.caption)
                            } else if password.count >= 6 {
                                Text("Seems Valid!")
                                    .foregroundColor(Color(hex: "006666"))
                                    .font(.caption)
                                    .padding(.horizontal,5)
                            } else {
                                Text("Password must be at least 6 characters")
                                    .foregroundColor(Color(UIColor.systemRed))
                                    .font(.caption)
                                    .padding(.horizontal,5)

                            }
                            
                            Button(action: {
                                validateInputs()
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: "006666"))
                                    Text("Sign In")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                }
                                .frame(maxHeight: 22)
                                .padding(.vertical)
                            }
                        }
                        .padding(.horizontal,5)
                        
                    }
                    .padding(.vertical, 5)
                    .background(Blur())
                    .padding(.horizontal, 6)
                    .cornerRadius(22)
                }
            }
            .padding(.bottom,10)
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage).font(.caption), dismissButton: .default(Text("Dismiss"))
                  {
                clearFields = true
                username = ""
                password = ""
            }
            )
        }
    }
    
    // Function to validate inputs
    func validateInputs() {
        // Reset previous error message
        errorMessage = ""
        
        // Check if email is empty or invalid
        if username.isEmpty || !isValidEmail(username) {
            errorMessage = "Please enter a valid email address"
            showErrorAlert = true
            return
        }
        
        // Check if password is empty or less than 6 characters
        if password.isEmpty || password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            showErrorAlert = true
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
                showErrorAlert = true
                return
            }
            
            guard (authResult?.user) != nil else {
                errorMessage = "Authentication failed"
                showErrorAlert = true
                return
            }
            
            // User role based on email domain
            let emailDomain = email.components(separatedBy: "@").last ?? ""
            
            switch emailDomain {
                       case "superadmin.com":
                           isLoggedIn = true
                           navigateToScreen(screen: AdminHome())
                           
                       case "admin.com":
                           isLoggedIn = true
                           navigateToScreen(screen: AdminView())
                           
                       case "doctor.com":
                           isLoggedIn = true
                           navigateToScreen(screen: DoctorView())
                           
                       default:
                           errorMessage = "Invalid email domain"
                           showErrorAlert = true
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
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct Authentication_Previews: PreviewProvider {
    static var previews: some View {
        Authentication()
    }
}
