//
//  loginView.swift
//  SpacedRepetition
//
//  Created by 呂沄 on 2023/7/15.
//

import SwiftUI

struct loginView: View {
    @State private var userName = ""
    @State private var password = ""
    @State private var errorEmpty = ""
    @State private var errorMessage = ""
    //    @State private var getUsername = ""
    @State private var isLoggedIn = false
    
    struct UserData: Decodable {
        var id: String
        var userName: String
        var message: String
    }

    var body: some View {
        NavigationView {
            if (!isLoggedIn) {
                VStack {
                    HStack {
                        Text("帳號：")
                        TextField("email", text: $userName)
                    }
                    HStack {
                        Text("密碼：")
                        TextField("password",text: $password)
                    }
                    Button {
                        login()
                    } label: {
                        Text("登入")
                    }
                    //                    Text(errorEmpty)
                    //                        .foregroundColor(.red)
                    // 帳號密碼在資料庫吳資料時
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            } else {
                MainView()
            }
        }
        .navigationTitle("登入畫面")
    }
    
    private func login() {
        
        class URLSessionSingleton {
            static let shared = URLSessionSingleton()
            let session: URLSession
            private init() {
                let config = URLSessionConfiguration.default
                config.httpCookieStorage = HTTPCookieStorage.shared
                config.httpCookieAcceptPolicy = .always
                session = URLSession(configuration: config)
            }
        }
        
        guard !userName.isEmpty && !password.isEmpty else {
            print("請確認帳號密碼都有輸入")
            //            errorEmpty = "請確認帳號密碼都有輸入"
            errorMessage = "請確認帳號密碼都有輸入"
            return
        }
        //        errorEmpty = ""
        errorMessage = ""
        let url = URL(string: "http://127.0.0.1:8888/account/login.php")!
        var request = URLRequest(url: url)
//        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "POST"
        let body = ["userName": userName, "password": password]
        let jsonData = try! JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
        URLSessionSingleton.shared.session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Connection error: \(error)")
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTP error: \(httpResponse.statusCode)")
            }
            else if let data = data{
                let decoder = JSONDecoder()
                do {
                    let userData = try decoder.decode(UserData.self, from: data)
                    if userData.message == "no such account" {
                        print("============== loginView ==============")
                        print(userData.message)
                        print("帳號或密碼輸入錯誤")
                        errorMessage = "帳號或密碼輸入錯誤"
                        print("============== loginView ==============")
                    } else {
                        print("============== loginView ==============")
                        print(userData)
                        print("使用者ID為：\(userData.id)")
                        print("使用者名稱為：\(userData.userName)")
                        print("============== loginView ==============")
                        isLoggedIn = true

                    }
                } catch {
                    print("解碼失敗：\(error)")
                }
            }
            // 測試
//            guard let data = data else {
//                print("No data returned from server.")
//                return
//            }
//            if let content = String(data: data, encoding: .utf8) {
//                print(content)
//            }
        }
        .resume()
    }
}

struct loginView_Previews: PreviewProvider {
    static var previews: some View {
        loginView()
    }
}
