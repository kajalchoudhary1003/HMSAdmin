import SwiftUI

struct HospitalCardView: View {
    var hospital: Hospital
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(hospital.city)
                .font(.title2)
                .foregroundColor(Color(.black))
            Text(hospital.city)
                .font(.subheadline)
                .foregroundColor(Color(.systemGray))
            HStack{
                Text(hospital.zipCode)
                    .font(.footnote)
                    .foregroundColor(Color(.systemGray2))
                
                Spacer()
                
                Text("Revenue")
                    .font(.headline)
                    .foregroundColor(Color.customPrimary)
                
            }
        }
        .padding()
        .background(Color(.white))
        .cornerRadius(10)
    }
}
