import SwiftUI

struct AdminView: View {
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Analytics").font(.title2).fontWeight(.bold))  {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Bookings")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.init(hex: "#006666"))
                            Text("46")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color.init(hex: "#006666"))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.white))
                    .cornerRadius(22)
                }

                Section(header: Text("Hospital Data").font(.title2).fontWeight(.bold)) {
                    VStack {
                        HStack {
                            Image(systemName: "stethoscope")
                                    .font(.title)
                                    .foregroundColor(Color.init(hex: "#006666"))
                                VStack(alignment: .leading) {
                                    Text("Doctors")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.init(hex: "#006666"))
                                    Text("80")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.init(hex: "#006666"))
                                }
                            Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.init(hex: "#006666"))
                            }
                            .padding()
                            .background(Color(.white))
                            .cornerRadius(22)
                        }
                    
                }

                Section(header: Text("")) {
                    VStack {
                        HStack {
                            Image(systemName: "person.crop.circle")
                                .font(.title)
                                .foregroundColor(Color.init(hex: "#006666"))
                            VStack(alignment: .leading) {
                                Text("Staffs")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.init(hex: "#006666"))
                                Text("120")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.init(hex: "#006666"))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.init(hex: "#006666"))
                        }
                        .padding()
                        .background(Color(.white))
                        .cornerRadius(14)
                    }
                }

                Section(header: Text("")) {
                    VStack {
                        HStack {
                            Image(systemName: "gift")
                                .font(.title)
                                .foregroundColor(Color.init(hex: "#006666"))
                            VStack(alignment: .leading) {
                                Text("Offers")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.init(hex: "#006666"))
                                Text("05")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.init(hex: "#006666"))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.init(hex: "#006666"))
                        }
                        .padding()
                        .background(Color(.white))
                        .cornerRadius(14)
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Hi, Admin")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "person.crop.circle")
                }
            }
        }
    }
}

#Preview{
    AdminView()
}
