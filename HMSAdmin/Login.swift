//
//  ContentView.swift
//  HMSAdmin
//
//  Created by Kajal Choudhary on 02/07/24.
//

import SwiftUI

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
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
                            .frame(width: 319, height: 50)
                            .background(Color.black.opacity(0.05))
                            
                        Rectangle()
                            .frame(width:319, height: 1)
                            .foregroundColor(Color.black.opacity(0.2))

                        SecureField("Password", text: $password)
                            .padding()
                            .frame(width: 319, height: 50)
                            .background(Color.black.opacity(0.05))
                            
                    }
                    .cornerRadius(14)
                   
                    
                    Spacer().frame(height: 50)
                    
                    Button("Login") {
                        //authenticate user logic
                    }
                    .foregroundColor(.white)
                    .frame(width: 317, height: 50)
                    .background(Color(hex: "#006666"))
                    .cornerRadius(14)
                    .fontWeight(.semibold)
                    .font(.system(size: 20))
                }
                
                Spacer() // This spacer will push the VStack to the top
            }
            .navigationBarHidden(true)
        }
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
    ContentView()
}
