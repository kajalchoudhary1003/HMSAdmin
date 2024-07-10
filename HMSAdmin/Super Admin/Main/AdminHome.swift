import SwiftUI
import Charts

//enum TimePeriod: String, CaseIterable {
//    case day = "Day"
//    case week = "Week"
//    case month = "Month"
//    case year = "Year"
//}

struct AdminHome : View {
    
    @State private var timePeriod: TimePeriod = .day
    @State private var barSelection: String?
    @State private var pieSelection: Double?
    @State private var selectedDepartment = "OPD"
    @State private var selectedPage = 0

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
    
    var selectedDepartmentRevenue: [ParticularRevenue] {
        switch selectedDepartment {
        case "OPD":
            return opdRevenue
        case "Cardio":
            return cardioRevenue
        case "Dental":
            return dentalRevenue
        case "Physio":
            return physioRevenue
        default:
            return opdRevenue
        }
    }
    
    var body: some View {
        ZStack {
            Color("bgColor").ignoresSafeArea(.all)
            
            VStack(alignment: .leading) {
                
                Text("Analytics")
                    .frame(alignment: .leading)
                    .font(.largeTitle)
                    .fontWeight(.semibold).padding(.leading,10)
                
                
                VStack(alignment: .leading) {
                    Text("Revenue")
                        .fontWeight(.regular)
                        .font(.title2)
                    
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
                    .chartLegend(position: .leading, alignment: .center, spacing: 45)
                    .chartForegroundStyleScale(range: colorScheme)
                    .frame(height: 150, alignment: .trailing)
                    
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
                .shadow(radius: 5)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(selectedDepartment) Earnings")
                            .fontWeight(.regular)
                            .font(.title3)
                        
                        Spacer()
                        
                        Menu {
                            Button(action: { selectedDepartment = "OPD" }) {
                                Text("OPD")
                            }
                            Button(action: { selectedDepartment = "Cardio" }) {
                                Text("Cardio")
                            }
                            Button(action: { selectedDepartment = "Dental" }) {
                                Text("Dental")
                            }
                            Button(action: { selectedDepartment = "Physio" }) {
                                Text("Physio")
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.title3)
                        }
                    }
                    .padding(.top,20)
                    .padding(.horizontal,10)
                    
                    Chart {
                        ForEach(selectedDepartmentRevenue) { revenue in
                            BarMark(
                                x: .value("Month", revenue.month),
                                y: .value("Revenue", revenue.revenue)
                            )
                            .foregroundStyle(by: .value("Month", revenue.month))
                        }
                        
                        if let barSelection {
                            RuleMark(x: .value("Month", barSelection))
                                .foregroundStyle(.gray.opacity(0.35))
                                .offset(yStart: -10)
                                .annotation(
                                    position: .top,
                                    spacing: 0,
                                    overflowResolution: .init(x: .fit, y: .fit)
                                ) {
                                    if let revenue = selectedDepartmentRevenue.findRevenue(barSelection) {
                                        ChartPopOverView(revenue, barSelection)
                                    }
                                }
                                .zIndex(-10)
                        }
                    }
                    .chartXSelection(value: $barSelection)
                    .chartAngleSelection(value: $pieSelection)
                    .chartLegend(position: .leading, alignment: .center, spacing: 45)
                    .chartForegroundStyleScale(range: colorScheme)
                    .frame(height: 150)
                    .padding( 10)
                }
                
                
                
                // added navigation to hospitalView()
                NavigationLink(destination: HospitalView()){
                    HStack {
                        Image(systemName: "plus.square.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color("appColor"))
                            .padding(8)
                            .cornerRadius(8)
                        
                        Text("Hospitals")
                            .font(.title2)
                        
                        Spacer()
                        
                        Text("03")
                            .foregroundColor(Color("appColor"))
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                            .foregroundColor(Color("appColor"))
                            .padding(8)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                
                
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 4)
            }
            .padding()
        }
    }
}

// chart popover view
@ViewBuilder
func ChartPopOverView(_ revenue: Double, _ month: String) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text("Revenue")
            .font(.title3)
            .foregroundStyle(.gray)
        
        HStack(spacing: 4) {
            Text(String(format: "%.0f", revenue))
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(month)
                .font(.title3)
                .textScale(.secondary)
        }
    }
    .padding(.all)
    .background(Color("PopupColor").opacity(1), in: .rect(cornerRadius: 8))
    .frame(maxWidth: .infinity, alignment: .center)
}

// Extension to create Color from hex string
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (1, 1, 1, 0)
//        }
//
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}

#Preview {
    AdminHome()
}
