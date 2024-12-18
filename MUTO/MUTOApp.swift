//
//  MUTOApp.swift
//  MUTO
//
//  Created by Burhan Raza on 11/12/24.
//

import SwiftUI
import UserNotifications

@main
struct MUTOApp: App {
    init() {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}
