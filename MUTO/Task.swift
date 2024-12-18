//
//  Task.swift
//  MUTO
//
//  Created by Burhan Raza on 17/12/24.
//

import SwiftUI

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var color: TaskColor
    var image: UIImage?
    var isCompleted: Bool = false
    var reminderDate: Date?
}

enum TaskColor: CaseIterable {
    case red, orange, green, blue
    
    var color: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .green: return .green
        case .blue: return .blue
        }
    }
    
    var name: String {
        switch self {
        case .red: return "red"
        case .orange: return "orange"
        case .green: return "green"
        case .blue: return "blue"
        }
    }
}
