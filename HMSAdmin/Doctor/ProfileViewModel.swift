//
//  ProfileViewModel.swift
//  HMSAdmin
//
//  Created by Aarrllo on 11/07/24.
//


import Foundation

class ProfileViewModel: ObservableObject {
    @Published var doctor: Doctor?
    
    func fetchCurrentDoctor() {
        if let currentDoctor = DataController.shared.getCurrentDoctor() {
            self.doctor = currentDoctor
        }
    }
}
