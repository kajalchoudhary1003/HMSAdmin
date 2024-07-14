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

