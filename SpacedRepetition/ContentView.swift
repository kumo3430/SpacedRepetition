//
//  ContentView.swift
//  SpacedRepetition
//
//  Created by heonrim on 5/1/23.
//

import SwiftUI

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var nextReviewDate: Date
}

class TaskStore: ObservableObject {
    @Published var tasks: [Task] = [
        Task(title: "英文", description: "背L2單字", nextReviewDate: Date()),
        Task(title: "國文", description: "燭之武退秦師", nextReviewDate: Date()),
        Task(title: "歷史", description: "中世紀歐洲", nextReviewDate: Date())
    ]
    func tasksForDate(_ date: Date) -> [Task] {
        return tasks.filter { Calendar.current.isDate($0.nextReviewDate, inSameDayAs: date) }
    }

}

struct ContentView: View {
    @ObservedObject var taskStore = TaskStore()

    var body: some View {
        NavigationView {
            List($taskStore.tasks) { $task in
                NavigationLink(destination: TaskDetailView(task: task)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.headline)
                        Text(task.description)
                            .font(.subheadline)
                        Text("Start time: \(formattedDate(task.nextReviewDate))")
                            .font(.caption)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("間隔重複")
            .navigationBarItems(trailing:
                NavigationLink(destination: AddTaskView(taskStore: taskStore)) {
                    Image(systemName: "plus")
                }
            )
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var taskStore: TaskStore
    @State var title = ""
    @State var description = ""
    @State var nextReviewDate = Date()

    var body: some View {
        Form {
            Section(header: Text("標題").textCase(nil)) {
                TextField("輸入標題", text: $title)
            }
            Section(header: Text("內容").textCase(nil)) {
                TextField("輸入內容", text: $description)
            }
            Section(header: Text("開始時間").textCase(nil)) {
                DatePicker("選擇時間", selection: $nextReviewDate, displayedComponents: [.date, .hourAndMinute])
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("新增任務")
        .navigationBarItems(
            trailing: Button("完成") {
                let task = Task(title: title, description: description, nextReviewDate: nextReviewDate)
                taskStore.tasks.append(task as! Task)
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(title.isEmpty)
        )
    }
}

struct TaskDetailView: View {
    @State var task: Task
    @State var isReviewChecked: [Bool] = Array(repeating: false, count: 4)
    

    var nextReviewDates: [Date] {
        let intervals = [1, 3, 7, 14]
        return intervals.map { Calendar.current.date(byAdding: .day, value: $0, to: task.nextReviewDate)! }
    }

    var body: some View {
        Form {
            Section(header: Text("標題")) {
                TextField("輸入標題", text: $task.title)
            }
            Section(header: Text("內容")) {
                TextField("輸入內容", text: $task.description)
            }

            Section(header: Text("開始時間")) {
                DatePicker("", selection: $task.nextReviewDate, displayedComponents: [.date, .hourAndMinute])
                    .disabled(true)
            }

            Section(header: Text("下一次間隔重複")) {
                ForEach(0..<4) { index in
                    HStack {
                        Toggle(isOn: $isReviewChecked[index]) {
                            Text("第\(formattedInterval(index))天： \(formattedDate(nextReviewDates[index]))")
                        }
                    }
                }
            }
        }
        .navigationBarTitle("任務")
        .navigationBarItems(
            trailing: Button("完成", action: handleCompletion)
        )
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }

    func formattedInterval(_ index: Int) -> Int {
        let intervals = [1, 3, 7, 14]
        return intervals[index]
    }

    func handleCompletion() {
        // Handle the completion action here
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
