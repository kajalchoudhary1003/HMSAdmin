import SwiftUI

struct ShowOffersView: View {
    @State private var showAddOfferView = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Add Offers")
                        .font(.system(size: 32, weight: .bold))
                    Spacer()
                    Button(action: {
                        showAddOfferView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title)
                    }
                    .sheet(isPresented: $showAddOfferView) {
                        AddOfferView()
                    }
                }
                
                .padding()

                Spacer() // This pushes the content to the top
            }
            .background(Color.customBackground)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
    }
}

struct ShowOffersView_Previews: PreviewProvider {
    static var previews: some View {
        ShowOffersView()
    }
}
