//
//  Extensions.swift
//  HMSAdmin
//
//  Created by Ansh Kalra on 08/07/24.
//

import SwiftUI


// Initialize Color from hex string
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
    static let customBackground = Color("BackgroundColor")
       static let customPrimary = Color("AccentColor")
       static let customPremium = Color("PremiumColor")
}

extension Appointment {
    init?(from dictionary: [String: Any], id: String) {
        guard let patientID = dictionary["patientID"] as? String,
              let doctorID = dictionary["doctorID"] as? String,
              let date = dictionary["date"] as? TimeInterval,
              let timeSlotID = dictionary["timeSlotID"] as? String else {
            return nil
        }
        
        self.patientID = patientID
        self.doctorID = doctorID
        self.date = Date(timeIntervalSince1970: date)
        self.timeSlotID = timeSlotID
        self.id = id
    }
}

extension Date{
    static func updateHour(_ value: Int) -> Date{
        let calendar = Calendar.current
        return calendar.date(byAdding: .hour, value: value, to: .init()) ?? .init()
    }
}


extension Date{
    func format(_ format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    //checking whether date is today or not
    var isToday: Bool{
        return Calendar.current.isDateInToday(self)
    }
    
    func fetchWeek(_ date: Date = .init()) -> [WeekDay]{
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: date)
        
        var week : [WeekDay] = []
        let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        guard let startOfWeek = weekForDate?.start else{
            return []
        }
        
        (0..<7).forEach{
            index in
            if let weekDay = calendar.date(byAdding: .day, value: index,  to: startOfWeek){
                week.append(.init(date: weekDay))
            }
        }
        return week
    }
    
    //creating next week based on the last current week's date
    func createNextWeek () -> [WeekDay]{
        let calendar = Calendar.current
        let startOfLastDate = calendar.startOfDay(for: self)
        guard let nextDate = calendar.date(byAdding: .day, value: 1,  to: startOfLastDate) else{
            return []
        }
        return fetchWeek(nextDate)
    }
    
    struct WeekDay: Identifiable{
        var id: UUID = .init()
        var date: Date
    }
}

extension View{
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View{
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View{
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
    
    //checking two dates are same
    func isSameDate(_ date1: Date, _ date2: Date) -> Bool{
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}
