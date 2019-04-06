//
//  AppDelegate.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/20.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

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
    
    
    return true
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

