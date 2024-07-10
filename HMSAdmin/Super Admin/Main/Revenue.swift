import SwiftUI

struct Revenue: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let revenue: Double
    
    static func == (lhs: Revenue, rhs: Revenue) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.revenue == rhs.revenue
    }
}

//enum TimePeriod: String, CaseIterable {
//    case day = "Day"
//    case week = "Week"
//    case year = "Year"
//}

var departmentRevenueDay: [Revenue] = [
    .init(name: "OPD", revenue: 345),
    .init(name: "Cardio", revenue: 245),
    .init(name: "Dental", revenue: 125),
    .init(name: "Physio", revenue: 45)
]

var departmentRevenueWeek: [Revenue] = [
    .init(name: "OPD", revenue: 2450),
    .init(name: "Cardio", revenue: 1750),
    .init(name: "Dental", revenue: 850),
    .init(name: "Physio", revenue: 450)
]

var departmentRevenueMonth: [Revenue] = [
    .init(name: "OPD", revenue: 2450),
    .init(name: "Cardio", revenue: 1750),
    .init(name: "Dental", revenue: 850),
    .init(name: "Physio", revenue: 450)
]

var departmentRevenueYear: [Revenue] = [
    .init(name: "OPD", revenue: 34500),
    .init(name: "Cardio", revenue: 24500),
    .init(name: "Dental", revenue: 12500),
    .init(name: "Physio", revenue: 4500)
]

var opdRevenue: [ParticularRevenue] = [
    .init(revenue: 2500, date: .createDate(1, 1, 2024)),
    .init(revenue: 1500, date: .createDate(1, 2, 2024)),
    .init(revenue: 2800, date: .createDate(1, 3, 2024)),
    .init(revenue: 3500, date: .createDate(1, 4, 2024))
]

var cardioRevenue: [ParticularRevenue] = [
    .init(revenue: 2000, date: .createDate(1, 1, 2024)),
    .init(revenue: 1000, date: .createDate(1, 2, 2024)),
    .init(revenue: 2300, date: .createDate(1, 3, 2024)),
    .init(revenue: 3000, date: .createDate(1, 4, 2024))
]

var dentalRevenue: [ParticularRevenue] = [
    .init(revenue: 1800, date: .createDate(1, 1, 2024)),
    .init(revenue: 900, date: .createDate(1, 2, 2024)),
    .init(revenue: 2100, date: .createDate(1, 3, 2024)),
    .init(revenue: 2800, date: .createDate(1, 4, 2024))
]

var physioRevenue: [ParticularRevenue] = [
    .init(revenue: 1500, date: .createDate(1, 1, 2024)),
    .init(revenue: 800, date: .createDate(1, 2, 2024)),
    .init(revenue: 1900, date: .createDate(1, 3, 2024)),
    .init(revenue: 2500, date: .createDate(1, 4, 2024))
]

struct ParticularRevenue: Identifiable, Equatable {
    let id = UUID()
    let revenue: Double
    var date: Date
    
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: date)
    }
    
    static func == (lhs: ParticularRevenue, rhs: ParticularRevenue) -> Bool {
        return lhs.id == rhs.id && lhs.revenue == rhs.revenue
    }
}

extension [ParticularRevenue] {
    func findRevenue(_ on: String) -> Double? {
        if let revenue = self.first(where: { $0.month == on }) {
            return revenue.revenue
        }
        return nil
    }
    
    func index(_ on: String) -> Int {
        if let index = self.firstIndex(where: { $0.month == on }) {
            return index
        }
        return 0
    }
}

extension Date {
    static func createDate(_ day: Int, _ month: Int, _ year: Int) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        
        let calendar = Calendar.current
        let date = calendar.date(from: components) ?? .init()
        
        return date
    }
}
