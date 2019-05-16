//
//  FeedVC.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/25.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase
import ActiveLabel

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedCellDelegate {

  // MARK: - Properties
  
  var posts = [Post]()
  var viewSinglePost = false
  var post : Post?
  var currentKey : String?
  var userProfileController : UserProfileVC?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      //MARK: Properties
      
      collectionView?.backgroundColor = AppColors.white
      
      //register cell classes
      self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
      
      //configure refresh control
      //フォロー、アンフォローした際に自動的に更新されるようになっている
      let refreshControl =  UIRefreshControl()
      refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
      collectionView?.refreshControl = refreshControl
      
      //configure logout button
      configureNavigationBar()
      
      if !viewSinglePost{
        
      //posts.removeAll(keepingCapacity: false)
      fetchPosts()
      //posts.removeAll(keepingCapacity: false)
      //handleRefresh() -> うまくいかない
      }
      updateUserFeeds()
      
    }
  
  //MARK: -UICollectionViewFlowLayout
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let width = view.frame.width
    var height = width + 8 + 40 + 8
    height += 50
    height += 60
    return CGSize(width: width, height: height)
  }
  
  // MARK: -UICollectionViewDataSource
  
  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
    if posts.count > 4 {
      if indexPath.item == posts.count - 1 {
        fetchPosts()
      }
    }
  }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
      
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      
       // return posts.count
      if viewSinglePost {
        return 1
      } else {
        
        return posts.count
      }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
      
      cell.delegate = self
      
      //var post : Post!
      
      //プロフィール画面で画像が選択された場合、メイン画面のフォーマットで画像を表示するものの、
      //全てではなくて１枚しか表示されないようにする
      if viewSinglePost {
        
        if let post  = self.post {
        cell.post = post
        
         }
        
      } else {
        
        cell.post = posts[indexPath.item]
      }
      
      handleHashtagTapped(for: cell)
      handleUsernameLabelTapped(forCell: cell)
      handleMentionTapped(forCell: cell)
      
      //cell.post = posts[indexPath.row]
    
        return cell
    }
  
  //MARK: Feed cell delegate protocol
  
  //userProfileVCに画面遷移する
  func handleUsernameTapped(for cell: FeedCell) {
    guard let post = cell.post else {return}
    let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
    userProfileVC.user = post.user
    navigationController?.pushViewController(userProfileVC, animated: true)
    
  }
  
  //右上に表示されている・・・ボタンをクリックした時に表示するポップアップについて定義している
  func handleOptionsTapped(for cell: FeedCell) {
    
    guard let post = cell.post else {return}
    
    //自分自身の投稿以外は削除できないようになっている
    if post.ownerUid == Auth.auth().currentUser?.uid {
      
          let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
          alertController.addAction(UIAlertAction(title: "Delete post", style: .destructive, handler: { (_) in
      
           post.deletePost()
            
            if !self.viewSinglePost {
              
              self.handleRefresh()
              
            } else {
              
              if let userProfileController = self.userProfileController {
                 _ = self.navigationController?.popViewController(animated: true)
                userProfileController.handleRefresh()
                
              }
             }
          }))
      
          alertController.addAction(UIAlertAction(title: "Edit post", style: .default, handler: { (_) in
            let uploadPostController = UploadPostVC()
            let navigationController = UINavigationController(rootViewController: uploadPostController)
            uploadPostController.isEditMode = true
            uploadPostController.postToEdit = post
            uploadPostController.uploadAction = UploadPostVC.UploadAction(index: 1)
            //self.navigationController?.pushViewController(uploadPostController, animated: true)
            self.present(navigationController, animated: true, completion: nil)
            
           
          }))
      
      alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
      
          present(alertController, animated: true, completion: nil)
      
    }
  }
  
  func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool) {
    
    print("テストです")
    guard let post = cell.post else {return}
    //guard let postId = post.postId else {return}
    
    if post.didLike {
      
      //ダブルタップされなかった場合
      if !isDoubleTap {
        post.adjustLikes(addLike: false, completion: { (likes) in
          cell.likesLabel.text = "\(likes) likes"
          cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
//          //DBのnotificationsにも反映される
//          self.sendLikeNotificationToServer(post: post, didLike: false)
          
        })
      }
      //updateLikeStructures(with: postId, addLike: false)
      
    } else {
      
      //ダブルタップされた場合
      post.adjustLikes(addLike: true, completion: { (likes) in
        cell.likesLabel.text = "\(likes) likes"
         cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
        
//        //DBのnotificationsにも反映される
//        self.sendLikeNotificationToServer(post: post, didLike: true)
      })
    }
  }
  
  func handleShowLikes(for cell: FeedCell) {
    guard let post = cell.post else {return}
    guard let postId = post.postId else {return}
   
    let followLikeVC = FollowLikeVC()
    
    followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 2)
    followLikeVC.postId = postId
    navigationController?.pushViewController(followLikeVC, animated: true)
    
  }
  
  func handleConfigureLikeButton(for cell: FeedCell) {
    
    guard let post = cell.post else {return}
    guard let postId = post.postId else {return}
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    
    USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
      
      if snapshot.hasChild(postId) {
        post.didLike = true
        cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
        
       }
      }
     }
  
  func handleCommentTapped(for cell: FeedCell) {
    guard let post = cell.post else {return}
    let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
    
    //postIdをcommentVCに渡している
    commentVC.post = post
    navigationController?.pushViewController(commentVC, animated: true)
    
  }

 
  // MARK: -Handlers
  @objc func handleRefresh(){
    
    posts.removeAll(keepingCapacity: false)
    self.currentKey = nil
    fetchPosts()
    collectionView?.reloadData()
    
  }
  
  @objc func handleShowMessages() {
    
   let messagesController =  MessagesController()
    navigationController?.pushViewController(messagesController, animated:true)
    
  }
  
  func handleHashtagTapped (for cell: FeedCell){
    cell.captionLabel.handleHashtagTap { (hashtag ) in
      let hashtagController = HashtagController(collectionViewLayout: UICollectionViewFlowLayout())
      hashtagController.hashtag = hashtag
      self.navigationController?.pushViewController(hashtagController, animated: true)
      
      //print("HASHTAG IS \(hashtag)")
    }
    
  }
  
  func handleMentionTapped(forCell cell: FeedCell) {
    
    cell.captionLabel.handleMentionTap { (username) in
      self.getMentionUser(withUsername: username)
    }
  }
  
  func handleUsernameLabelTapped(forCell cell: FeedCell){
    
    guard let user = cell.post?.user else {return}
    guard let username = user.username else {return}
    
     let customType = ActiveType.custom(pattern: "^\(username)\\b")
    
    cell.captionLabel.handleCustomTap(for: customType) { (_) in
      let userProfileController = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
      userProfileController.user = user
      self.navigationController?.pushViewController(userProfileController, animated: true)
      
    } 
  }
  
  
  //MARK:どこからも参照されていないため削除
//  func updateLikeStructures(with postId : String, addLike: Bool){
//    guard let currentUid = Auth.auth().currentUser?.uid else {return}
//
//    if addLike
//
//    {
//    } else {
//   }
//  }
  
  func configureNavigationBar() {
    
    //プロフィール画面から画像が選択されている場合に、logoutボタンは非表示にする
    if !viewSinglePost {
      
          self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
      
    }
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"),  style: .plain, target: self, action: #selector(handleShowMessages))
    self.navigationItem.title = "Feed"
    
  }
  
  @objc func handleLogout(){
    
    //declare alret controller
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    //add alret logout action
    alertController.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { (_) in
      
      do {
        //サインアウトを試みる
        try Auth.auth().signOut()
        
       let loginVC = LoginVC()
        
        //present login controller
        let navController = UINavigationController(rootViewController: loginVC)
        self.present(navController, animated: true, completion: nil)
        print("Successfully logged user out")
        
      } catch {

        //handle error
        print("Falied to sign out")
        
      }
    }))
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alertController, animated: true, completion: nil)
    
  }
  
  //MARK: API
  func updateUserFeeds(){
    
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    USER_FOLLOWING_REF.child(currentUid).observe(.childAdded) {(snapshot) in
     let followingUserId = snapshot.key
      USER_POSTS_REF.child(followingUserId).observe(.childAdded, with: {(snapshot) in
      let postId = snapshot.key
        USER_FEED_REF.child(currentUid).updateChildValues([postId: 1 ])
        
      })
    }
    
    USER_POSTS_REF.child(currentUid).observe(.childAdded) {(snapshot) in
    let postId =  snapshot.key
    USER_FEED_REF.child(currentUid).updateChildValues([postId: 1 ])
    
    }
  }
  
  func fetchPosts(){
    
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    
    if currentKey == nil {
      
//      USER_FEED_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
//        print(snapshot)
//      }
      
      //Feed画面に表示される投稿画像を5件までとする
      USER_FEED_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
        
        self.collectionView?.refreshControl?.endRefreshing()
        
        guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
        guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
        
        allObjects.forEach({ (snapshot) in
          let postId = snapshot.key
          self.fetchPost(withPostId: postId)
          
        })
      
        self.currentKey = first.key
        
      })
      
    } else {
      
      USER_FEED_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value,with: { (snapshot) in
        
        //self.collectionView?.refreshControl?.endRefreshing()
        
        guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
        guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
        
        allObjects.forEach({ (snapshot) in
          
          let postId = snapshot.key
          if postId != self.currentKey {
            self.fetchPost(withPostId : postId)
            
          }
        })
        
        self.currentKey = first.key
        
      })
     }
    }
  
  func fetchPost(withPostId postId :String){
    
    Database.fetchPost(with: postId) { (post) in
      self.posts.append(post)
      self.posts.sort(by: { (post1, post2) -> Bool in
        
        return post1.creationDate > post2.creationDate
        
      })
      
      //self.collectionView?.refreshControl?.endRefreshing()
      self.collectionView?.reloadData()
      
    }
  }
}

extension UITabBar {
  override open func sizeThatFits(_ size: CGSize) -> CGSize {
    
    
    var size = super.sizeThatFits(size)
    size.height = 35
    
    
    
    return size
  }
}


//
//func fetchPosts(){
//  
//  guard let currentUid = Auth.auth().currentUser?.uid else {return}
//    //ここでが全ての投稿画像に関するスナップショットを取得している
//    USER_FEED_REF.child(currentUid).observe(.childAdded) {(snapshot) in
//
//       //print("can fetch")
//       //print(snapshot)
//
//      let postId = snapshot.key
//
//      Database.fetchPost(with: postId, completion: { (post) in
//
//      self.posts.append(post)
//
//      self.posts.sort(by: { (post1, post2) -> Bool in
//      return post1.creationDate > post2.creationDate
//
//      })
//
//      //stop refreshing、メイン画面を更新している
//      self.collectionView?.refreshControl?.endRefreshing()
//
//      //print("post caption is", post.caption)
//      self.collectionView?.reloadData()
//
//      })
//    }


