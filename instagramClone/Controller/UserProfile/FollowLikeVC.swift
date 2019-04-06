//
//  Follow.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/28.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "FollowCell"

class FollowLikeVC : UITableViewController, FollowCellDelegate {

  
  //MARK: - Properties
  
  var followCurrentKey : String?
  var likeCurrentKey : String?
  
  
    enum ViewingMode: Int {
      
      case Following
      case Followers
      case Likes
      
      init (index: Int){
        switch index   {
        case 0 : self = .Following
        case 1 : self = .Followers
        case 2 : self = .Likes
        default : self = .Following

      }
    }
  }
  
  var postId: String?
  var uid: String?
  var viewingMode: ViewingMode!
  var users = [User]()

  override func viewDidLoad() {
  super.viewDidLoad()
    
  //セルを登録している,register cell class
  tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdentifier)
    
    //configure nav title
    configureNavigationTitle()
    
    //fetch users
    fetchUsers()
    
//    //configure nav controller and fetch users
//    if let viewingMode = self.viewingMode {
//
//      configureNavigationTitle()
//
//      //fetch users
//      fetchUsers()
//
//    }
  
      //clear separator lines
      tableView.separatorColor = .clear
    }
    

  //MARK: - UITableView
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return users.count
    
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowLikeCell
    
    cell.user = users[indexPath.row]
    
    cell.delegate = self
    
    return cell
    
  }
  
  // フォローしている方のプロフィール画像をクリックした時にプロフィール画面に遷移する
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let user = users[indexPath.row]
    let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
    userProfileVC.user = user
    navigationController?.pushViewController(userProfileVC, animated: true)
    
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
    
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if users.count > 3 {
      if indexPath.item == users.count - 1 {
        
       fetchUsers()
        
      }
    }
  }
  
  //MARK: FollowCellDelegate Protocol
  func handleFollowTapped(for cell: FollowLikeCell) {
    
    guard let user = cell.user else {return}
    
    //返却されるのはbool
    if user.isFollowed {
      
      user.unfollow()
      cell.followButton.setTitle("Follow", for: .normal)
      cell.followButton.setTitleColor(AppColors.white, for: .normal)
      cell.followButton.layer.borderWidth = 0
      cell.followButton.backgroundColor = AppColors.blue
      
    } else {
      
      user.follow()
      cell.followButton.setTitle("Following", for: .normal)
      cell.followButton.setTitleColor(.black, for: .normal)
      cell.followButton.layer.borderWidth = 0.5
      cell.followButton.layer.borderColor = AppColors.lightGray.cgColor
      cell.followButton.setTitleColor(.black, for: .normal)
      cell.followButton.backgroundColor = AppColors.white
   
    }
  }

//MARK: -Handlers
func configureNavigationTitle(){
  guard let viewingMode = self.viewingMode else {return}
  
  switch viewingMode {
  case .Followers: navigationItem.title = "Followers"
  case .Following: navigationItem.title = "Following"
  case .Likes: navigationItem.title = "Likes"
  
   }
  }

func getDatabaseReference() -> DatabaseReference?{
  
  guard let viewingMode = self.viewingMode else {return nil}
  
  
  switch viewingMode {
    
  case .Followers : return USER_FOLLOWER_REF
  case .Following : return USER_FOLLOWING_REF
  case .Likes : return POST_LIKES_REF
    
   }
 }
  
  func fetchUser(withUid uid: String ){
    
    Database.fetchUser(with: uid, completion: { (user) in
    self.users.append(user)
    self.tableView.reloadData()
      
    })
  }
  
  //ユーザー情報を取得してくる
  func fetchUsers(){
    guard let ref = getDatabaseReference() else {return}
    guard let viewingMode = self.viewingMode else {return}
    
    switch viewingMode {
      
    case .Followers, .Following :
      guard let uid = self.uid else {return}
      
      if followCurrentKey == nil {
        ref.child(uid).queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in
         
          guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
          guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
          
          allObjects.forEach({ (snapshot) in
            let followUid = snapshot.key
            self.fetchUser(withUid : followUid)
            
          })
          self.followCurrentKey = first.key
        
        })
      } else {
        
        ref.child(uid).queryOrderedByKey().queryEnding(atValue: self.followCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: {(snapshot) in
            
            guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
          
          allObjects.forEach({ (snapshot) in
            let followUid = snapshot.key
            if followUid != self.followCurrentKey {
              self.fetchUser(withUid: followUid)
              
            }
          })
          
          self.followCurrentKey = first.key
          
        })
      }
      
    case .Likes:
      guard let postId = self.postId else {return}
      
      if likeCurrentKey == nil {
        ref.child(postId).queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in
          
          guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
          guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
          
          allObjects.forEach({ (snapshot) in
            let likeUid = snapshot.key
            self.fetchUser(withUid :likeUid)
          })
          self.likeCurrentKey = first.key
    })
        
      } else {
        
        ref.child(postId).queryOrderedByKey().queryEnding(atValue: self.likeCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: {(snapshot) in
          
          guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
          guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
          
          allObjects.forEach({ (snapshot) in
            let likeUid = snapshot.key
            if likeUid != self.likeCurrentKey {
              self.fetchUser(withUid: likeUid)
              
            }
          })
          
          self.likeCurrentKey = first.key
          
     })
    }
  }
 }
}
