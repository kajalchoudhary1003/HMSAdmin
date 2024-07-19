import SwiftUI
import Firebase

struct Authentication: View {
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    @State private var clearFields = false
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("userRole") var userRole: String = ""
    @AppStorage("userID") var userID: String = "" // Store the logged-in user's ID
    @AppStorage("hasChangedPassword") var hasChangedPassword: Bool = false
    @State private var showChangePassword = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    VStack(alignment: .leading) {
                        Text("Welcome to")
                            .font(.title3)
                            .padding(.top, 10)
                        Text("infyMed")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color.customPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    
                    Spacer()
                }
                GeometryReader { geometry in
                    Image("Staff 3D")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                        .position(x: geometry.size.width / 1.62, y: geometry.size.height * 0.355)
                }

                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Enter your credentials")
                            .font(.headline)
                            .padding(5)
                            .padding(.top,8)
                            .padding(.horizontal,5)

                        Text("Please enter your email and password to proceed")
                            .font(.subheadline)
                            .foregroundColor(Color.customPrimary)
                            .padding(5)
                            .padding(.bottom, 5)
                            .padding(.horizontal,5)

                        VStack(alignment: .leading){
                            TextField("Email", text: $username)
                                .padding()
                                .background(Color("SecondaryColor"))
                                .cornerRadius(10)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .onChange(of: username) { newValue in
                                    if newValue.count > 100 {
                                        username = String(newValue.prefix(100))
                                    }
                                }
                                .onTapGesture {
                                    clearFields = false
                                }
                            if username.isEmpty {
                                Text(" ")
                                    .font(.caption)
                                    .padding(.horizontal,5)
                            } else if isValidEmail(username) {
                                Text("Yeah, Looks Valid Email Address")
                                    .foregroundColor(Color.customPrimary)
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
                                .background(Color("SecondaryColor"))
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
                                    .foregroundColor(Color.customPrimary)
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
                                        .fill(Color.customPrimary)
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
            .background(Color.customBackground)
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
        .fullScreenCover(isPresented: $showChangePassword) {
            ChangePassword(isFirstLogin: true, loggedInAdminID: userID)
        }
    }
    
    func validateInputs() {
        errorMessage = ""
        
        if username.isEmpty || !isValidEmail(username) {
            errorMessage = "Please enter a valid email address"
            showErrorAlert = true
            return
        }
        
        if password.isEmpty || password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            showErrorAlert = true
            return
        }
        
        authenticateUser(email: username, password: password)
    }
    
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
                    userRole = "superadmin"
                    isLoggedIn = true
                    navigateToScreen(screen: NewHome())
                case "admin.com", "doctor.com":
                    userRole = emailDomain == "admin.com" ? "admin" : "doctor"
                    isLoggedIn = true
                    if !hasChangedPassword {
                        showChangePassword = true
                    } else {
                        navigateToAppropriateScreen()
                    }
                    
                default:
                    errorMessage = "Invalid email domain"
                    showErrorAlert = true
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func navigateToScreen<Screen: View>(screen: Screen) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(rootView: screen)
                window.makeKeyAndVisible()
            }
        }
    }
    
    func navigateToAppropriateScreen() {
        switch userRole {
        case "admin":
            navigateToScreen(screen: AdminView(loggedInAdminID: userID))
        case "doctor":
            navigateToScreen(screen: DoctorView())
        default:
            break
        }
    }
}

struct Authentication_Previews: PreviewProvider {
    static var previews: some View {
        Authentication()
    }
}
