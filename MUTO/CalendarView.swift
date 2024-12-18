//
//  CalendarView.swift
//  MUTO
//
//  Created by Burhan Raza on 11/12/24.
//


import SwiftUI
import EventKit

// MARK: - Calendar Manager
class CalendarManager: ObservableObject {
    @Published var isAuthorized = false
    @Published var events: [EKEvent] = []
    @Published var selectedDate = Date()
    let eventStore = EKEventStore()
    
    init() {
        checkInitialAuthorizationStatus()
    }
    
    private func checkInitialAuthorizationStatus() {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.fetchEvents(for: self?.selectedDate ?? Date())
                    }
                    if let error = error {
                        print("Error checking calendar access: \(error)")
                    }
                }
            }
        } else {
            let status = EKEventStore.authorizationStatus(for: .event)
            DispatchQueue.main.async {
                self.isAuthorized = status == .authorized
                if self.isAuthorized {
                    self.fetchEvents(for: self.selectedDate)
                }
            }
        }
    }
    
    func requestAccess() {
        if #available(iOS 17.0, *) {
            print("Requesting calendar access for iOS 17+")
            eventStore.requestFullAccessToEvents { [weak self] granted, error in
                print("Calendar access response - Granted: \(granted)")
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.fetchEvents(for: self?.selectedDate ?? Date())
                    }
                    if let error = error {
                        print("Calendar access error: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            print("Requesting calendar access for iOS 16 and below")
            eventStore.requestAccess(to: .event) { [weak self] granted, error in
                print("Calendar access response - Granted: \(granted)")
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.fetchEvents(for: self?.selectedDate ?? Date())
                    }
                    if let error = error {
                        print("Calendar access error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func fetchEvents(for date: Date) {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil
        )
        
        DispatchQueue.main.async {
            self.events = self.eventStore.events(matching: predicate)
                .sorted { $0.startDate < $1.startDate }
        }
    }
    
    func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Calendar View
struct CalendarView: View {
    @StateObject private var calendarManager = CalendarManager()
    @State private var showingDatePicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                if calendarManager.isAuthorized {
                    VStack {
                        // Date selector
                        HStack {
                            Text(calendarManager.dateString(calendarManager.selectedDate))
                                .font(.headline)
                            
                            Button(action: {
                                showingDatePicker.toggle()
                            }) {
                                Image(systemName: "calendar")
                                    .foregroundColor(Color.appForeground)
                            }
                        }
                        .padding()
                        
                        if showingDatePicker {
                            DatePicker(
                                "Select Date",
                                selection: $calendarManager.selectedDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .onChange(of: calendarManager.selectedDate) { _, newDate in
                                calendarManager.fetchEvents(for: newDate)
                            }
                            .padding()
                        }
                        
                        // Events list
                        List {
                            ForEach(calendarManager.events, id: \.eventIdentifier) { event in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(event.title)
                                        .font(.headline)
                                        .foregroundColor(Color.appForeground)
                                    
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundColor(Color.appAccent)
                                        Text("\(calendarManager.timeString(event.startDate)) - \(calendarManager.timeString(event.endDate))")
                                            .font(.subheadline)
                                    }
                                    
                                    if let location = event.location, !location.isEmpty {
                                        HStack {
                                            Image(systemName: "location")
                                                .foregroundColor(Color.appAccent)
                                            Text(location)
                                                .font(.subheadline)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Text("Calendar Access Required")
                            .font(.title)
                            .bold()
                        
                        Text("Please grant access to your calendar to view and manage your events")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Grant Access") {
                            print("Grant Access button tapped")
                            calendarManager.requestAccess()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.appAccent)
                        .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Calendar")
            .background(Color.appBackground)
        }
    }
}

