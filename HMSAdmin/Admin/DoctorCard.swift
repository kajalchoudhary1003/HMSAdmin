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
                Text("\(doctor.firstName) \(doctor.lastName)")
                    .font(.largeTitle)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            Text(doctor.designation.title)
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack {
                Spacer()
                Text(doctor.interval)
                    .font(.subheadline)
                    .foregroundColor(.teal)
            }
        }
        .padding(.vertical, 8)
    }
}

