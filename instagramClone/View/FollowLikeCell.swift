//
//  FollowCell.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/28.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

// ここはほぼコピペ

import UIKit
import Firebase

class FollowLikeCell: UITableViewCell {
  
  var delegate : FollowCellDelegate?
  
  
  //MARK: -Properties
  
  var user : User? {
    
    didSet{
      
      guard let profileImageUrl = user?.profileImageUrl else {return}
      guard let username = user?.username else {return}
      guard let fullName = user?.name else {return}
      
      profileImageView.loadImage(with: profileImageUrl)
      
      self.textLabel?.text = username
      self.detailTextLabel?.text = fullName
      
      //hide follow button for current user
      //本人の場合にフォローボタンが表示されないようにする 
      if user?.uid == Auth.auth().currentUser?.uid {
        
        followButton.isHidden = true
        
      }
      
      user?.checkIfUserIsFollowed(completion: { (followed) in
        
        if followed {
          
          //configure follow button for follow user
          self.followButton.configure(didFollow: true)
         
          
        } else {
          
          //configure follow button for non follow user
          self.followButton.configure(didFollow: false)
          
        }
      })
    }
  }
  
  let profileImageView : CustomImageView = {
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = AppColors.lightGray
    return iv
  }()
  
  lazy var followButton : UIButton = {
    
    let button = UIButton(type: .system)
    button.setTitle("Loading", for: .normal)
    button.setTitleColor(AppColors.white, for: .normal)
    button.backgroundColor = AppColors.blue
    button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
    return button
  }()
  
  //MARK: -Handlers
  @objc func handleFollowTapped(){
  delegate?.handleFollowTapped(for: self)
    
  }
  
  //MARK: -Init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    
    addSubview(profileImageView)
    profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
    profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    profileImageView.layer.cornerRadius = 48 / 2
    
    addSubview(followButton)
    followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
    followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    followButton.layer.cornerRadius = 5

    
    textLabel?.text = "Username"
    detailTextLabel?.text = "Full name"
    
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
