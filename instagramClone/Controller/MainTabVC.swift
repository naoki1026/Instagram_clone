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
  
  //MARK: Properties
  let dot = UIView()
  var notificationIDs = [String]()
  

    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.delegate = self
      configureViewControllers()
      
      configureNotificationDot()
      //user validation
      checkIfUserIsLoggedIn()
      
      //observenotification
      observeNotifications()
      
    }

  func configureViewControllers() {
    
    //home feed controller
    let feedVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
    
    //search feed controller
    let searchVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchVC())
    
//    //post controller
//    let uploadPostVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: UploadPostVC())
    
    //select image controller
    let selectImageVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
      
    //notification controller
    let notificationVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: NotificationsVC())
    
    //profile controllen
    let userProfileVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
    
    //タブコントローラーにviewControllerを追加する
    viewControllers = [feedVC, searchVC, selectImageVC, notificationVC, userProfileVC]
    
    //tab bar tint color
    tabBar.tintColor = .black
    
  }
  
  //MARK: UITabBar
  
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
  
  func configureNotificationDot(){
    
    
    if UIDevice().userInterfaceIdiom == .phone {
      
      let tabBarHeigt = tabBar.frame.height
      
      if UIScreen.main.nativeBounds.height == 2436 {
        
        //for iphone x
        dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - tabBarHeigt, width: 6, height: 6)
        
        
      } else {
        
        //for other
        dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - 16, width: 6, height: 6)
        
      }
      
      dot.center.x = (view.frame.width / 5 * 3 + (view.frame.width / 5) / 2 )
      dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
      dot.layer.cornerRadius = dot.frame.width / 2
      self.view.addSubview(dot)
      dot.isHidden = true
      

    }
  }
  
  //MARK: UITabBar
  
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    let index = viewControllers?.index(of: viewController)
    
    if index == 2 {
      
      let selectImageVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
      let navController = UINavigationController(rootViewController: selectImageVC)
      navController.navigationBar.tintColor = AppColors.black
      present(navController, animated: true, completion: nil)
      return false
      
      
    } else if index == 3 {
      
      print("Did select notification controller")
      
      //
      dot.isHidden = true
      //setNotificationsToChecked()
      //このreturnの後にfalseとすると画面遷移できなくなってしまう
      return true
    }
    
    return true
  }
  
  //MARK: API
  
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
 
  func observeNotifications (){
    
    
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    //self.notificationIDs.removeAll()
    
    //このコードが間違えていた、
    NOTIFICATIONS_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
    //NOTIFICATIONS_REF.child(currentUid).observe(.childAdded) {(snapshot) in
      
      //guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
      guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
      
      allObjects.forEach({(snapshot) in
        
      let notificationId = snapshot.key
      
      NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").observeSingleEvent(of: .value, with: { (snapshot) in
        
        guard let checked = snapshot.value as? Int else { return }
        
        if checked == 0 {
          
          //まだnotificationを確認していない場合
          //print("Notifications has not been checked")
          self.dot.isHidden = false
          //self.notificationIDs.append(notificationId)
          
        } else {
          
          //notificationを確認した場合
          //print("Notifications has been checked")
          self.dot.isHidden = true
          
        }
      })
     })
    }
  }
}


//func observeNotifications() {
//  guard let currentUid = Auth.auth().currentUser?.uid else { return }
//
//  NOTIFICATIONS_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
//    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
//
//    allObjects.forEach({ (snapshot) in
//      let notificationId = snapshot.key
//
//      NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").observeSingleEvent(of: .value, with: { (snapshot) in
//        guard let checked = snapshot.value as? Int else { return }
//
//        if checked == 0 {
//          self.dot.isHidden = false
//        } else {
//          self.dot.isHidden = true
//}
