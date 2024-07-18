import SwiftUI

struct NewHome: View {
    var body: some View {
        TabView {
           
            NewAdminHome()
            .tabItem {
                Image(systemName: "chart.bar.xaxis")
                Text("Analytics")
            }
            
            
            // navigation view is added bcoz of hospital adding functionality was not showing
            NavigationView {
                HospitalView()
            }
            .tabItem {
                Image(systemName: "building.2")
                Text("Hospitals")
            }
        }
    }
}

#Preview {
    NewHome()
}
