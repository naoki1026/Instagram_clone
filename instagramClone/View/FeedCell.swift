//
//  FeedCell.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/30.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase
import ActiveLabel

class FeedCell: UICollectionViewCell {
  
  var delegate : FeedCellDelegate?
  
  var post : Post?  {
    
    didSet {
      
      guard let ownerUid = post?.ownerUid else {return}
      guard let imageUrl = post?.imageUrl else {return}
      guard let likes = post?.likes else {return}
      
      Database.fetchUser(with: ownerUid) { (user) in
        //print(user)
        self.profileImageView.loadImage(with: user.profileImageUrl)
        self.usernameButton.setTitle(user.username, for: .normal)
        self.configurePostCaption(user: user)
        
      }
      
      postImageView.loadImage(with: imageUrl)
      likesLabel.text = "\(likes) likes"
      configureLikeButton()
      
    }
  }
  
  let  profileImageView: CustomImageView = {
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = .lightGray
    return iv
  }()
  
  lazy var usernameButton : UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Username", for: .normal)
    button.setTitleColor(AppColors.black, for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
    button.addTarget(self, action: #selector(handleUsernameTapped), for: .touchUpInside)
    return button
    
    }()
  
  lazy var optionsButton : UIButton = {
    let button = UIButton(type: .system)
    
    //optionbutton + 8
    button.setTitle("•••", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    button.addTarget(self, action: #selector(handleOptionsTapped), for: .touchUpInside)
    return button
    
  }()
  
  lazy var postImageView : CustomImageView = {
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = AppColors.lightGray
    
    //add gesture recognizer for doublt tap to like
    //表示されてる画像をダブルクリックすることでlikeということにする
    let likeTap = UITapGestureRecognizer(target: self, action:#selector(handleDoubleTapToLike))
    likeTap.numberOfTapsRequired = 2
    iv.isUserInteractionEnabled = true
    iv.addGestureRecognizer(likeTap)
    
    return iv
  }()
  
  lazy var likeButton : UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
    button.tintColor = AppColors.black
    button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
    return button
    
  }()
  
   lazy var commentButton : UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
    button.tintColor = AppColors.black
    button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
    return button
    
  }()
  
  let messageButton : UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "send2"), for: .normal)
    button.tintColor = AppColors.black
    button.addTarget(self, action: #selector(handleShowMessages), for: .touchUpInside)
    return button

  }()
  
  let savePostButton : UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
    button.tintColor = AppColors.black
    return button
    
  }()
  
  lazy var  likesLabel : UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 12)
    label.text = ""
    
    //add gesture recognizer
    let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleShowLikes))
    likeTap.numberOfTapsRequired = 1
    label.isUserInteractionEnabled = true
    label.addGestureRecognizer(likeTap)
    
    return label
  }()
  
  //MARK:ActiveLabelを適用
  let captionLabel : ActiveLabel = {
    
  let label = ActiveLabel()
  label.numberOfLines = 0
  return label
    
  }()
  
  let postTimeLabel  : UILabel = {
    let label  = UILabel()
    label.textColor = AppColors.lightGray
    label.font = UIFont.boldSystemFont(ofSize: 10)
    label.text = "2 DAYS AGO"
    return label
  }()
  
  override init(frame: CGRect){
  super.init(frame: frame)
    
    addSubview(profileImageView)
    profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
    profileImageView.layer.cornerRadius = 40 / 2
    
    addSubview(usernameButton)
    usernameButton.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    usernameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    
    addSubview(optionsButton)
    optionsButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
     optionsButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    
    addSubview(postImageView)
    postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0 )
    
    //これで正方形にしている
    postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
    
    configureActionButton()
    
    addSubview(likesLabel)
    likesLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: -4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0 )
    
    addSubview(captionLabel)
    captionLabel.anchor(top: likesLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    addSubview(postTimeLabel)
    postTimeLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
 
  }
  
  //MARK: Handlers
  
  @objc func handleUsernameTapped (){
    
    delegate?.handleUsernameTapped(for: self)
    
  }
  
  @objc func handleOptionsTapped (){
    
    delegate?.handleOptionsTapped(for: self)
  
  }
  
  @objc func handleLikeTapped (){
    
    delegate?.handleLikeTapped(for: self, isDoubleTap: false)
    
  }
  
  @objc func handleCommentTapped (){
    
    delegate?.handleCommentTapped(for: self)
    
  }
  
  
  @objc func handleShowMessages(){
    
    //delegate?.handleShowMessages(for: self)
    print("ok")
    
  }
  
  @objc func handleShowLikes(){
    
    delegate?.handleShowLikes(for: self)
    
  }
  
  //表示されている画像をダブルクリックすることで、likeにする
  @objc func handleDoubleTapToLike(){
    
    //２回画像をタップすることで、ハートマークを１回クリックすることと同様の処理を行う
    delegate?.handleLikeTapped(for:self, isDoubleTap: false)
    print("Handle doublt tap to like")
    
  }
  
  func configureLikeButton(){
    
    delegate?.handleConfigureLikeButton(for: self)
    
  }
  
  
  func configurePostCaption(user: User) {
    guard let post = self.post else { return }
    
    guard let caption = post.caption else { return }
    
    guard let username = post.user?.username else { return }
    
    
    // look for username as pattern
    let customType = ActiveType.custom(pattern: "^\(username)\\b")
    
    
    // enable username as custom type
    captionLabel.enabledTypes = [.mention, .hashtag, .url, customType]
    
    
    // configure usnerame link attributes
    captionLabel.configureLinkAttribute = { (type, attributes, isSelected) in
      var atts = attributes
      
      switch type {
      case .custom:
        atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
      default: ()
      }
      return atts
    }
    
    captionLabel.customize { (label) in
      
      label.text = "\(username)  \(caption)"
      label.customColor[customType] = .black
      label.font = UIFont.systemFont(ofSize: 12)
      label.textColor = .black
      captionLabel.numberOfLines = 2
      
    }
    
    postTimeLabel.text = post.creationDate.timeAgoToDisplay()
  }
  
//  func configurePostCaption(user: User){
//
//    guard let post = self.post else {return}
//    guard let caption = post.caption else {return}
//    guard let username = post.user?.username else {return}
//
//    //look for username as pattern
//    let customType = ActiveType.custom(pattern: "^\(username)\\b")
//
//    //enable username as custome type
//    captionLabel.enabledTypes = [.mention, .hashtag, .url, customType]
//
//    //configure username link attributes
//    captionLabel.configureLinkAttribute = {(type, attributes, isSelected)} in
//
//    var atts = attributes
//
//    switch type {
//
//    case .custom:
//
//      atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
//
//    default: ()
//
//    }
//
//     return atts
//
//    }
//
    //let label = UILabel()
    
//    let attributedText = NSMutableAttributedString(string: "\(username)  ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
//
//    attributedText.append(NSAttributedString(string: "\(caption)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
//    captionLabel.attributedText = attributedText
  
  func configureActionButton(){
    
    let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, messageButton])
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    
    addSubview(stackView)
    stackView.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
    
    addSubview(savePostButton)
    savePostButton.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 20, height: 24)
  }
  
   required init?(coder aDecoder: NSCoder) {
   fatalError("init(coder:) has not been implemented")
    
    
  }
  
    
}
