//
//  ChangePassword.swift
//  HMSAdmin
//
//  Created by Madhav Sharma on 04/07/24.
//

import SwiftUI

struct ChangePassword: View {
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Password Reset")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your new password must be different from previous used password")
                .font(.body)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 10) {
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
            
            Button(action: {
                // Handle password reset action
            }) {
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
        }
        .padding()
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePassword()
    }
}
