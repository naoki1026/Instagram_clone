//
//  Constants.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/20.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

struct AppColors {
  
  static let green = UIColor(red: 0, green: 120/255, blue: 175/255, alpha: 1)
  static let lightBlue =  UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
  static let blue =  UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
  static let lightGray = UIColor.lightGray
  static let white = UIColor.white
  static let black = UIColor.black
  
}
  
  // MARK: - Root References
  let DB_REF = Database.database().reference()
  let STORAGE_REF = Storage.storage().reference()
  let STORAGE_PROFILE_IMAGE_REF = STORAGE_REF.child("profile_images")
  
  // MARK: - Storage References
  let STORAGE_PROFILE_IMAGES_REF = STORAGE_REF.child("profile_images")
  let STORAGE_MESSAGE_IMAGES_REF = STORAGE_REF.child("message_images")
  let STORAGE_MESSAGE_VIDEO_REF = STORAGE_REF.child("video_messages")
  let STORAGE_POST_IMAGES_REF = STORAGE_REF.child("post_images")
  
  // MARK: - Database References
  
  let USER_REF = DB_REF.child("users")
  
  let USER_FOLLOWER_REF = DB_REF.child("user-followers")
  let USER_FOLLOWING_REF = DB_REF.child("user-following")
  
  let POSTS_REF = DB_REF.child("posts")
  let USER_POSTS_REF = DB_REF.child("user-posts")
  
  let USER_FEED_REF = DB_REF.child("user-feed")
  
  let USER_LIKES_REF = DB_REF.child("user-likes")
  let POST_LIKES_REF = DB_REF.child("post-likes")

  
  let COMMENT_REF = DB_REF.child("comments")
  
  let NOTIFICATIONS_REF = DB_REF.child("notifications")
  
  let MESSAGES_REF = DB_REF.child("messages")
  let USER_MESSAGES_REF = DB_REF.child("user-messages")
//  let USER_MESSAGE_NOTIFICATIONS_REF = DB_REF.child("user-message-notifications")
//  
  let HASHTAG_POST_REF = DB_REF.child("hashtag-post")
//  
  // MARK: - Decoding Values
  let LIKE_INT_VALUE = 0
  let COMMENT_INT_VALUE = 1
  let FOLLOW_INT_VALUE = 2
  let COMMENT_MENTION_INT_VALUE = 3
  let POST_MENTION_INT_VALUE = 4



