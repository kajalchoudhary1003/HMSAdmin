import SwiftUI

struct AdminView: View {
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Analytics").font(.headline).foregroundColor(.gray)) {
                    HStack {
                        Text("Bookings")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#006666"))
                        Spacer()
                        Text("46")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#006666"))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                }

                Section(header: Text("Hospital Data").font(.headline).foregroundColor(.gray)) {
                    VStack(spacing: 16) {
                        NavigationLink(destination: AddDoctors()) {
                            HospitalDataRow(icon: "stethoscope", title: "Doctors", count: "80")
                        }
                        HospitalDataRow(icon: "syringe", title: "Staffs", count: "120")
                        HospitalDataRow(icon: "gift", title: "Offers", count: "05")
                    }
                    .listRowInsets(EdgeInsets())
                    .background(Color.clear)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .searchable(text: $searchText, prompt: "Search")
            .navigationTitle("Hi, Admin")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(Color(hex: "#006666"))
                }
            }
        }
    }
}

struct HospitalDataRow: View {
    let icon: String
    let title: String
    let count: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(hex: "#006666"))
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            Spacer()
            Text(count)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.black)
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

#Preview {
    AdminView()
}
