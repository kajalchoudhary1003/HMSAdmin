//
//  DoctorCard.swift
//  HMSAdmin
//
//  Created by pushker yadav on 06/07/24.
//

import SwiftUI

struct DoctorCard: View {
    let doctor: Doctor
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(doctor.firstName) \(doctor.lastName)")
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(doctor.designation.title)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Fees: \(doctor.fees)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                    Text(doctor.interval)
                        .font(.headline)
                        .foregroundColor(Color(hex: "#006666"))
                        .padding(.top, 10)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(.vertical, 8)
        .padding(.horizontal,20)
        
    }
}

