import SwiftUI

struct HospitalCardView: View {
    var hospital: Hospital
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(hospital.name)
                .font(.headline)
            Text(hospital.city)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
