//
//  NewMessageCell.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/04/03.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit

class NewMessageCell: UITableViewCell {
  
  
  //MARK:Properties
  var user : User? {
  
  didSet {
  
  
    guard let profileImageUrl = user?.profileImageUrl else {return}
    guard let username = user?.username else {return}
    guard let fullname =  user?.name else {return}
    
    profileImageView.loadImage(with: profileImageUrl)
    textLabel?.text = username
    detailTextLabel?.text = fullname
  
    }
  }
  
  
  let  profileImageView: CustomImageView = {
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = .lightGray
    return iv
  }()
  

  
  //MARK: Init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    
    
    selectionStyle = .none
    
    
    addSubview(profileImageView)
    profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
    profileImageView.layer.cornerRadius = 50 / 2
    profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
    textLabel?.text = "Naoki"
    detailTextLabel?.text = "Thank you, good bye"
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y , width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
    detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y , width: self.frame.width - 108, height: (detailTextLabel?.frame.height)!)
    
    textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
    detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
    detailTextLabel?.textColor = AppColors.lightGray
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
