//
//  NotificationCell.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/04/01.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
  
  //MARK: Properties
  
  var delegate : NotificationCellDelegate?
  //以下のコードを記述することで、notificationの画面に画像、コメントが表示されるようになった
  var notification: Notification? {
    
    didSet {
      
      guard let user = notification?.user else {return}
      
      //guard let username = user.username else {return}
      guard let profileImageUrl = user.profileImageUrl else {return}
      
      //configure notification label
      configureNotificationLabel()
      
      //configure notification type
      configureNotificationType()
      
      profileImageView.loadImage(with: profileImageUrl)
      //notificationLabel.text = "\(username)\(notificationMessage)"
      
      if let post = notification?.post {
        postImageView.loadImage(with: post.imageUrl)
        
      }
    }
  }
  
  let profileImageView : CustomImageView = {
    
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = AppColors.lightGray
    return iv
    
  }()
  
  let notificationLabel : UILabel = {
    
    let label = UILabel()
    label.numberOfLines = 3
    return label
    
  }()
  
  lazy var followButton : UIButton =  {
    
    let button = UIButton(type: .system)
    button.setTitle("Loading", for: .normal)
    button.setTitleColor(AppColors.white, for: .normal)
    button.backgroundColor = AppColors.blue
    button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
    return button
    
     }()
    
  lazy var postImageView : CustomImageView = {
      
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = AppColors.lightGray
    
    //ボタンでは記述する必要はないが、imageViewをボタンのように扱う場合に記述する必要がある
    let postTap = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
    postTap.numberOfTouchesRequired = 1
    iv.isUserInteractionEnabled = true
    iv.addGestureRecognizer(postTap)
    
    return iv
    
  }()
  
  //MARK:  -Handlers
  @objc func handleFollowTapped(){
    
    delegate?.handleFollowTapped(for: self)
    
  }
  
  @objc func handlePostTapped(){
    
    delegate?.handlePostTapped(for: self)
    
  }
  
  
  func configureNotificationLabel(){
    
    guard let notification = self.notification else {return}
    guard let user = notification.user else {return}
    guard let username = user.username else {return}
    let notificationMessage = notification.notificationType.description
    
    // 関数のreturnの後に戻したい値を記述しておけば関数を呼び出した際に値を算出することができる
    guard let notificationDate = getNotificationTimeStamp() else { return }
    
    let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
    attributedText.append(NSAttributedString(string: " \(notificationMessage)"  , attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
    attributedText.append(NSAttributedString(string: " \(notificationDate)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
    notificationLabel.attributedText = attributedText
    
  }
  
  func configureNotificationType (){
    
    guard let notification = self.notification else {return}
    guard let user = notification.user else {return}
    
    //この制約がないとクラッシュしてしまう
    //var anchor : NSLayoutXAxisAnchor!
    
      if notification.notificationType != .Follow {
        
        //画像を表示する
        addSubview(postImageView)
        postImageView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 40, height: 40)
        postImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.followButton.isHidden = true
        self.postImageView.isHidden = false
        //この制約がないとクラッシュしてしまう
       // anchor = postImageView.leftAnchor
        
      } else {
    
      //フォローボタンを追加する
      addSubview(followButton)
      followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
      followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
      followButton.layer.cornerRadius = 3
      self.followButton.isHidden = false
      self.postImageView.isHidden = true

      //この制約がないとクラッシュしてしまう
      //anchor = followButton.leftAnchor
        
        user.checkIfUserIsFollowed(completion:  { (followed) in
          
          //Notification画面で、フォローの状態によってボタンの表示内容を変更する
          if followed {
            
            //configure follow button for follow user
            self.followButton.setTitle("Following", for: .normal)
            self.followButton.setTitleColor(.black, for: .normal)
            self.followButton.layer.borderWidth = 0.5
            self.followButton.layer.borderColor = AppColors.lightGray.cgColor
            self.followButton.setTitleColor(.black, for: .normal)
            self.followButton.backgroundColor = AppColors.white
            
          } else {
            
            //configure follow button for non follow user
            self.followButton.setTitle("Follow", for: .normal)
            self.followButton.setTitleColor(AppColors.white, for: .normal)
            self.followButton.layer.borderWidth = 0
            self.followButton.backgroundColor = AppColors.blue
            
       }
     })
   }
    
    addSubview(notificationLabel)
    notificationLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 100, width: 0, height: 0)
    notificationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    
  }
  
  func getNotificationTimeStamp() -> String? {
    
    guard let notification = self.notification else { return nil }
    
    let dateFormatter = DateComponentsFormatter()
    dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
    dateFormatter.maximumUnitCount = 1
    dateFormatter.unitsStyle = .abbreviated
    let now = Date()
    return dateFormatter.string(from: notification.creationDate, to: now)
    
  }
  
  //MARK: -Init
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    //選択されても灰色にならないようにする
    selectionStyle = .none
    
    addSubview(profileImageView)
    profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8  , paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
    profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    profileImageView.layer.cornerRadius = 40 / 2
  
  }
  
  required init?(coder aDecoder: NSCoder) {
    
    fatalError("init(coder:) has not been implemented")
    
  }
}


