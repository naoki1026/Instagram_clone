//
//  NotificationsVC.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/25.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "NotificationCell"

class NotificationsVC: UITableViewController, NotificationCellDelegate {

  
  //MARK: properties
  
  var timer : Timer?
  var currentKey : String?
  var notifications = [Notification]()

    override func viewDidLoad() {
        super.viewDidLoad()
      
      //clear separator line
      tableView.separatorColor = .clear
      
      //navtitle
      navigationItem.title = "Notifications"
      
      //registerCellClass
      //これを登録してあげないとクラッシュしてしまう
      tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
      
      fetchNotifications()

    }

    // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notifications.count
      
    }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
    cell.notification = notifications[indexPath.row]
    cell.delegate = self
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    //notificationには投稿した人の情報が含まれている
    let notification = notifications[indexPath.row]
    
    //print("User that sent notification is \(notification.user.username)")
    let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
    userProfileVC.user = notification.user
    navigationController?.pushViewController(userProfileVC, animated: true)
    
  }
  
  //MARK: NotificationCellDelegate Protocol
  func handleFollowTapped(for cell: NotificationCell) {
    
    guard let user = cell.notification?.user else {return}
    if user.isFollowed {
      
      user.unfollow()
      //Extensionsより
      cell.followButton.configure(didFollow: false)
      
      
    } else {
      user.follow()
       //Extensionsより
      cell.followButton.configure(didFollow: true)
     
    }
    
  }
  
  func handlePostTapped(for cell: NotificationCell) {
    
    //変数postを定義
    guard let post = cell.notification?.post else {return}
    
    //遷移先の画面を定数の中に定義
   let feedController = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
   
    //遷移先の変数の中に入れたい値を定義
    feedController.post = post
    
    //画面遷移を実行
    navigationController?.pushViewController(feedController, animated: true)
    //navigationController?.pushViewController(userProfileVC, animated: true)
    
    
  }
  
  //MARK: Handlers
  
  func handleReloadTable() {
    
    self.timer?.invalidate()
    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleSortNotifications), userInfo: nil, repeats: false)
    
  }
  
  @objc func handleSortNotifications(){
    
    self.notifications.sort { (notification1, notification2) -> Bool in
      return notification1.creationDate > notification2.creationDate
    }
    
    self.tableView.reloadData()
    
  }
  
  
  


  func fetchNotifications() {
    
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    
    NOTIFICATIONS_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
      guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
      
      allObjects.forEach({ (snapshot) in
        let notificationId = snapshot.key
        guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
        guard let uid = dictionary["uid"] as? String else { return }
        
        Database.fetchUser(with: uid, completion: { (user) in
          
          // if notification is for post
          if let postId = dictionary["postId"] as? String {
            Database.fetchPost(with: postId, completion: { (post) in
              let notification = Notification(user: user, post: post, dictionary: dictionary)
//              if notification.notificationType == .Comment {
//                self.getCommentData(forNotification: notification)
//              }
              self.notifications.append(notification)
              self.handleReloadTable()
            })
          } else {
            let notification = Notification(user: user, dictionary: dictionary)
            self.notifications.append(notification)
            self.handleReloadTable()
          }
        })
        NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").setValue(1)
      })
    }
  }
}

  
//  //MARK: API
//
//  func fetchNotifications(){
//
////    //MARK:動いていない・・・
//
////    print("テスト")
//    guard let currentUid = Auth.auth().currentUser?.uid else {return}
//
//    if currentKey == nil {
//
//      Database.database().reference().child("notifications").child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value) {(snapshot) in
//
//        guard let first = snapshot.children.allObjects as? DataSnapshot  else {return}
//        guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
//
//        allObjects.forEach({ (snapshot) in
//
//          let notificationId = snapshot.key
//          guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
//          guard let uid = dictionary["uid"] as? String else {return}
//
//          Database.fetchUser(with: uid, completion: { (user) in
//
//            //if notification is for post
//            if let postId =  dictionary["postId"] as? String {
//
//              Database.fetchPost(with: postId, completion: { (post) in
//
//                let notification = Notification(user: user, post: post, dictionary: dictionary)
//                self.notifications.append(notification)
//                //self.handleSortNotifications()
//                //self.tableView.reloadData()
//                self.handleReloadTable()
//
//              })
//
//            } else {
//
//              let notification = Notification(user: user, dictionary: dictionary)
//              self.notifications.append(notification)
//              //self.handleSortNotifications()
//              //self.tableView.reloadData()
//              self.handleReloadTable()
//            }
//          })
//
//          NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").setValue(1)
//
//        })
//        self.currentKey = first.key
//      }
//    } else {
//
//
//     }
//    }
//  }


