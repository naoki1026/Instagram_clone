//
//  UIProfileVC.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/25.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//
//プロフィール画面の設定

import UIKit
import Firebase

//Identifierはここに定義しておく
private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
  
    //Mark: -Properties

  var user: User?
  var posts = [Post]()
  var currentKey: String?
  

  
  //User.swiftfile
  //var currentUser : User?
  
  //searchVCで選択されたセルによって表示内容を変更するためも設けられた変数
  //var userToLoadFromSearchVC : User?
  
  //MARK:Int-
  

    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Register cell classes
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
      
       //カスタムヘッダーを登録する
       self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
      
      //configure refresh control
      configureRefreshControll()
      
      
       //background color
       self.collectionView.backgroundColor = AppColors.white

       //searchVCからセルを選択して遷移した場合は、選択したセルに紐づくプロフィールが表示される
      if self.user == nil {
        
      fetchCurrentUserData()
        
      }
      
      
      //fetch posts
      fetchPosts()
      
       //fetchCurrentUserData()
    
      //searchVCから遷移した場合に選択したセルのプロフィールを表示する
//      if let userToLoadFromSearchVC = self.userToLoadFromSearchVC {
//        print("Username from previous controller is \(userToLoadFromSearchVC)")
//      }
      
    }
  
  //MARK: - UICollectionViewFlowLayout
  
  //横線の間隔
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }
  
  //縦線の間隔
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let width = (view.frame.width - 2) / 3
    return CGSize(width: width, height: width)
    
  }
  
  
  //ヘッダーの大きさを定義,rederenceと入力する
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    
    return CGSize(width: view.frame.width, height: 200)
    
  }
  
    // -MARK: UICollectionView
    //セクションは分けないため１としている
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
  
  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
    if posts.count > 9 {
      
      if indexPath.item == posts.count - 1 {
        fetchPosts()
      }
    }
    
  }
  
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return posts.count
    }
  
  //ヘッダーを宣言している
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
  //ヘッダーの宣言
  let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
    
  //デリゲートの設定
  header.delegate = self
    
//    if let user = self.currentUser {
//
//      header.user = user
//
//    } else if let userToLoadFromSearchVC = self.userToLoadFromSearchVC {
//      header.user = userToLoadFromSearchVC
//      navigationItem.title = userToLoadFromSearchVC.username
//
//    }
    
    header.user = self.user
    navigationItem.title = user?.username
    
    //ヘッダーにユーザーを定義する
    //データの取得に時間がかかるとエラー扱いとなってしまう
//    if let user = self.user {
//
//      header.user = user
//    } else {
//
//      print("User was not set")
//    }
    
    
    //ヘッダーを返却している
    return header
  }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell
      
       cell.post = posts[indexPath.item]
    
        return cell
    }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
    
    //ここで１枚しか選択されていないという情報をFeedVCに送っている
    feedVC.viewSinglePost = true
    feedVC.userProfileController = self
    
    feedVC.post = posts[indexPath.item]
    navigationController?.pushViewController(feedVC, animated: true)
    
    
  }
  
  //MARK: -UserProgileHeaderProtocol
  func handleFollowersTapped(for header: UserProfileHeader) {
    let followVC = FollowLikeVC()
    followVC.viewingMode = FollowLikeVC.ViewingMode(index: 1)
    //followVC.viewingMode = FollowLikeVC.ViewingMode(index: 1)
    followVC.uid = user?.uid
    navigationController?.pushViewController(followVC, animated: true)
    print("Handle followers tapped")
  }
  
  //MARK:-ここが怪しい
  func handleFollowingTapped(for header: UserProfileHeader) {
    let followVC = FollowLikeVC()
    followVC.viewingMode = FollowLikeVC.ViewingMode(index: 0)
    followVC.uid = user?.uid
    navigationController?.pushViewController(followVC, animated: true)
    print("Handle following tapped")
  }
  
  
  func handleEditFollowTapped(for header: UserProfileHeader) {
    
    guard let user = header.user else { return }
    
    if header.editProfileFollowButton.titleLabel?.text == "Edit Profile" {
      
      print("Handle edit profile")
    
    } else {
      
    if header.editProfileFollowButton.titleLabel?.text == "Follow" {
      header.editProfileFollowButton.setTitle("Following", for: .normal)
      user.follow()
      
    } else {
     
      header.editProfileFollowButton.setTitle("Follow", for: .normal)
      user.unfollow()
    
      }
    }
  }
  
  func setUserStats(for header: UserProfileHeader) {
    
    guard let uid = header.user?.uid else {return}
    
    var numberOfFollowers: Int!
    var numberOfFollowing: Int!
    
    //フォロワーの数を取得する
    USER_FOLLOWER_REF.child(uid).observe(.value) { (snapshot) in
      
      if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
        
        numberOfFollowers = snapshot.count
        
      } else  {
        
        numberOfFollowers = 0
        
      }
      
      let attributedText = NSMutableAttributedString(string: "\(numberOfFollowers!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
      attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
      
      header.followersLabel.attributedText = attributedText
      
    }
    //フォローしている人の数を取得する
    
     USER_FOLLOWING_REF.child(uid).observe(.value) { (snapshot) in
   // USER_FOLLOWING_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
      
      if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
        
        numberOfFollowing = snapshot.count
        
      } else  {
        
        numberOfFollowing = 0
        
      }
      
      let attributedText = NSMutableAttributedString(string: "\(numberOfFollowing!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
      
      attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
      
      header.followingLabel.attributedText = attributedText
      
    }
  }
  
  //MARK: Handlers
  @objc func handleRefresh(){
    posts.removeAll(keepingCapacity: false)
    self.currentKey = nil
    fetchPosts()
    collectionView?.reloadData()
    //collectionView?.refreshControl?.endRefreshing()
  }
  
  func configureRefreshControll () {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    collectionView?.refreshControl = refreshControl
    
  }
  
  
  //MARK: -API
  func fetchPosts() {
  
    var uid: String!
    
    if let user = self.user {
      
      uid = user.uid
      
    } else {
      
      uid = Auth.auth().currentUser?.uid
      
    }
    //initial data pull
    if currentKey == nil {
      
      USER_POSTS_REF.child(uid).queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { (snapshot) in
        
        self.collectionView?.refreshControl?.endRefreshing()
        
        guard let first  = snapshot.children.allObjects.first as? DataSnapshot else {return}
        guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
        
        allObjects.forEach({ (snapshot) in
          
          let postId = snapshot.key
          self.fetchPost(withPostId: postId)
//          Database.fetchPost(with: postId, completion: { (post) in
//            self.posts.append(post)
//            self.collectionView?.reloadData()
//
//          })
        })
        
        self.currentKey = first.key
        
      })
    } else {
      
      USER_POSTS_REF.child(uid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 7).observeSingleEvent(of: .value, with: { (snapshot) in
        guard let first  = snapshot.children.allObjects.first as? DataSnapshot else {return}
        guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
        
        allObjects.forEach({ (snapshot) in
          let postId = snapshot.key
          
          if postId != self.currentKey {
            self.fetchPost(withPostId: postId)
            
          }
        })
        self.currentKey = first.key
      })
    }
  }
  
  func fetchPost(withPostId postId : String ){
    
    Database.fetchPost(with: postId) { (post) in
      self.posts.append(post)
      self.posts.sort(by: { (post1, post2) -> Bool in
        
        return post1.creationDate > post2.creationDate
        
      })
      
      //self.collectionView?.refreshControl?.endRefreshing()
      self.collectionView?.reloadData()
      
    }
  }
  
  func fetchCurrentUserData(){
    
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    Database.database().reference().child("users").child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
      guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
      
      //keyはfirebase関連
      let uid = snapshot.key
      let user  = User(uid: uid, dictionary: dictionary)
      self.user = user
      self.navigationItem.title = user.username
      self.collectionView.reloadData()
     
     }
   }
}
    
    //guard let currentUid = Auth.auth().currentUser?.uid else { return }
    
    //print("Current user id is \(currentUid)")
    
    //Firebaseのusersのカテゴリの中のusernameの情報を取得してくるということをここでは表している
    //このsnapshotの中にユーザー名の情報が入っている
//    Database.database().reference().child("users").child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
    
//    print(snapshot)
    
//      //Stringがキーで、AnyObjectが中身である
//      guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
//
//      //snaoshotkeyはデータベースにある規則性のないキー値のことである
//      let uid = snapshot.key
//
//      let user  = User(uid: uid, dictionary: dictionary)
//
//      //print("Username is \(user.username)")
//
//       self.navigationItem.title = user.username
//
//      self.user = user
      
      
//      guard let username = snapshot as? String else {return}
//       //ここでユーザー名が表示される
//      //print(snapshot)
//      self.navigationItem.title = username




////アップロードしているスナップショット画像のスナップショットを取得している
////guard let uid = self.user?.uid else {return}
//USER_POSTS_REF.child(uid).observe(.childAdded) {(snapshot) in
//
//  let postId = snapshot.key
//
//  Database.fetchPost(with: postId, completion: { (post) in
//
//    self.posts.append(post)
//
//    //日付が新しいものから順番に並び替えることができる
//    self.posts.sort(by: { (post1, post2) -> Bool in
//      return post1.creationDate > post2.creationDate
//    })
//
//    //ここで画像をアップロードする際に自分がコメントした内容が表示される
//    //print("Post caption is \(post.caption)")
//    self.collectionView?.reloadData()
//
//
//  })
//  //      POSTS_REF.child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
//  //
//  //        //print(snapshot)
//  //
//  //        guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
//  //        let post = Post(postId: postId, dictionary: dictionary)
//
//  //        self.posts.append(post)
//  //
//  //          //日付が新しいものから順番に並び替えることができる
//  //          self.posts.sort(by: { (post1, post2) -> Bool in
//  //            return post1.creationDate > post2.creationDate
//  //          })
//  //
//  //        //ここで画像をアップロードする際に自分がコメントした内容が表示される
//  //        //print("Post caption is \(post.caption)")
//  //
//  //        self.collectionView?.reloadData()
//
//}
