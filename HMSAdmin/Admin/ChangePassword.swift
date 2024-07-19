import SwiftUI
import FirebaseAuth

struct ChangePassword: View {
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var oldPassword: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var navigateToHome = false
    @AppStorage("hasChangedPassword") var hasChangedPassword: Bool = false
    @Environment(\.presentationMode) var presentationMode
    var isFirstLogin: Bool
    
    var loggedInAdminID: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Password Reset")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your new password must be different from previous used password")
                    .font(.body)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 10) {
                    if !isFirstLogin {
                        SecureField("Old password", text: $oldPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    SecureField("New password", text: $newPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Text("Must be at least 8 characters")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    SecureField("Confirm password", text: $confirmPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Text("Both passwords must match")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                if let successMessage = successMessage {
                    Text(successMessage)
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal)
                }
                
                Button(action: handlePasswordReset) {
                    Text("Reset")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.init(hex: "#006666"))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Navigation link to redirect to home view on success
                NavigationLink("", destination: AdminView(loggedInAdminID: loggedInAdminID).navigationBarBackButtonHidden(true), isActive: $navigateToHome)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func handlePasswordReset() {
        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        guard newPassword.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return
        }
        
        guard let user = Auth.auth().currentUser, let email = user.email else {
            errorMessage = "User not found"
            return
        }
        
        if isFirstLogin {
            updatePassword(for: user)
        } else {
            let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
            user.reauthenticate(with: credential) { authResult, error in
                if let error = error {
                    errorMessage = "Authentication Failed: \(error.localizedDescription)"
                    return
                }
                updatePassword(for: user)
            }
        }
    }
    
    func updatePassword(for user: User) {
        user.updatePassword(to: newPassword) { error in
            if let error = error {
                errorMessage = "Password update failed: \(error.localizedDescription)"
            } else {
                successMessage = "Password Successfully Modified"
                errorMessage = nil
                hasChangedPassword = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if isFirstLogin {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        navigateToHome = true
                    }
                }
            }
        }
    }
}
