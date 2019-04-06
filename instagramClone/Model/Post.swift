//
//  Post.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/30.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

//アプリに以下の情報を読み込むための準備
import Firebase
import Foundation

class Post {
  
  var caption : String!
  var likes : Int!
  var imageUrl : String!
  var ownerUid : String!
  var creationDate : Date!
  var postId : String!
  var user : User?
  var didLike = false
  
  init(postId: String!, user : User, dictionary: Dictionary<String, AnyObject>){
    
    self.postId = postId
    
    self.user = user
    
    if let caption = dictionary["caption"] as? String {
      
    self.caption = caption
      
    }
    
    if let likes = dictionary["likes"] as? Int {
      
      self.likes = likes
    }
    
    if let imageUrl = dictionary["imageUrl"] as? String {
      
      self.imageUrl = imageUrl
    }
    
    if let ownerUid = dictionary["ownerUid"] as? String {
      
      self.ownerUid = ownerUid
    }
    
    if let creationDate = dictionary["creationDate"] as? Double {
      self.creationDate = Date(timeIntervalSince1970: creationDate)
      
    }
    
    
  }

  func adjustLikes(addLike: Bool, completion: @escaping(Int) -> ()){
    
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    guard let postId = self.postId else { return }

  //好きマークがクリックされた時に以下の処理が行われる
  if addLike {
    
    //send notification to server
    sendLikeNotificationToServer()

  //update user-likes structure
    USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1], withCompletionBlock: { (err, ref) in

      //updates post-likes structure
      POST_LIKES_REF.child(self.postId).updateChildValues([currentUid: 1], withCompletionBlock: { (err, ref) in

        self.likes = self.likes + 1
        self.didLike = true
        POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
        completion(self.likes)
        

      })
    })

  } else {
    
     //好きマークが解除された時に以下の処理が行われる
    
    //observe database for notification id to remove
    //DBからnotificationを取り除く
    USER_LIKES_REF.child(currentUid).child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
      
      //notification id to remove from server
      guard let notificationID = snapshot.value as? String else {return}
      
      //remove notification from server
      NOTIFICATIONS_REF.child(self.ownerUid).child(notificationID).removeValue(completionBlock: {(err, ref) in
        
        //remove like from user-like structure
        USER_LIKES_REF.child(currentUid).child(postId).removeValue(completionBlock : { (err, ref) in
          
          //remove like from post-like structure
          POST_LIKES_REF.child(self.postId).child(currentUid).removeValue(completionBlock : { (err, ref) in
            
            guard self.likes > 0 else {return}
            self.likes = self.likes - 1
            self.didLike = false
            POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
            completion(self.likes)
        
         })
       })
      })
    })
   }
 }
  
  //削除ボタンがクリックされた時の処理
  func deletePost(){
    
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    Storage.storage().reference(forURL: self.imageUrl).delete(completion: nil)
    USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
      let followerUid = snapshot.key
      USER_FEED_REF.child(followerUid).child(self.postId).removeValue()
      
    }
    
    USER_FEED_REF.child(currentUid).child(postId).removeValue()
    USER_POSTS_REF.child(currentUid).child(postId).removeValue()
    POST_LIKES_REF.child(postId).observe(.childAdded) { (snapshot) in
      
      let uid  = snapshot.key
    
    USER_LIKES_REF.child(uid).child(self.postId).observeSingleEvent(of: .value, with: {(snapshot) in
      
      guard let notificationId = snapshot.value as? String else {return}
      
      NOTIFICATIONS_REF.child(self.ownerUid).child(notificationId).removeValue(completionBlock: { (err, ref) in
      POST_LIKES_REF.child(self.postId).removeValue()
      USER_LIKES_REF.child(uid).child(self.postId).removeValue()
        
      })
    })
   }
    
    let words = caption.components(separatedBy: .whitespacesAndNewlines)
    for var word in words {
      
      if word.hasPrefix("#") {
        word = word.trimmingCharacters(in: .punctuationCharacters)
        word = word.trimmingCharacters(in: .symbols)
        
        HASHTAG_POST_REF.child(word).child(postId).removeValue()
        
      }
    }
    
    COMMENT_REF.child(postId).removeValue()
    POSTS_REF.child(postId).removeValue()
    
    
  }
  //好きマークがクリックされた時に処理される関数
  func sendLikeNotificationToServer() {
    
   
     guard let currentUid = Auth.auth().currentUser?.uid else {return}
     let creationDate = Int(NSDate().timeIntervalSince1970)
    
    //only send notification if like is for post that is not current users
    //自分の投稿に対しては処理が行われないようにするための分岐
    if currentUid != self.ownerUid {
      
      //notification values
      let values = ["checked" : 0,
                    "creationDate" : creationDate,
                    "uid" : currentUid,
                    "type" : LIKE_INT_VALUE,
                    "postId" : postId ] as [String : Any]
      
      //upload notification values to server
      //NOTIFICATIONS_REF.childByAutoId().updateChildValues(values)
      
      //notification database reference
      //childByAutoId()で自動的にnotificationIDが生成される
      let notificationRef = NOTIFICATIONS_REF.child(self.ownerUid).childByAutoId()
      
      //upload notification values to database
      notificationRef.updateChildValues(values, withCompletionBlock: {(err,ref) in
        USER_LIKES_REF.child(currentUid).child(self.postId).setValue(notificationRef.key)
        
      })
    }
  }
}
