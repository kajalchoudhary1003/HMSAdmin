import SwiftUI

struct AdminView: View {
    
    @State private var searchText: String = ""
    @State private var doctors: [Doctor] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            List {
                analyticsSection
                hospitalDataSection
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
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    private var analyticsSection: some View {
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
            .frame(maxWidth: .infinity, minHeight: 110)
            .background(Color.white)
            .cornerRadius(10)
        }
    }
    
    private var hospitalDataSection: some View {
        Section(header: Text("Hospital Data").font(.headline).foregroundColor(.gray)) {
                dataCard(icon: "stethoscope", title: "Doctors", count: "80", destination: AnyView(ShowDoctors()))
                dataCard(icon: "syringe", title: "Staffs", count: "120", destination: AnyView(Text("Staff Screen")))
                dataCard(icon: "gift", title: "Offers", count: "05", destination: AnyView(Text("Offers Screen")))
        }
    }
    
    private func dataCard(icon: String, title: String, count: String, destination: AnyView) -> some View {
        NavigationLink(destination: destination) {
            HStack {
                HStack(spacing: 15) {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(Color(hex: "#006666"))
                    Text(title)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                Spacer()
                Text(count)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
            }
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 100)
        }
        .padding(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 20))
        .listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        .listRowBackground(Color.clear)
        .background(Color.white)
        .cornerRadius(10)
    }
}

#Preview {
    AdminView()
}
