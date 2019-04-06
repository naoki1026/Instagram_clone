//
//  MessagesCell.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/04/03.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

class MessagesCell: UITableViewCell {
  
  //MARK: Properties
  
  var message: Message? {
    
    didSet{
      
      guard let messageText = message?.messageText else {return}
      detailTextLabel?.text = messageText
      
      if let seconds = message?.creationDate {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        timeStampLabel.text = dateFormatter.string(from: seconds)
        
      }
      
      configureUserData()
      
    }
    
  }
  
  let  profileImageView: CustomImageView = {
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = .lightGray
    return iv
  }()
  
  let timeStampLabel : UILabel = {
    
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = .darkGray
    label.text = "2d."
    return label
    
  }()
  

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    
    selectionStyle = .none
    
    
  addSubview(profileImageView)
  profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
  profileImageView.layer.cornerRadius = 50 / 2
  profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
  addSubview(timeStampLabel)
  timeStampLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
    
  textLabel?.text = "Naoki"
  detailTextLabel?.text = "Some test label to see if this works"
    
  }
  
  override func layoutSubviews() {
    
    //最初に呼び出さないとクラッシュしてしまう
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
  
  //MARK: Handlers
  func configureUserData(){
    
    guard let chatPartnerId = message?.getChatPartnerId() else {return}
    
    Database.fetchUser(with: chatPartnerId) { (user) in
      self.profileImageView.loadImage(with: user.profileImageUrl)
      self.textLabel?.text = user.username
    }
    
  }
  
}
