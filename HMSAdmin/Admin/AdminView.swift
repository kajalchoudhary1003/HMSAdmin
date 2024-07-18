import SwiftUI

struct AdminView: View {
    
    @State private var searchText: String = ""
    @State private var doctors: [Doctor] = []
    @State private var isLoading = true
    @State private var isProfilePresented = false
    
    var body: some View {
        NavigationView {
            List {
                hospitalDataSection
            }
            .background(Color("BackgroundColor"))
            .listStyle(InsetGroupedListStyle())
            .searchable(text: $searchText, prompt: "Search")
            .navigationTitle("Hi, Admin")
            .toolbar {
                ToolbarItem() {
                    Button(action: {
                        isProfilePresented.toggle()
                    }) {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundColor(Color("AccentColor"))
                    }
                }
            }
            .sheet(isPresented: $isProfilePresented) {
                AdminProfileView(admin1: AdminProfile(id: "1", firstName: "Subhash", lastName: "Ghai", email: "subhash.ghai@example.com", phone: "1234567890"))
            }
        }.background(Color.customBackground)
    }
    
    private var hospitalDataSection: some View {
        Section(header: Text("Hospital Data").font(.headline).foregroundColor(.gray)) {
            dataCard(icon: "stethoscope", title: "Doctors", count: "80", destination: AnyView(ShowDoctors()))
            dataCard(icon: "syringe", title: "Staffs", count: "120", destination: AnyView(StaffsView()))
            dataCard(icon: "gift", title: "Offers", count: "05", destination: AnyView(Text("Offers Screen")))
        }
    }
    
    private func dataCard(icon: String, title: String, count: String, destination: AnyView) -> some View {
        NavigationLink(destination: destination) {
            HStack {
                HStack(spacing: 20) {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(Color( "AccentColor"))
                    Text(title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color( "TextColor"))
                }
                Spacer()
                Text(count)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color( "TextColor"))
            }
            .frame(maxWidth: .infinity, minHeight: 100)
        }
        .padding(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 20))
        .listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        .listRowBackground(Color.clear).background(Color("SecondaryColor"))
        .cornerRadius(10)
    }
}

#Preview {
    AdminView()
}
