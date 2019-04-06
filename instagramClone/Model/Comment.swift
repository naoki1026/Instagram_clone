//
//  Comment.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/04/01.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import Foundation
import Firebase

class Comment {
  
  var uid : String!
  var commentText : String!
  var creationDate : Date!
  var user : User?
  
  init(user: User, dictionary: Dictionary <String, AnyObject> ) {
    
    self.user = user
    
    if let uid = dictionary["uid"] as? String {
      
      self.uid = uid
      
//      Database.fetchUser(with: uid, completion: {(user) in
//        self.user = user

    }
    
    if let commentText = dictionary["commentText"] as? String {
      self.commentText = commentText
      
    }
    
    if let creationDate = dictionary["creationDate"] as? Double {
      self.creationDate = Date(timeIntervalSince1970: creationDate)
    }
    
  }
  
  
  
  
  
  
}
