//
//  AppDelegate.swift
//  Lovechive
//
//  Created by 장상경 on 3/5/25.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        sleep(2)
        FirebaseApp.configure()
        
        let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { res, error in
            DispatchQueue.main.async {
                UserDefaultsManager().saveToUserDefaults(res, forKey: "isNotificationEnabled")
            }
        }
        
        if UserDefaults.standard.object(forKey: "정렬 방법") == nil {
            UserDefaults.standard.set("List", forKey: "정렬 방법")
        } else if UserDefaults.standard.object(forKey: "정렬 순서") == nil {
            UserDefaults.standard.set("최신순", forKey: "정렬 순서")
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

