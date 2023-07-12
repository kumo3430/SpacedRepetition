//
//  CalendarView.swift
//  GraduationProject
//
//  Created by heonrim on 3/27/23.
//

import SwiftUI
import EventKit

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
}

struct CalendarView: View {
    @ObservedObject var taskStore = TaskStore()
    @State var selectedDate = Date()
    @State var showModal = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                VStack {
                    Text("行事曆")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 40)
                    
                    Divider().frame(height: 1).background(.gray.opacity(0.4))
                    
                    datePicker()
                    
                    Divider().frame(height: 1).background(.gray.opacity(0.4))
                    
                    eventList()
                    
                    Spacer()
                }
            }
        }
    }
    
    func datePicker() -> some View {
        DatePicker("Select Date", selection: $selectedDate,
                   in: ...Date.distantFuture, displayedComponents: .date)
            .datePickerStyle(.graphical)
    }
    
    func eventList() -> some View {
        let filteredTasks = taskStore.tasksForDate(selectedDate)
        
        return List(filteredTasks) { task in
            Text(task.title)
        }
    }
}


struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}

