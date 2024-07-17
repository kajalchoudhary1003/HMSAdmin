//
//  NewHome.swift
//  HMSAdmin
//
//  Created by Nakshatra Verma on 15/07/24.
//

import SwiftUI

struct NewHome: View {
    var body: some View {
          TabView {
              NewAdminHome()
                  .tabItem {
                      Image(systemName: "chart.bar.xaxis")
                      Text("Analytics")
                  }
              
              HospitalView()
                  .tabItem {
                      Image(systemName: "building.2")
                      Text("Hospitals")
                  }
          }
      }
}




struct AnalyticsView: View {
    var body: some View {
        Text("Analytics Content")
            .font(.largeTitle)
            .padding()
    }
}




#Preview {
    NewHome()
}
