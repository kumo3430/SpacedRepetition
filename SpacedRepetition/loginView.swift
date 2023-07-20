//
//  loginView.swift
//  SpacedRepetition
//
//  Created by 呂沄 on 2023/7/15.
//

import SwiftUI
import SwiftSMTP
struct loginView: View {
    let roles = ["Login", "SignUp"]
    @State private var selectedIndex = 0
    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $selectedIndex) {
                    ForEach(Array(roles.enumerated()), id: \.offset) { index, role in
                        Text(role)
                    }
                } label: {
                    Text("選擇角色")
                }
                .pickerStyle(.segmented)
                if(selectedIndex == 0){
                    login()
                } else {
                    SignUp()
                }
            }
        }
        .navigationTitle("登入畫面")
    }
}


struct loginView_Previews: PreviewProvider {
    static var previews: some View {
        loginView()
    }
}

struct login: View {
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

struct SignUp: View {
    
    @State  var email = ""
    @State private var password = ""
    @State private var verify = 0
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("你的帳號：")
                    TextField("email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
                HStack {
                    Text("你的密碼：")
                    TextField("password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
                NavigationLink {
                    verifyRegister(verify: $verify,email: $email)
                        .onAppear() {
                            mix()
                        }
                } label: {
                    Text("註冊")
                }
                
            }
            .navigationTitle("註冊")
        }
    }
    public func mix() {
        DispatchQueue.global().async {
            Random()
            sendMail()
        }
    }
    
    private func Random() {
        self.verify = Int.random(in: 1..<99999999)
        print("隨機變數為：\(self.verify)")
    }
    
    public func sendMail() {
        
        let smtp = SMTP(
            hostname: "smtp.gmail.com",     // SMTP server address
            email: "3430yun@gmail.com",        // username to login
            password: "knhipliavnpqxwty"            // password to login
        )
        
        //        let megaman = Mail.User(name: "coco", email: "3430coco@gmail.com")
        let megaman = Mail.User(name: "coco", email: self.email)
        let drLight = Mail.User(name: "Yun", email: "3430yun@gmail.com")
        
        
        let mail = Mail(
            from: drLight,
            to: [megaman],
            subject: "歡迎使用我習慣了！這是您的驗證信件",
            text: "以下是您的驗證碼： \(String(self.verify))"
        )
        
        smtp.send(mail) { (error) in
            if let error = error {
                print(error)
            } else {
                print("---------------------------------")
                print("Send email successful")
                print("SEND: SUBJECT: \(mail.subject)")
                print("SEND: SUBJECT: \(mail.text)")
                print("FROM: \(mail.from)")
                print("TO: \(mail.to)")
                print("---------------------------------")
            }
        }
    }
}
