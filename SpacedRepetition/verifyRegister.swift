//
//  verifyRegister.swift
//  smtp
//
//  Created by 呂沄 on 2023/7/12.
//

import SwiftUI
import SwiftSMTP

struct verifyRegister: View {
    
    var aViewInstance = ContentView()
    @State private var Verify = ""
    @Binding var verify :Int
    @Binding var email :String
    @State private var messenge = ""
    // 此處為日後要更改的秒數
    //    @State var timeRemaining = 300
    @State var timeRemaining = 20
    @State var verificationCode:Int = 0
    @State var verifyNumber:Int = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        VStack {
            VStack {
                Text("剩餘時間：\(timeRemaining / 60)分 \(timeRemaining % 60)秒")
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        }
                    }
                    .padding(10)
                    .frame(width: 400)
                Button {
                    print("再次發送驗證碼")
                    timeRemaining = 20
                    
                    DispatchQueue.global().async {
                        verificationCode =  random()
                        sendMail(verificationCode)
                    }
                    //                    aViewInstance.mix()
                } label: {
                    Text("重新發送驗證碼")
                }
                .padding(10)
                
            }
            HStack {
                Text("您的驗證碼：")
                TextField("驗證碼", text: $Verify)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .padding(10)
            }
            Button {
                print("進行驗證中")
                doVerify()
            } label: {
                Text("進行驗證")
            }
            Text(messenge)
                .foregroundColor(Color.red)
        }
        .navigationTitle("驗證帳號")
    }
    
    func doVerify() {
        // 如果上個畫面的驗證碼還存在的話使用上個畫面的驗證碼去判斷使用者是否輸入錯誤
        if (verify != 0){
            verifyNumber = verify
        } else {
            // 如果上個畫面的驗證碼為0使用新的驗證碼去判斷
            verifyNumber = verificationCode
        }
        //        print("驗證碼為：\(verify)")
        print("驗證碼為：\(verifyNumber)")
        print("使用者輸入為：\(Verify)")
        if (timeRemaining == 0) {
            print("時效已過，請重新再驗證一次")
            messenge = "時效已過，請重新再驗證一次"
        } else {
            //            if (Verify == String(verify)) {
            if (Verify == String(verifyNumber)) {
                // 將使用者資料加入資料庫
                print("使用者輸入正確")
                messenge = "使用者輸入正確"
            } else {
                print("使用者輸入錯誤")
                messenge = "使用者輸入錯誤"
            }
        }
    }
    
    private func random()  -> Int {
        // 如果重新寄送驗證碼的話，上個畫面的驗證碼紀錄會為0
        verify = 0
        self.verificationCode = Int.random(in: 1..<99999999)
        print("隨機變數為：\(self.verificationCode)")
        return self.verificationCode
    }
    
    //    func sendMail() async {
    func sendMail(_ verificationCode: Int)  {
        let smtp = SMTP(
            hostname: "smtp.gmail.com",     // SMTP server address
            email: "3430yun@gmail.com",        // username to login
            password: "knhipliavnpqxwty"            // password to login
        )

//        print("aViewInstance.email:\(email)")
        let megaman = Mail.User(name: "coco", email: email)
        let drLight = Mail.User(name: "Yun", email: "3430yun@gmail.com")
        
        
        let mail = Mail(
            from: drLight,
            to: [megaman],
            subject: "歡迎使用我習慣了！這是您的驗證信件",
            text: "以下是您的驗證碼： \(String(self.verificationCode))"
        )
        
        smtp.send(mail) { (error) in
            if let error = error {
                print(error)
            } else {
                print("Send email successful")
            }
        }
    }
}

struct verifyRegister_Previews: PreviewProvider {
    static var previews: some View {
        @State var verify: Int = 00000000
        @State var email: String = "Email"
        NavigationView {
            verifyRegister(verify: $verify,email: $email)
        }
    }
}
