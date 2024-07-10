import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Text("Profile")
                .font(.title)
                .fontWeight(.bold)
                .padding(.trailing, 250)
            
            Spacer().frame(height: 60)
            
            Image("profile_picture")
                .resizable()
                .scaledToFill()
                .frame(width: 130, height: 130)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(hex: 0x006666), lineWidth: 2))  // Updated line
                .shadow(radius: 10)
                .padding(.trailing, 20)
            
            Text("Dr. Rajesh Waghle")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 10)
                .padding(.trailing, 150)
            
            VStack(alignment: .leading, spacing: 10) {
                ProfileRow(title: "Qualification", value: "MBBS, MD")
                Divider()
                ProfileRow(title: "Department", value: "Physiotherapy")
                Divider()
                ProfileRow(title: "Email id", value: "waghlerajesh@gmail.com")
                Divider()
                ProfileRow(title: "Phone Number", value: "7864527364")
                Divider()
                ProfileRow(title: "Work Experience", value: "18+ yrs")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
            
            VStack {
                
                
                Button(action: {
                    // Logout action
                }) {
                    Text("Log out")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.red)
                        .font(.caption)
                        .background(Color.gray)  // Updated line
                        .cornerRadius(10)
                        
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .padding(.leading,50)
                .padding(.trailing,50)
            }
            
            Spacer().frame(height: 20)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

struct ProfileRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
                .font(.body)
        }
    }
}

extension Color {
    init(hex: Int, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

