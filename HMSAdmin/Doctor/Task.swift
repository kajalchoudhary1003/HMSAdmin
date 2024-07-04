//
//  Task.swift
//  HMSAdmin
//
//  Created by Kajal Choudhary on 04/07/24.
//

import SwiftUI

extension Date{
    static func updateHour(_ value: Int) -> Date{
        let calendar = Calendar.current
        return calendar.date(byAdding: .hour, value: value, to: .init()) ?? .init()
    }
}

