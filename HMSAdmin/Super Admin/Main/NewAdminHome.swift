import SwiftUI
import Charts
import FirebaseAuth

struct NewAdminHome: View {
    @State private var selectedRange: TimeRange = .oneDay
    @State private var chartData: [DataPoint] = generateData(for: .oneDay)
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
   
   // @State private var selectedCategory: Category = .branches
    @State private var timePeriod: TimePeriod = .day
    @State private var pieSelection: Double?
    
    // Sample data for branch cards
    let branchItems = [
        "New Delhi", "Mumbai", "Bengaluru", "Ahmedabad"
    ]
    
    let hospitalName = "Max Hospital"
    
    
    let baseColor = Color(hex: "006666")
    let colorScheme: [Color] = [
        Color(hex: "006666"),
        Color(hex: "007777"),
        Color(hex: "00AAAA"),
        Color(hex: "00BBBB"),
        Color(hex: "00DDDD"),
        Color(hex: "00EEEE"),
        Color(hex: "00FFFF")
    ]
    
    var departmentRevenue: [Revenue] {
        switch timePeriod {
        case .day:
            return departmentRevenueDay
        case .week:
            return departmentRevenueWeek
        case .month:
            return departmentRevenueMonth
        case .year:
            return departmentRevenueYear
        }
    }
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Analytics")
                            .font(.largeTitle)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Button(action: {
                           logout()
                            print("Logout button tapped")
                        }) {
                            Image(systemName: "power")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(10)
                        //.background(Color(UIColor.systemGray6))
                        .clipShape(Circle())
                        .shadow(color: Color.gray.opacity(0.4), radius: 3, x: 0, y: 2)


                    }
                    .padding(.bottom,20)
                    .padding(.trailing,8)
                    
                    
                    HStack{
                        HStack {
                            Text("Profit:")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("+5k")
                                .font(.title3)
                        }
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 0.8)
                            .overlay(
                                Text("All Branches")
                                    .padding(8)
                                    .foregroundColor(.gray)
                            )
                            .frame(maxWidth: 120, maxHeight: 25)

                        
                    }
                    .padding(.horizontal,5)
                    .padding(.top,20)
                    .padding(.bottom)
                    
                    
                    // line chart
                    Chart {
                                       ForEach(chartData) { dataPoint in
                                           AreaMark(
                                               x: .value("Date", dataPoint.date),
                                               y: .value("Value", dataPoint.value)
                                           )
                                           .foregroundStyle(Color(hex: "00AAAA").opacity(0.3))
                                           
                                           LineMark(
                                               x: .value("Date", dataPoint.date),
                                               y: .value("Value", dataPoint.value)
                                           )
                                           .foregroundStyle(Color(hex: "00AAAA"))
                                       }
                                   }
                                   .frame(height: 180)
                                   .padding(.horizontal, 10)
                                  // .padding(.top, 20)
                                   .chartForegroundStyleScale(range: colorScheme)
                    
                    Picker("Time Range", selection: $selectedRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue)
                                .tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal,40)
                    .padding(.top,20)
                    .onChange(of: selectedRange) { newRange in
                        chartData = generateData(for: newRange)
                    }
                    
                    

                    
                    HStack {
                        Text("Departments")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(alignment: .leading)
                           
                            .padding(.horizontal,5)
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 0.8)
                            .overlay(
                                Text("Top Performers")
                                    .padding(8)
                                    .foregroundColor(.gray)
                            )
                            .frame(maxWidth: 150,maxHeight: 25)
                        
                    }
                    .padding(.top,50)
                    .padding(.bottom,15)
                    
                   
                    
                    
                    
                    // graph for branches revenue
                    VStack(alignment: .leading) {

                        
                        Chart {
                            ForEach(departmentRevenue) { revenue in
                                SectorMark(
                                    angle: .value("Revenue", revenue.revenue),
                                    innerRadius: .ratio(0.55),
                                    angularInset: 1
                                )
                                .foregroundStyle(by: .value("Department", revenue.name))
                                .opacity(pieSelection == nil ? 1 : (pieSelection == revenue.revenue ? 1 : 0.4))
                            }
                        }
                        .chartLegend(position: .trailing, alignment: .leading, spacing: -25)
                        .chartForegroundStyleScale(range: colorScheme)
                        .frame(height: 150)
                        
                        Picker("", selection: $timePeriod) {
                            ForEach(TimePeriod.allCases, id: \.rawValue) { type in
                                Text(type.rawValue)
                                    .tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .frame(width: 300)
                        .padding(.top, 30)
                        .padding(.horizontal)
                    }
                    .padding(15)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1.5)
                    
                    
                    //Spacer()
                    
                    Text("Branches")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal,5)
                        .padding(.top,50
                    )
                    // Grid of branch cards
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 30)
                    {
                        ForEach(branchItems, id: \.self) { branch in
                            NavigationLink(destination: BranchAnalytics(HospitalName: hospitalName, BranchName: branch)) {
                                BranchCardView(branchName: branch)
                            }
                            
                        }
                    }
                   
                   
              
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    
    // Function to handle logout
      func logout() {
          do {
              try Auth.auth().signOut()
              isLoggedIn = false
              navigateToScreen(screen: Authentication())
          } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
          }
      }


    // Function to navigate to different screens
     func navigateToScreen<Screen: View>(screen: Screen) {
         if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
             if let window = windowScene.windows.first {
                 window.rootViewController = UIHostingController(rootView: screen)
                 window.makeKeyAndVisible()
             }
         }
     }
}

// Example of a branch card view
struct BranchCardView: View {
    let branchName: String
    
    var body: some View {
        
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black,lineWidth: 0.4)
                .overlay(
                    //VStack(alignment: .leading) {
                        HStack(spacing: -5) {
                            Text(branchName)
                                .font(.title3)
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                                
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(hex: "006666"))

                            // Add more content as needed for each branch card
                        }.padding(.horizontal,10)
                    //}
                )
                .frame(width: 160)
                .frame(height: 70)
                .padding(8)
          
    }
}

enum TimeRange: String, CaseIterable {
    case oneDay = "1D"
    case oneWeek = "1W"
    case oneYear = "1Y"
    case max = "Max"
}

//enum Category: String, CaseIterable {
//    case branches = "Branches"
//    case departments = "Departments"
//}

struct DataPoint: Identifiable {
    var id = UUID()
    var date: Date
    var value: Double
}

func generateData(for range: TimeRange) -> [DataPoint] {
    let now = Date()
    switch range {
    case .oneDay:
        return [
            DataPoint(date: now.addingTimeInterval(-3600 * 24), value: 10),
            DataPoint(date: now.addingTimeInterval(-3600 * 18), value: 30),
            DataPoint(date: now.addingTimeInterval(-3600 * 12), value: 25),
            DataPoint(date: now.addingTimeInterval(-3600 * 6), value: 40),
            DataPoint(date: now, value: 20)
        ]
    case .oneWeek:
        return [
            DataPoint(date: now.addingTimeInterval(-86400 * 6), value: 15),
            DataPoint(date: now.addingTimeInterval(-86400 * 5), value: 25),
            DataPoint(date: now.addingTimeInterval(-86400 * 4), value: 30),
            DataPoint(date: now.addingTimeInterval(-86400 * 3), value: 10),
            DataPoint(date: now.addingTimeInterval(-86400 * 2), value: 20),
            DataPoint(date: now.addingTimeInterval(-86400), value: 35),
            DataPoint(date: now, value: 25)
        ]
    case .oneYear:
        return (1...12).map { month in
            DataPoint(date: Calendar.current.date(byAdding: .month, value: -month, to: now)!, value: Double.random(in: 10...50))
        }
    case .max:
        return (1...5).map { year in
            DataPoint(date: Calendar.current.date(byAdding: .year, value: -year, to: now)!, value: Double.random(in: 10...50))
        }
    }
}

#if DEBUG
struct NewAdminHome_Previews: PreviewProvider {
    static var previews: some View {
        NewAdminHome()
    }
}
#endif
