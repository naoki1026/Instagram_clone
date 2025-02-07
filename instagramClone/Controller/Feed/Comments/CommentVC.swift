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
  
  
  
  lazy var containerView : CommentInputAccesoryView = {
    
    let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
    let containerView = CommentInputAccesoryView(frame: frame)
    
    //定義することでコメント欄の背景を白にして、透けないようにしてくれる
    containerView.backgroundColor = AppColors.white
    
    containerView.delegate = self
    
    return containerView
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

extension CommentVC : CommentInputAccesoryViewDelegate {
 
  func didSubmit(forComment comment: String) {
    
    guard let postId = self.post?.postId else {return}
    guard let uid = Auth.auth().currentUser?.uid else {return}
    let creationDate = Int(NSDate().timeIntervalSince1970)
    
    //データベースに反映するための値の型を作成
    let values = [ "commentText" : comment,
                   "creationDate" : creationDate,
                   "uid" : uid ] as [String : Any]
    
    COMMENT_REF.child(postId).childByAutoId().updateChildValues(values) {(err, ref) in
      
      self.uploadCommentNotificationToServer()
      
      if comment.contains("@") {
        
        self.uploadMentoionNotification(forPostId: postId, withText: comment, isForComment: true)
        
      }
      
      self.containerView.clearCommentTextView()
      
    }
  }
  
}
