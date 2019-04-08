//
//  UserProfileHeader.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/25.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {
  
  
  var delegate : UserProfileHeaderDelegate?
  
  var user: User? {
    
    //didSetは、プロパティの値がセットされたタイミングを検知することができる
    didSet {
      
    //フォロワーの情報を反映する
    setUserStats(for: user)
      
    //configure edit profile button
    configureEditProfileFollowButton()
      
      //プロフィール画像の表示
      let fullName = user?.name
      nameLabel.text = fullName
      
      guard let profileImageUrl = user?.profileImageUrl else {return}
      profileImageView.loadImage(with: profileImageUrl)
      
    }
  }
  
  //プロフィール画面の左上に表示するぷプロフィール画像
  let profileImageView : CustomImageView = {
    
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = AppColors.lightGray
    return iv
  }()
  
  let nameLabel : UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 12)
    return label
    
  }()
  
  let postsLabel : UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.textAlignment = .center
    
    
    let attributedText = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
    attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
    label.attributedText = attributedText
    return label
  
  }()
  
  //lazyにすることが重要
  lazy var followersLabel : UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.textAlignment = .center
    
    //add gesture recognizer
    //did setで最終的には表示されるようになるが、読み込むまでに時間がかかるため先に表示させておく
    let attributedText = NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
    attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
    label.attributedText = attributedText
    
    //ラベルのタップで反応する
    let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
    followTap.numberOfTapsRequired = 1
    label.isUserInteractionEnabled = true
    label.addGestureRecognizer(followTap)
    
    return label
    
  }()
  
  //lazyにすることが重要
  lazy var followingLabel : UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.textAlignment = .center
    
    //did setで最終的には表示されるようになるが、読み込むまでに時間がかかるため先に表示させておく
    let attributedText = NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
    attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
    label.attributedText = attributedText
    
    //ラベルのタップで反応する
    let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
    followTap.numberOfTapsRequired = 1
    label.isUserInteractionEnabled = true
    label.addGestureRecognizer(followTap)
    
    
    return label
  }()
  
  //lazyにすることが重要
  lazy var editProfileFollowButton : UIButton = {
    
    let button = UIButton(type: .system)
    button.setTitle("Loading", for: .normal)
    button.layer.cornerRadius = 5
    button.layer.borderColor = AppColors.lightGray.cgColor
    button.layer.borderWidth = 0.5
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    //Editボタンの文字の色を定義している
    button.setTitleColor(.black, for: .normal)
    button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
    
    
    return button
    
  }()
  
  let gridButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
    return button
  }()
  
  let listButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
    button.tintColor = UIColor(white: 0, alpha: 0.2)
    return button
  }()
  
  let bookmarkButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
    button.tintColor = UIColor(white: 0, alpha: 0.2)
    return button
  }()

  //MARK: Handlers
  
  @objc func handleFollowersTapped(){
  //サブクラスの関数
  delegate?.handleFollowersTapped(for: self)
    //print("Handlle followers tapped")

  }
  
  @objc func handleFollowingTapped(){
  //サブクラスの関数
  delegate?.handleFollowingTapped(for: self)
  
    
  }
  
  @objc func handleEditProfileFollow(){
    
  //サブクラスの関数
  delegate?.handleEditFollowTapped(for: self)
  }
  
  //中断にあるボタン３つ、その上下にある線を定義している
  func configureBottomToolBar(){
    
     let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
    
    let topDividerView = UIView()
    topDividerView.backgroundColor = AppColors.lightGray
    
    let bottomDividerView = UIView()
    bottomDividerView.backgroundColor = AppColors.lightGray
    
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    
    addSubview(stackView)
    addSubview(topDividerView)
     addSubview(bottomDividerView)
    
    addSubview(profileImageView)
    
    stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    
    topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    
    bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right:rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
  }
  
  //スタックビューとしてまとめている
  func configureUserStarts(){
    
    let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
    
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    addSubview(stackView)
    stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    
  }
  
  func setUserStats(for user: User?) {
    
    delegate?.setUserStats(for: self)
  
  }
  
  func configureEditProfileFollowButton() {
    
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    guard let user = self.user else {return}
    
    if currentUid == user.uid {
      
      //configure button as edit profile
      editProfileFollowButton.setTitle("Edit profile", for: .normal)
      
    } else {
      
      //configure button as edit profile
      editProfileFollowButton.setTitleColor(AppColors.white, for: .normal)
      editProfileFollowButton.backgroundColor = AppColors.blue
      
      user.checkIfUserIsFollowed (completion: {(followed) in
        
      if followed {
          
        self.editProfileFollowButton.setTitle("Following", for: .normal)
          
      } else {
          
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        
        }
      })
    }
  }
  
  //MARK: 初期化
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    //Profile imageの登録
    addSubview(profileImageView)
    profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
    profileImageView.layer.cornerRadius = 80 / 2
    
    //nameLabelの登録
    addSubview(nameLabel)
    nameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    configureUserStarts()
    
    addSubview(editProfileFollowButton)
    editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 12, paddingLeft: 8, paddingBottom: 0, paddingRight: 12, width: 0, height: 30)
    
    configureBottomToolBar()
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
