//
//  File.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/20.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

extension UIColor {
  
static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
  }
  
}

//UIButton自体にこの機能を追加してしまう
extension UIButton {
  
  func configure(didFollow: Bool) {
    
    
    if didFollow {
      
      //handle follow user
      self.setTitle("Following", for: .normal)
      self.setTitleColor(.black, for: .normal)
      self.layer.borderWidth = 0.5
      self.layer.borderColor = AppColors.lightGray.cgColor
      self.setTitleColor(.black, for: .normal)
      self.backgroundColor = AppColors.white
      
    } else {
      
      //handle unfollow user
      self.setTitle("Follow", for: .normal)
      self.setTitleColor(AppColors.white, for: .normal)
      self.layer.borderWidth = 0
      self.backgroundColor = AppColors.blue
      
    }
  }
}

extension UIViewController {
  
  func getMentionUser(withUsername username : String) {
    
    USER_REF.observe(.childAdded) {(snapshot) in
      let uid = snapshot.key
      USER_REF.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
        guard let dictionary = snapshot.value as? Dictionary <String, AnyObject> else {return}
        
        if username == dictionary["username"] as? String {
          Database.fetchUser(with: uid, completion: { (user) in
            let userProfileController = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileController.user = user
            self.navigationController?.pushViewController(userProfileController, animated: true)
            return
          })
        }
      })
    }
  }
  func uploadMentoionNotification (forPostId postId : String, withText text: String, isForComment: Bool) {
    
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    let creationDate = Int(NSDate().timeIntervalSince1970)
    let words = text.components(separatedBy: .whitespacesAndNewlines)
    
    var mentionIntegerValue : Int!
    
    if isForComment {
      mentionIntegerValue = COMMENT_MENTION_INT_VALUE
      
    } else {
      
      mentionIntegerValue = POST_MENTION_INT_VALUE
    }
    
    
    for var word in words {
      if word.hasPrefix("@") {
        word = word.trimmingCharacters(in: .symbols)
        word = word.trimmingCharacters(in: .punctuationCharacters)
        
        USER_REF.observe(.childAdded) { (snapshot) in
          let uid = snapshot.key
          
          USER_REF.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
            if word == dictionary["username"] as? String {
              
              let notificationValues = ["postId" : postId,
                                        "uid" : currentUid,
                                        "type" : mentionIntegerValue,
                                        "creationDate" : creationDate ] as [String : Any]
              
              if currentUid != uid {
                
                NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(notificationValues)
              }
            }
          })
        }
      }
    }
  }
}

extension Date {
  
  func timeAgoToDisplay() -> String {
    
   let secondsAgo = Int(Date().timeIntervalSince(self))
  
    let minute = 60
    let hour = 60 * minute
    let day = 24 * hour
    let week = 7 * day
    let month = 4 * week
    let quotient: Int
    let unit: String
    
    if secondsAgo < minute {
      quotient = secondsAgo
      //unit = "秒"
      unit = "SECONDS"
      
    } else if secondsAgo < hour {
        
      quotient = secondsAgo / minute
      //unit = "分"
      unit = "MIN"
        
    } else if secondsAgo < day {
      
      quotient = secondsAgo / hour
      //unit = "時間"
      unit = "HOUR"
      
    } else if secondsAgo < week {
      
      quotient = secondsAgo / day
      //unit = "日"
      unit = "DAY"
      
    } else if secondsAgo < month {
      
      quotient = secondsAgo / week
      //unit = "週"
      unit = "WEEK"
      
    } else {
      quotient = secondsAgo / month
      unit = "ヶ月"
      //unit = "MONTH"
      
    }
    
    //return "\(quotient)\(unit)前"
    return "\(quotient)\(unit)\(quotient == 1 ? "" : "")AGO"
    //return "\(quotient)\(unit)\(quotient == 1 ? "" : "分") 前"
    
  }
}

extension UIView {
  
  //オプショナルになっている理由は、毎回、必ずしも必要ではないものが含まれているためである
  
  func anchor (top: NSLayoutYAxisAnchor?,
               left: NSLayoutXAxisAnchor?,
               bottom: NSLayoutYAxisAnchor?,
               right: NSLayoutXAxisAnchor?,
               paddingTop: CGFloat,
               paddingLeft: CGFloat,
               paddingBottom: CGFloat,
               paddingRight: CGFloat,
               width: CGFloat,
               height: CGFloat) {
    
    //AutoLayoutの解除の有無、falseで解除しない、trueで解除する
    translatesAutoresizingMaskIntoConstraints = false
    
    if let top = top {
      
      self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
      
    }
    
    if let left = left {
      
      self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
      
    }
    
    if let bottom = bottom {
      
      self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingTop).isActive = true
      
    }
    
    if let right = right {
      
      self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
      
    }
    
    if width != 0 {
      
      widthAnchor.constraint(equalToConstant: width).isActive = true
      
    }
    
    if height != 0 {
      
      heightAnchor.constraint(equalToConstant: height).isActive = true
      
    }
  }
}

//Databaseに対して拡張している
extension Database {
  
  static func fetchUser(with uid : String, completion: @escaping(User) -> ()){
    
    
    USER_REF.child(uid).observeSingleEvent(of: .value) {(snapshot) in
      
      guard let dictionary = snapshot.value as? Dictionary<String,AnyObject> else {return}
      
      let user = User(uid: uid, dictionary: dictionary)
      
      completion(user)
      
    }

  }
  
  static func fetchPost(with postId: String, completion : @escaping(Post) ->()){
    
    POSTS_REF.child(postId).observeSingleEvent(of: .value) { (snapshot) in
      
      guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
      guard let ownerUid = dictionary["ownerUid"] as? String else {return}
      
      Database.fetchUser(with: ownerUid, completion: { (user) in
        
        let post = Post(postId: postId, user: user, dictionary: dictionary)
        
        completion(post)
        
      })
    }
  }
}
