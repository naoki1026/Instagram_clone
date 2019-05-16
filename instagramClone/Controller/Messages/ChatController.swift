//
//  ChatController.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/04/03.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "ChatCell"

class ChatController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  //Properties
  
  var user: User?
  var messages = [Message]()
  
  lazy var containerView : UIView = {
    let containerView = UIView()
    
    containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 55)
    
    let sendButton = UIButton(type: .system)
    sendButton.setTitle("Send", for: .normal)
    sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    containerView.addSubview(sendButton)
    sendButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 0)
    sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    
    containerView.addSubview(messageTextField)
    messageTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    
    let separatorView = UIView()
    separatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    containerView.addSubview(separatorView)
    separatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    
    containerView.backgroundColor = AppColors.white
    
   return containerView
    
  }()
  
  let messageTextField : UITextField = {
    
    let tf = UITextField()
    tf.placeholder = "Enter message..."
    return tf
    
  }()
  
  
  //Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    collectionView?.backgroundColor = AppColors.white
    configureNavigationbar()
    observeMessages()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = true
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    tabBarController?.tabBar.isHidden = false
    
  }
  
  override var inputAccessoryView: UIView?{
    
    get {
      
      return containerView
      
    }
  }
  
  override var canBecomeFirstResponder: Bool {
    
    return true
    
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    var height : CGFloat = 80
    let message = messages[indexPath.item]
    height = estimateFrameForText(message.messageText).height + 20
    return CGSize(width: view.frame.width, height: height)
    
  }
  

  //UICollectionCiew
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
    
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier , for: indexPath) as! ChatCell
    
    cell.message = messages[indexPath.item]
    
    configureMessage(cell: cell, message: messages[indexPath.item])
    
    return cell
    
  }
  
  //MARK:Handlers
  @objc func handleSend (){
    
    //メッセージをDBにアップ
    uploadMessageToServer()
    
    messageTextField.text = nil
    
  }
  
  //メッセージをやり取りする画面で自分の会話と相手の会話を分ける
  func configureMessage(cell: ChatCell, message: Message) {
    
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.messageText).width + 32
    cell.frame.size.height = estimateFrameForText(message.messageText).height + 20
    
    if message.fromId == currentUid {
      
      cell.bubbleViewRightAnchor?.isActive = true
      cell.bubbleViewLeftAnchor?.isActive = false
      cell.bubbleView.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
      cell.textView.textColor = .white
      cell.profileImageView.isHidden = true
      
    } else  {
      
      
      cell.bubbleViewRightAnchor?.isActive = false
      cell.bubbleViewLeftAnchor?.isActive = true
      cell.bubbleView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
      cell.textView.textColor = .black
      cell.profileImageView.isHidden = false
      
    }
  }
  
  func configureNavigationbar(){
    
    guard let user = self.user else {return}
    navigationItem.title = user.username
    
    //infoLightでビックリマークが表示されたアイコンに変わる
    let infoButton = UIButton(type: .infoLight)
    infoButton.tintColor = .black
    infoButton.addTarget(self, action: #selector(handleInfoTapped), for:  .touchUpInside)
    let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
    navigationItem.rightBarButtonItem = infoBarButtonItem
    
  }
  
  @objc func handleInfoTapped () {
    
    let userProfileController = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
    userProfileController.user = user
    navigationController?.pushViewController(userProfileController, animated: true)
    
  }
  
    func estimateFrameForText(_ text: String) -> CGRect {
    let size = CGSize(width: 200, height: 1000)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
  }
  
  //MARK:API
  
  //メッセージをDBにアップ、記述方法がアップデートされているため注意
  func uploadMessageToServer(){
    
    guard let messageText = messageTextField.text else {return}
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    guard let user = self.user else {return}
    let creationDate = Int(NSDate().timeIntervalSince1970)
    
    // UPDATE: - Safely unwrapped uid to work with Firebase 5
    guard let uid = user.uid else { return }
    
    var values: [String: AnyObject] = ["toId": user.uid as AnyObject,
                                       "fromId": currentUid as AnyObject,
                                       "creationDate": creationDate as AnyObject,
                                       "messageText" : messageText as AnyObject,
                                       "read": false as AnyObject]
    
    //properties.forEach({values[$0] = $1})
    
    let messageRef = MESSAGES_REF.childByAutoId()
    
    // UPDATE: - Safely unwrapped messageKey to work with Firebase 5
    guard let messageKey = messageRef.key else { return }
    
    messageRef.updateChildValues(values) { (err, ref) in
      USER_MESSAGES_REF.child(currentUid).child(uid).updateChildValues([messageKey: 1])
      USER_MESSAGES_REF.child(uid).child(currentUid).updateChildValues([messageKey: 1])
      
      }
    }
    
//    let messageValues = ["creationDate" : creationDate,
//                         "fromId" : currentUid,
//                         "toId" : user.uid,
//                         "messageText" : messageText ] as! [String : Any]
//
//
//     let messageRef = MESSAGES_REF.childByAutoId()
//    messageRef.updateChildValues(messageValues)
//
//    print("アップロード")
//    print(messageRef)
//
//    ///ここからうまくいっていない・・・
//
//    // UPDATE: - Safely unwrapped messageKey to work with Firebase 5
//    guard let messageKey = messageRef.key else { return }
//
//    messageRef.updateChildValues(values) { (err, ref) in
//      USER_MESSAGES_REF.child(currentUid).child(uid).updateChildValues([messageKey: 1])
//      USER_MESSAGES_REF.child(uid).child(currentUid).updateChildValues([messageKey: 1])
    
//    USER_MESSAGES_REF.child(currentUid).child(user.uid).updateChildValues([messageRef.key: 1])
//    USER_MESSAGES_REF.child(user.uid).child(currentUid).updateChildValues([messageRef.key: 1])
  
  func observeMessages(){

    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    guard let chatPartnerId = self.user?.uid else {return}

    DB_REF.child("user-messages").child(currentUid).child(chatPartnerId).observe(.childAdded) {(snapshot) in

      let messageId = snapshot.key
      self.fetchMessage(withMessageId: messageId)

    }

  }
  
  func fetchMessage(withMessageId messageId : String){
    
    DB_REF.child("messages").child(messageId).observeSingleEvent(of: .value) { (snapshot) in
      guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}

      let message = Message(dictionary: dictionary)
      
      self.messages.append(message)
      self.collectionView?.reloadData()
      
    }
    
  }
  
}
//
//extension ChatController {
//  
//  func handleUploadMessage(message: String) {
//    let properties = ["messageText": message] as [String: AnyObject]
//    uploadMessageToServer(withProperties: properties)
//    
//    //self.containerView.clearMessageTextView()
//  }
//  
////  func handleSelectImage() {
////    let imagePickerController = UIImagePickerController()
////    imagePickerController.delegate = self
////    imagePickerController.allowsEditing = true
////    imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
////    present(imagePickerController, animated: true, completion: nil)
////  }
//}

