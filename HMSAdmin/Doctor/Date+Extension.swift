//
//  Date+Extension.swift
//  HMSAdmin
//
//  Created by Kajal Choudhary on 04/07/24.
//

import SwiftUI

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
