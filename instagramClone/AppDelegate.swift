//
//  AppDelegate.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/20.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate, MessagingDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
   
    
    FirebaseApp.configure()
    
    //この２行で新しい黒い画面を表示することができる
    window = UIWindow()
    //window?.makeKeyAndVisible()
    
    //window?.rootViewController = LoginVC()
    //ここで最初に表示させる画面を定義する
    //window?.rootViewController = UINavigationController(rootViewController: MainTabVC())
    window?.rootViewController = MainTabVC()
    
    attemptToRegisterForNotifications(application: application)
    
    return true
  }
  
  func attemptToRegisterForNotifications(application: UIApplication) {
    
    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self
    let options: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: options) { (authorized, error) in
      if authorized {
        print("DEBUG: SUCCESSFULLY REGISTERED FOR NOTIFICATIONS")
      }
    }
    application.registerForRemoteNotifications()
    
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
    print("DEBUG: Registered for notifications with deveice token:", deviceToken  )
  }
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    
    print("DEBUG: Registered with FCM Token: ", fcmToken)
  }
  
  
  func applicationWillResignActive(_ application: UIApplication) {
    
    
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    
  }

  func applicationWillTerminate(_ application: UIApplication) {
    
  }


}

