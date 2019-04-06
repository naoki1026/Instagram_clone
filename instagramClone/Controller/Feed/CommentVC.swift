//
//  CommentVC.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/04/01.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "CommentCell"

class CommentVC : UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  //MARK: Properties
  var comments = [Comment]()
  var post : Post?
  
  
  
  lazy var containerView : UIView = {
    
    let containerView = UIView()
    containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
    
    containerView.addSubview(postButton)
    postButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 0 )
    postButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    
    containerView.addSubview(commentTextField)
    commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: postButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    
    let separatorView = UIView()
    separatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    containerView.addSubview(separatorView)
    separatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    
    //定義することでコメント欄の背景を白にして、透けないようにしてくれる
    containerView.backgroundColor = AppColors.white
    
    return containerView
  }()
  
  let commentTextField : UITextField = {
   let tf = UITextField()
    tf.placeholder = "Enter comment..."
    tf.font = UIFont.systemFont(ofSize: 14)
    return tf
  }()
  
  let postButton : UIButton = {
    
  let button = UIButton(type: .system)
  button.setTitle("Post", for: .normal)
  button.setTitleColor(.black, for: .normal)
  button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    button.addTarget(self, action: #selector(handleLoadComment), for: .touchUpInside)
  return button
    
    
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //configure collectionV View
   collectionView?.backgroundColor = .white
    
   collectionView?.alwaysBounceVertical = true
   collectionView?.keyboardDismissMode = .interactive
   collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
   collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
    
   navigationItem.title = "Comments"
    
  //register cell class
  collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
  //fetch comments
    fetchComments()
    
  }
  //画面が表示される直前
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = true
  }
  
  //別の画面に遷移する直前
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
     tabBarController?.tabBar.isHidden = false
  }
  
  //キーボードの表示・非表示を制御している
  override var inputAccessoryView: UIView? {
    
    get {
      
      return containerView
    }
  }
  //キーボードの表示、非表示を制御している
  override var canBecomeFirstResponder: Bool {
    
    return true
    
  }
  
  //MARK: UICollectionView
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//    return CGSize(width: collectionView.frame.width, height:  50)
    let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
    let dummyCell = CommentCell(frame:frame)
    dummyCell.comment = comments[indexPath.item]
    dummyCell.layoutIfNeeded()
    
    let targetSize = CGSize(width: view.frame.width, height: 1000)
    let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
   
    let height = max(40 + 8 + 8, estimatedSize.height)
    return CGSize(width: view.frame.width, height: height)
    
  } 
 
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
  return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return comments.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
  
    handleHashtagTapped(forCell: cell)
    handleMentionTapped(forCell: cell)
    
  cell.comment = comments[indexPath.item]
  return cell
  
  }
  
  //MARK: Handlers
  
  @objc func handleLoadComment (){
    
    guard let postId = self.post?.postId else {return}
    guard let commentText = commentTextField.text else {return}
    guard let uid = Auth.auth().currentUser?.uid else {return}
    let creationDate = Int(NSDate().timeIntervalSince1970)
    
    //データベースに反映するための値の型を作成
    let values = [ "commentText" : commentText,
                   "creationDate" : creationDate,
    "uid" : uid ] as [String : Any]
    
    COMMENT_REF.child(postId).childByAutoId().updateChildValues(values) {(err, ref) in
      
      self.uploadCommentNotificationToServer()
      
      if commentText.contains("@") {
        
         self.uploadMentoionNotification(forPostId: postId, withText: commentText, isForComment: true)
        
      }
     
      self.commentTextField.text = nil
      
    }
  }
  
  
  func handleHashtagTapped(forCell cell : CommentCell){
    cell.commentLabel.handleHashtagTap { (hashtag) in
      let hashtagController = HashtagController(collectionViewLayout: UICollectionViewFlowLayout())
      hashtagController.hashtag = hashtag
      self.navigationController?.pushViewController(hashtagController, animated: true)
    }
  }
  
  func handleMentionTapped(forCell cell: CommentCell){
    
    cell.commentLabel.handleMentionTap {(username) in
      self.getMentionUser(withUsername: username )
      
    }
  }
  
  
  //MARK:API
  
 func fetchComments(){
  
  guard let post = self.post else {return}
  guard let postId = post.postId else {return}
  COMMENT_REF.child(postId).observe(.childAdded) {(snapshot) in
    
    //print(snapshot)
    
    guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
    guard let uid = dictionary["uid"] as? String else {return}
    
    Database.fetchUser(with: uid, completion: { (user) in
      
      let comment = Comment(user: user, dictionary: dictionary)
      self.comments.append(comment)
      self.collectionView?.reloadData()
      
    })
   }
  }
    
//    let comment = Comment(dictionary: dictionary)
//    self.comments.append(comment)
//
//    print("User that commented is \(comment.user?.username)")
//    self.collectionView?.reloadData()
    

  
//  func getMentionUser(withUsername username : String) {
//    
//    USER_REF.observe(.childAdded) {(snapshot) in
//      let uid = snapshot.key
//      USER_REF.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
//        guard let dictionary = snapshot.value as? Dictionary <String, AnyObject> else {return}
//        
//        if username == dictionary["username"] as? String {
//          Database.fetchUser(with: uid, completion: { (user) in
//            let userProfileController = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
//            userProfileController.user = user
//            self.navigationController?.pushViewController(userProfileController, animated: true)
//            return
//          })
//        }
//      })
//    }
//  }
//  func uploadMentoionNotification (forPostId postId : String, withText text: String) {
//    
//    guard let currentUid = Auth.auth().currentUser?.uid else {return}
//    let creationDate = Int(NSDate().timeIntervalSince1970)
//    let words = text.components(separatedBy: .whitespacesAndNewlines)
//    
//    for var word in words {
//      if word.hasPrefix("@") {
//        word = word.trimmingCharacters(in: .symbols)
//        word = word.trimmingCharacters(in: .punctuationCharacters)
//        
//        USER_REF.observe(.childAdded) { (snapshot) in
//          let uid = snapshot.key
//          
//          USER_REF.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
//            if word == dictionary["username"] as? String {
//              
//              let notificationValues = ["postId" : postId,
//                                       "uid" : currentUid,
//                                       "type" : MENTION_INT_VALUE,
//                                       "creationDate" : creationDate ] as [String : Any]
//              
//              if currentUid != uid {
//                
//                NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(notificationValues)
//              }
//            }
//          })
//        }
//      }
//    }
//  }
  
  
  func uploadCommentNotificationToServer(){
    
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    guard let postId = self.post?.postId else {return}
    guard let uid = post?.user?.uid else {return}
    let creationDate = Int(NSDate().timeIntervalSince1970)
    
    //notification values
    let values = ["checked" : 0,
                  "creationDate" : creationDate,
                  "uid" : currentUid,
                  "type" : COMMENT_INT_VALUE,
                  "postId" : postId ] as [String : Any]
    
    print("確認中です")
    
    //upload comment notification to server
    if uid != currentUid {
      
      NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(values)
      
    }
  }
}
