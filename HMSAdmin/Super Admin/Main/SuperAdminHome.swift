import SwiftUI
import Charts

struct SuperAdminHome : View {
    
    @State private var timePeriod: TimePeriod = .day
    @State private var barSelection: String?
    @State private var pieSelection: Double?
    @State private var selectedDepartment = "OPD"
    @State private var selectedPage = 0

    let baseColor = Color.customPrimary
    let colorScheme: [Color] = [
        Color.customPrimary,
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
        
        
        NavigationView {
            ZStack {
                
                Color("BackgroundColor").ignoresSafeArea(.all)
                
                VStack(alignment: .leading) {
                    
                    Text("Analytics")
                        .frame(alignment: .leading)
                        .font(.largeTitle)
                        .fontWeight(.semibold).padding(.leading,10)
                    
                    
                    VStack(alignment: .leading) {
                        Text("Revenue")
                            .fontWeight(.regular)
                            .font(.headline).padding(.horizontal,10)
                        
                        VStack{
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
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .padding(10)
                        .padding(.horizontal)
                        .background(Color("SecondaryColor"))
                        .cornerRadius(10)
                    }
                    .padding(.vertical,10)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(selectedDepartment) Earnings")
                                .fontWeight(.regular)
                                .font(.headline)
                            
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
                        .frame(height: 180)
                        .padding()
                        .background(Color("SecondaryColor"))
                        .cornerRadius(10)
                    }
                    .padding(.bottom)
                    
                    
    //                NavigationLink(destination: HospitalView()){
                    NavigationLink(destination: HospitalView()) {
                        HStack {
                                Image(systemName: "cross.case.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color("AccentColor"))
                                    .padding(8)
                                    .cornerRadius(10)
                                
                                Text("Hospitals")
                                    .font(.title2)
                                
                                Spacer()
                                
                                Text("03")
                                    .foregroundColor(Color("AccentColor"))
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(Color("AccentColor"))
                                    .padding(8)
                                    .cornerRadius(10)
                            }
                            .padding()
        //                }
                        
                        .background(Color("SecondaryColor"))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }.background(Color.customBackground)
        }
    }
}

// chart popover view
@ViewBuilder
func ChartPopOverView(_ revenue: Double, _ month: String) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text("Revenue")
            .font(.headline)
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

#Preview {
    SuperAdminHome()
}
