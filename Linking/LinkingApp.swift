//
//  LinkingApp.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/13.
//

import SwiftUI
import Firebase
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"
     let aps = "aps"
     let data1Key = "DATA1"
     let data2Key = "DATA2"
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("대리인에게 실행 프로세스가 거의 완료되었으며 앱을 실행할 준비가 되었음을 알림")
        // 파베 설정
        FirebaseApp.configure()
        
        //(Messaging: FIRMessaging)의 인스턴스에게 FCM 토큰 새로 고침 및 FCM 직접 채널을 통해 수신된 원격 데이터 메시지를 처리하도록 위임
        
        // 취소승인옵션, [경고를 표시하는 기능, 앱의 배지를 업데이트 하는 기능, 소리를 재상하는 기능]
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        // 로컬 및 원격 알림이 사용자의 장치로 전달될 때 사용자와 상호 작용할 수 있는 권한 부여를 요청.
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        NSApplication.shared.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self // MessagingDelegate
        UNUserNotificationCenter.current().delegate = self
    
    }

    private func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("가져올 데이터가 있음을 나타내는 원격 알림이 도착했음을 앱에 알림")
        if let messageID = userInfo[gcmMessageIDKey] {
                          print("Message ID: \(messageID)")
                      }
                      print("userInfo : ", userInfo)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   willPresent notification: UNNotification,
                                   withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
           print("앱이 포그라운드에서 실행되는 동안 도착한 알림을 처리하는 방법")
           let userInfo = notification.request.content.userInfo
           if let messageID = userInfo[gcmMessageIDKey] {
               print("Message ID: \(messageID)")
           }
           
           if let data1 = userInfo[data1Key] {
               print("data1: \(data1)")
           }
           
           if let data2 = userInfo[data2Key] {
               print("data2: \(data2)")
           }

           if let apsData = userInfo[aps] {
               print("apsData : \(apsData)")
           }
           // Change this to your preferred presentation option
           completionHandler([[.banner, .badge, .sound]])
       }
       
       func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
           print("앱이 APNS에 성공적으로 등록되었음을 대리자에게 알림")
           Messaging.messaging().apnsToken = deviceToken
       }
       
       func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
           print("APNS가 등록 프로세스를 성공적으로 완료할 수 없어서 대리인에게 전송되었음")
       }
       
       func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   didReceive response: UNNotificationResponse,
                                   withCompletionHandler completionHandler: @escaping () -> Void) {
           print("전달된 알림에 대한 사용자의 응답을 처리하도록 대리인에게 요청합니다.")
           let userInfo = response.notification.request.content.userInfo
           
           if let messageID = userInfo[gcmMessageIDKey] {
               print("Message ID from userNotificationCenter didReceive: \(messageID)")
           }
           print(userInfo)
           completionHandler()
       }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("messaging")
        let deviceToken:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
           name: Notification.Name("FCMToken"),
           object: nil,
           userInfo: deviceToken
         )
        print("Device token: ", deviceToken) // This token can be used for testing notifications on FCM
        UserDefaults.standard.set(deviceToken["token"]!, forKey: "token")
        NotificationViewModel.shared.insertFcmToken(token: deviceToken["token"]!)
    }
}
    
@main
struct LinkingApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(ProjectViewModel()).environmentObject(GroupViewModel())
                .environmentObject(PageViewModel()).environmentObject(ToDoViewModel()).environmentObject(NotificationViewModel()).environmentObject(ChatViewModel())
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands{
            SidebarCommands()
        }
    }
}
