//
//  MainView.swift
//  GraduationProject
//
//  Created by heonrim on 4/24/23.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "house")
                    Text("首頁")
                }
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("行事曆")
                }
        }
    }
}

struct CalendarListView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
