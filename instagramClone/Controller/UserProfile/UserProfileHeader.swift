//
//  UserProfileHeader.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/25.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit

class UserProfileHeader: UICollectionViewCell {
  
  //プロフィール画面の左上に表示するぷプロフィール画像
  let profileImageView : UIImageView = {
    
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = AppColors.lightGray
    return iv
  }()
  
  let nameLabel : UILabel = {
    let label = UILabel()
    //表示する文字をここに定義している
    label.text =  "Health Ledger"
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
  
  let followersLabel : UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.textAlignment = .center
    let attributedText = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
    attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
    label.attributedText = attributedText
    return label
  }()
  
  let followingLabel : UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.textAlignment = .center
    let attributedText = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
    attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
    label.attributedText = attributedText
    return label
  }()
  
  let editProfileButton : UIButton = {
    
    let button = UIButton(type: .system)
    button.setTitle("Edit Profile", for: .normal)
    button.layer.cornerRadius = 5
    button.layer.borderColor = AppColors.lightGray.cgColor
    button.layer.borderWidth = 0.5
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    
    //Editボタンの文字の色を定義している
    button.setTitleColor(.black, for: .normal)
    
    
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
    
  addSubview(editProfileButton)
  editProfileButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 12, paddingLeft: 8, paddingBottom: 0, paddingRight: 12, width: 0, height: 30)
    
    configureBottomToolBar()
    
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
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
