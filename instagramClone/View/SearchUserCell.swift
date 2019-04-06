//
//  SearchUserCell.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/28.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit

//UITableViewCellではセルの中身を定義している
class SearchUserCell: UITableViewCell {
  
  //MARK: -Properties
  
  var user : User? {
    
    didSet{
      
      guard let profileImageUrl = user?.profileImageUrl else {return}
      guard let username = user?.username else {return}
      guard let fullName = user?.name else {return}
      
      profileImageView.loadImage(with: profileImageUrl)
      
      self.textLabel?.text = username
      self.detailTextLabel?.text = fullName
    
    }
  }
  
  let profileImageView : CustomImageView = {
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = AppColors.lightGray
    return iv
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    
    //プロフィール画像を追加する
    addSubview(profileImageView)
    profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
    profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    profileImageView.layer.cornerRadius = 48 / 2
    
    self.textLabel?.text = "Username"
    self.detailTextLabel?.text = "Fullname"
    
    //セルを灰色にしない
    self.selectionStyle = .none
  }
  
  override func layoutSubviews() {
    
    super.layoutSubviews()
    
    textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
    
    textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
    
    detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y, width: self.frame.width - 108, height: detailTextLabel!.frame.height)
    
    detailTextLabel?.textColor = AppColors.lightGray
    detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
