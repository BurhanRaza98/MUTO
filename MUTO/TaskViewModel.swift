//
//  TaskViewModel.swift
//  MUTO
//
//  Created by Burhan Raza on 17/12/24.
//

import Combine
import Foundation
import SwiftUI
import UIKit
import UserNotifications

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    
    init() {
        requestNotificationPermission()
    }
    
    var activeTasks: [Task] {
        tasks.filter { !$0.isCompleted }
    }
    
    var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func addTask(title: String, description: String, color: TaskColor, image: UIImage?, reminderDate: Date?) {
        let task = Task(title: title, description: description, color: color, image: image, reminderDate: reminderDate)
        tasks.append(task)
        
        if let reminderDate = reminderDate {
            scheduleNotification(for: task, at: reminderDate)
        }
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            
            // If task is completed, remove its notification
            if tasks[index].isCompleted {
                removeNotification(for: task)
                // Schedule a completion notification
                sendCompletionNotification(for: task)
            }
        }
    }
    
    private func scheduleNotification(for task: Task, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "Have you completed your \(task.color.name) task: \(task.title)?"
        content.sound = .default
        
        // Add color as a category for different actions
        content.categoryIdentifier = "TASK_REMINDER"
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        // Add actions to notification
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_TASK",
            title: "Mark as Complete",
            options: .foreground
        )
        
        let remindLaterAction = UNNotificationAction(
            identifier: "REMIND_LATER",
            title: "Remind in 30 minutes",
            options: .foreground
        )
        
        let category = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [completeAction, remindLaterAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func removeNotification(for task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
    
    private func sendCompletionNotification(for task: Task) {
        let content = UNMutableNotificationContent()
        content.title = "Task Completed"
        content.body = "\(task.title) has been moved to completed tasks"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "\(task.id.uuidString)-completion",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending completion notification: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        // Remove notifications for deleted tasks
        for index in offsets {
            let task = tasks[index]
            removeNotification(for: task)
        }
        tasks.remove(atOffsets: offsets)
    }
    
    func updateTask(_ task: Task, newTitle: String, newDescription: String) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].title = newTitle
            tasks[index].description = newDescription
        }
    }
}
