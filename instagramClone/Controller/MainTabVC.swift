//
//  MainTabVC.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/25.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.delegate = self
      configureViewControllers()
      
      //user validation
      checkIfUserIsLoggedIn()
      
    }

  func configureViewControllers() {
    
    //home feed controller
    let feedVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
    
    //search feed controller
    let searchVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchVC())
    
    //post controller
    let uploadPostVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: UploadPostVC())
    
    //notification controller
    let notificationVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: NotificationsVC())
    
    //profile controllen
    let userProfileVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
    
    //タブコントローラーにviewControllerを追加する
    viewControllers = [feedVC, searchVC, uploadPostVC, notificationVC, userProfileVC]
    
    //tab bar tint color
    tabBar.tintColor = .black
    
  }
  
  //construct navigation controller,選択されていない時の画像、選択されている時の画像、遷移する画面がそれぞれ引数になっている
  func constructNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
    
    //ナビゲーションコントローラを設定
    let navController = UINavigationController(rootViewController: rootViewController)
    navController.tabBarItem.image = unselectedImage
    
    //ここを非表示にすると、画像がselectedImageに切り替わらない
    navController.tabBarItem.selectedImage = selectedImage
    
    //よくわからない
    navController.navigationBar.tintColor = .black
    
    //return navController
    return navController
  }
  
  func checkIfUserIsLoggedIn(){
    
    //ログイン中か、否かを判定している
    if Auth.auth().currentUser == nil {
      
      //ログインしていない場合の処理を以下に記述している
      DispatchQueue.main.async {
      let loginVC = LoginVC()
      //present login controller
      let navController = UINavigationController(rootViewController: loginVC)
      self.present(navController, animated: true, completion: nil)
        
      }
      
      return
   
    }
  }
}
