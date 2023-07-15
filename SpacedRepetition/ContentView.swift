//
//  ContentView.swift
//  SpacedRepetition
//
//  Created by heonrim on 5/1/23.
//

import SwiftUI

// 任務結構，每個任務都具有唯一的識別符
struct Task: Identifiable {
    // 以下是他的屬性
    let id = UUID()
    var title: String
    var description: String
    var nextReviewDate: Date
}

// 任務存儲類別，用於存儲和管理任務列表
class TaskStore: ObservableObject {
    // 具有一個已發佈的 tasks 屬性，該屬性存儲任務的數組
    @Published var tasks: [Task] = [
        Task(title: "英文", description: "背L2單字", nextReviewDate: Date()),
        Task(title: "國文", description: "燭之武退秦師", nextReviewDate: Date()),
        Task(title: "歷史", description: "中世紀歐洲", nextReviewDate: Date())
    ]
    // 根據日期返回相應的任務列表
    func tasksForDate(_ date: Date) -> [Task] {
        return tasks.filter { Calendar.current.isDate($0.nextReviewDate, inSameDayAs: date) }
    }
    
}

struct ContentView: View {
    // 用於觀察任務存儲的屬性，當任務存儲的 tasks 屬性發生變化時，將自動刷新視圖。
    @ObservedObject var taskStore = TaskStore()
    
    var body: some View {
        NavigationView {
            // 這是一個 List 的視圖，用於顯示一個項目的列表。$taskStore.tasks 表示綁定到 taskStore 中的 tasks 屬性，使得列表可以動態地反映 tasks 屬性的變化。$task 是一個綁定到 task 的綁定值，表示列表中的每一個項目。
            List($taskStore.tasks) { $task in
                // 這是一個導航連結，用於導航到指定的目標視圖。當用戶點擊列表中的項目時，將導航到 TaskDetailView 視圖，並將相應的 task 傳遞給目標視圖。
                NavigationLink(destination: TaskDetailView(task: task)) {
                    // alignment 參數設置對齊方式，spacing 參數設置子視圖之間的間距
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
    
    // 用於將日期格式化為指定的字符串格式
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

// 右上角 新增的button
struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var taskStore: TaskStore
    @State var title = ""
    @State var description = ""
    @State var nextReviewDate = Date()
    
    var body: some View {
        Form {
            // 此部分為欄位上面小小的字
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
        // 一個隱藏的分隔線
        .listStyle(PlainListStyle())
        .navigationBarTitle("新增任務")
        // ！！！！！
        // 我需要把上面的那些欄位透過這個按鈕寫進資料庫裡面
        .navigationBarItems(
            trailing: Button("完成") {
                // 建立一個 Task 物件，傳入使用者輸入的 title、description 和 nextReviewDate。
                let task = Task(title: title, description: description, nextReviewDate: nextReviewDate)
                // 將新建立的 task 加入到 taskStore 的 tasks 陣列中。
                // 這行程式碼試圖將 task 強制轉換為 Task 類型，然後再將其添加到 taskStore.tasks 陣列中。然而，由於 task 已經是 Task 類型，所以這個強制轉換是多餘的，並不會產生任何效果。
                //                taskStore.tasks.append(task as! Task)
                taskStore.tasks.append(task )
                // ????
                presentationMode.wrappedValue.dismiss()
            }
            // 如果 title 為空，按鈕會被禁用，即無法點擊。
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
