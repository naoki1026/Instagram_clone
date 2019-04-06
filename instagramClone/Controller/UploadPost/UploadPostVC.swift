//
//  UploadPostVCViewController.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/25.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

class UploadPostVC: UIViewController, UITextViewDelegate {
  
  //MARK: Properties
  enum UploadAction: Int {
    case UploadPost
    case SaveCanges
    
    init(index: Int) {
      switch index {
      case 0 : self = .UploadPost
      case 1 : self = .SaveCanges
      default: self = .UploadPost
        
      }
    }
  }
  
  var uploadAction :  UploadAction!
  var selectedImage : UIImage?
  var isEditMode = false
  var postToEdit : Post?
 
  

  
  let photoImageView : CustomImageView = {
    let iv = CustomImageView  ()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = AppColors.lightGray
    return iv
  }()
  
  let captionTextView : UITextView = {
    
    let tv = UITextView()
    tv.backgroundColor = UIColor.groupTableViewBackground
    tv.font = UIFont.systemFont(ofSize: 12)
    return tv
    
  }()
  
  let actionButton : UIButton  = {
    let button = UIButton(type: .system)
    button.backgroundColor = AppColors.lightBlue
    button.setTitle("share", for: .normal)
    button.setTitleColor(AppColors.white, for: .normal)
    button.layer.cornerRadius = 5
    button.isEnabled = false
    button.addTarget(self, action: #selector(handleUploadAction), for: .touchUpInside)
    return button
    
  }()
  
    //MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
      
      //ナビゲーションバーのすぐ下という指定の仕方は基本的にはない
      configureViewComponents()
      
      //configureViewComponentsの後にloadImageを行わないとクラッシュしてしまう
      loadImage()
      
      //text view delegate
      captionTextView.delegate = self
      
      view.backgroundColor = AppColors.white
      
    }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if uploadAction == .SaveCanges {
      
      guard let post = self.postToEdit else {return}
      actionButton.setTitle("Save Changes", for: .normal)
      self.navigationItem.title = "Edit Post"
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
      navigationController?.navigationBar.tintColor = .black
      photoImageView.loadImage(with: post.imageUrl)
      captionTextView.text = post.caption
      
    } else {
      
      actionButton.setTitle("Share", for: .normal)
      self.navigationItem.title = "Update post"
      
    }
  }
  
  func configureViewComponents(){

  view.addSubview(photoImageView)
  photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
  
  view.addSubview(captionTextView)
  captionTextView.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 100)
  
  view.addSubview(actionButton)
  actionButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 40)
    
  }
  
  //MARK: - UITextView
  func textViewDidChange(_ textView: UITextView) {
    
    //textView.textが空欄ではない場合
    guard !textView.text.isEmpty else {
      actionButton.isEnabled = false
      actionButton.backgroundColor = AppColors.lightBlue
      return
      
    }
    
    actionButton.isEnabled = true
    actionButton.backgroundColor = AppColors.blue
    
  }
  
  //MARK: - Handlers
  
  func updateUserFeeds(with postId : String){
    
    //current user id
    
    //current user id
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    
    //database values
    let values = [postId: 1]
    
    //update followers feeds
    USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) {(snapshot) in
      let followerUid = snapshot.key
      USER_FEED_REF.child(followerUid).updateChildValues(values)
      
    }
    
    //upda  te current user feed
    USER_FEED_REF.child(currentUid).updateChildValues(values)
    
  }
  
  @objc func handleUploadAction() {
    
    buttonSelector(uploadAction: uploadAction)
    
  }
  
  @objc func handleCancel(){
    
    self.dismiss(animated: true, completion: nil)
    
  }
  
  func buttonSelector(uploadAction: UploadAction){

    switch uploadAction {
      
    case .UploadPost:
      handleUploadPost()
      
    case .SaveCanges:
      handleSavePostChanges()
      
    }
    
  }
  
  func handleSavePostChanges(){
    
    print("ここまでOK")
    
    guard let post = self.postToEdit else {return}
    let updatedCaption = captionTextView.text
    uploadHashtagToServer(withPostId: post.postId)
    
    POSTS_REF.child(post.postId).child("caption").setValue(updatedCaption) {(err, ref) in
      
      //_ = self.navigationController?.popViewController(animated: true)
      self.dismiss(animated: true, completion: nil)
    }
    
  }
  
  func handleUploadPost(){
    //parameters
    guard
      let caption = captionTextView.text,
      let postImg = photoImageView.image,
      let currentUid = Auth.auth().currentUser?.uid else {return}
    
    //入力された文字を表示する
    //print("Post caption is \(caption)")
    
    //image upload data
    guard let uploadData = postImg.jpegData(compressionQuality: 0.5) else { return }
    
    //creation Data
    let creationDate = Int(NSDate().timeIntervalSince1970)
    
    //upload storage
    let filename = NSUUID().uuidString
    
    //この２行はビデオと異なる
    let storageRef = STORAGE_POST_IMAGES_REF.child(filename)
    storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
      //Storage.storage().reference().child("post_images").child(filename).putData(uploadData, metadata: nil) { (metadata, error) in
      
      //handle error
      if let error = error {
        
        print("Failed to upload image to storage with error", error.localizedDescription)
        return
      }
      
      //image url
      storageRef.downloadURL(completion: { (url, error) in
        
        //absoluteStringでURLをString型に変更している
        guard let imageUrl = url?.absoluteString else { return }
        
        //データベースに書き込む情報
        let values = ["caption" : caption,
                      "creationDate" : creationDate,
                      "likes" : 0,
                      "imageUrl" : imageUrl,
                      "ownerUid" : currentUid] as [String : Any]
        
        //post idを定義している
        //POSTS_REFが最終的にはpostsになっている
        let postId = POSTS_REF.childByAutoId()
        
        //映像と異なるところ
        guard let postKey = postId.key else { return }
        
        //データベースにアップロードしている
        postId.updateChildValues(values, withCompletionBlock: { (err, ref) in
          
          //update user-post structure, user-postsを追加する
          //Database.database().reference().child("user-posts").child(currentUid).updateChildValues([postId.key: 1])
          
          //下の２行が映像とは異なるところ
          let userPostsRef = USER_POSTS_REF.child(currentUid)
          userPostsRef.updateChildValues([postKey: 1])
          
          //update user-feed structure
          self.updateUserFeeds(with: postKey)
          
          //ハッシュタグをアップする
          self.uploadHashtagToServer(withPostId : postKey)
          
          //upload mention notification to server
          if caption.contains("@") {
            
            self.uploadMentoionNotification(forPostId: postKey, withText: caption, isForComment: false)
            
          }
          
          //元の画面に戻ってきている
          self.dismiss(animated: true, completion: {
            self.tabBarController?.selectedIndex = 0
            
          })
        })
      })
    }
  }
  
  func loadImage() {
    
    guard let selectedImage = self.selectedImage else { return }
    
    photoImageView.image = selectedImage
    
  }
  
  //ハッシュタグをアップする
  func uploadHashtagToServer(withPostId postId: String){
    
    guard let caption = captionTextView.text else {return}
    let words : [String] = caption.components(separatedBy: .whitespacesAndNewlines)
    
    for var word in words {
      
      if word.hasPrefix("#") {
        
        word = word.trimmingCharacters(in: .punctuationCharacters)
        word = word.trimmingCharacters(in: .symbols)
        
        let hashgtagValues = [postId : 1]
        HASHTAG_POST_REF.child(word.lowercased()).updateChildValues(hashgtagValues)
        
      }
    }
  }
}
