import SwiftUI
import Charts

struct BranchAnalytics: View {
    @State private var timePeriod: TimePeriod = .day
    @State private var pieSelection: Double?
    
    @State var HospitalName : String
    @State var BranchName : String
    
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
    
    var body: some View {
        VStack(alignment: .leading) {
            
            
            
           
            VStack(alignment: .leading) {
                Text(HospitalName)   // replace with hospital Name defined above
                    .font(.title2)
                    .fontWeight(.semibold)
                    .textCase(.uppercase)
                   
                   
                Text(BranchName)      // replace with branch Name defined above
                    .font(.title3)
                    .fontWeight(.regular)
                
            }
            .padding(.top)
            
            
          
            Text("Department Revenue")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.top,20)
            
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
            
            
            
            Text("Other Info")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.top,30)
            
            VStack(alignment: .leading, spacing: 10) {
                
                ProfileRow2(title: "Total Doctors", value: "96")
                Divider()
                ProfileRow2(title: "Registered Patients", value:  "5654")
                Divider()
                ProfileRow2(title: "Total Staff", value: "145")
                Divider()
                ProfileRow2(title: "Phone Number", value: "0122-453478")
                // Placeholder for experience
            }
            .padding()
            .background(Color(.white))
            .cornerRadius(10)
            .shadow(radius: 1.5)
            .frame(minWidth: 340)
          
            Spacer() // Pushes the text to the top
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()// Align content to top left
        
        
        
    }
}

struct ProfileRow2: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
                .font(.body)
        }
    }
}

#Preview {
    BranchAnalytics(HospitalName: "aiims", BranchName: "delhi")
}
