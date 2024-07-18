import SwiftUI

struct DoctorCard: View {
    let doctor: Doctor
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(doctor.firstName) \(doctor.lastName)")
                        .font(.title2)
                        .foregroundColor(Color("TextColor"))
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
                    
                    Spacer()
                    
                    Text(doctor.interval)
                        .font(.headline)
                        .foregroundColor(Color("AccentColor"))
                        .padding(.top, 10)
                }
            }
            .padding()
            .background(Color("SecondaryColor"))
            .cornerRadius(8)
        }
        .padding(.vertical, 8)
        .padding(.horizontal,20)
        
    }
}

