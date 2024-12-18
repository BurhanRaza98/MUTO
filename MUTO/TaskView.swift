//
//  TaskView.swift
//  MUTO
//
//  Created by Burhan Raza on 11/12/24.
//


import SwiftUI
import UIKit

struct TaskView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showingAddTask = false
    @State private var showingCompletedTasks = false
    @State private var showToast = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.edgesIgnoringSafeArea(.all)
                
                List {
                    ForEach(viewModel.activeTasks) { task in
                        TaskRowView(task: task, viewModel: viewModel, onTaskCompleted: {
                            showToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showToast = false
                            }
                        })
                    }
                    .onDelete(perform: viewModel.deleteTask)
                }
                .navigationTitle("Tasks")
                .navigationBarItems(trailing: Button(action: {
                    showingAddTask = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(Color.appForeground)
                })
                
                // Floating button for completed tasks
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingCompletedTasks = true
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.appAccent)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                        .padding(.bottom, 60)
                    }
                }
                
                // Toast message
                if showToast {
                    VStack {
                        Spacer()
                        ToastView(message: "Task completed! Tap the completed tasks button to view.")
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: showToast)
                }
            }
            .accentColor(Color.appForeground)
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingCompletedTasks) {
            CompletedTasksView(viewModel: viewModel)
        }
    }
}

struct TaskRowView: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    @State private var showTaskDetail = false
    let onTaskCompleted: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(task.color.color)
                        .frame(width: 12, height: 12)
                    
                    Text(task.title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.toggleTaskCompletion(task)
                        if task.isCompleted {
                            onTaskCompleted()
                        }
                    }) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green : .gray)
                            .font(.system(size: 20))
                    }
                }
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                if let image = task.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 100)
                        .cornerRadius(8)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .padding(.vertical, 4)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .onTapGesture {
                showTaskDetail = true
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
        .sheet(isPresented: $showTaskDetail) {
            TaskDetailView(task: task, viewModel: viewModel)
        }
    }
}

struct TaskDetailView: View {
    let task: Task
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskViewModel
    @State private var editedTitle: String
    @State private var editedDescription: String
    @State private var isEditing = false
    
    init(task: Task, viewModel: TaskViewModel) {
        self.task = task
        self.viewModel = viewModel
        _editedTitle = State(initialValue: task.title)
        _editedDescription = State(initialValue: task.description)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let image = task.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.gray.opacity(0.1))
                            )
                            .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        if isEditing {
                            TextField("Title", text: $editedTitle)
                                .font(.title)
                                .bold()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextEditor(text: $editedDescription)
                                .frame(minHeight: 100)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                        } else {
                            Text(editedTitle)
                                .font(.title)
                                .bold()
                            
                            Text(editedDescription)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        
                        if let reminderDate = task.reminderDate {
                            HStack {
                                Image(systemName: "bell.fill")
                                Text("Reminder set for: ")
                                Text(reminderDate, style: .date)
                                Text(reminderDate, style: .time)
                            }
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.gray.opacity(0.1))
            .navigationBarItems(
                leading: Button(isEditing ? "Cancel" : "Edit") {
                    if isEditing {
                        // Reset to original values
                        editedTitle = task.title
                        editedDescription = task.description
                    }
                    isEditing.toggle()
                },
                trailing: Group {
                    if isEditing {
                        Button("Save") {
                            viewModel.updateTask(task, newTitle: editedTitle, newDescription: editedDescription)
                            isEditing = false
                        }
                        .disabled(editedTitle.isEmpty)
                    } else {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            )
        }
    }
}

struct CompletedTasksView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.completedTasks) { task in
                    TaskRowView(task: task, viewModel: viewModel) {
                        // Empty closure since we don't need toast for completed tasks view
                    }
                }
            }
            .navigationTitle("Completed Tasks")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedColor: TaskColor = .blue
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var reminderDate = Date()
    @State private var isReminderEnabled = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Color Code")) {
                    HStack(spacing: 20) {
                        ForEach(TaskColor.allCases, id: \.self) { color in
                            Circle()
                                .fill(color.color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(color == selectedColor ? Color.black : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
                
                Section(header: Text("Image")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Text(selectedImage == nil ? "Add Image" : "Change Image")
                    }
                }
                
                Section(header: Text("Reminder")) {
                    Toggle("Set Reminder", isOn: $isReminderEnabled)
                    
                    if isReminderEnabled {
                        DatePicker(
                            "Reminder Date",
                            selection: $reminderDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    viewModel.addTask(
                        title: title,
                        description: description,
                        color: selectedColor,
                        image: selectedImage,
                        reminderDate: isReminderEnabled ? reminderDate : nil
                    )
                    dismiss()
                }
                .disabled(title.isEmpty)
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}
