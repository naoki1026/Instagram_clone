//
//  Protocols.swift
//  InstagramCopy
//
//  Created by Stephan Dowless on 2/7/18.
//  Copyright © 2018 Stephan Dowless. All rights reserved.
//


//プロトコル
protocol UserProfileHeaderDelegate {
  
  func handleEditFollowTapped(for header: UserProfileHeader)
  func setUserStats(for header: UserProfileHeader)
  func handleFollowersTapped(for header: UserProfileHeader)
  func handleFollowingTapped(for header: UserProfileHeader)
  
}

protocol FollowCellDelegate  {
  
  func handleFollowTapped(for cell : FollowLikeCell)
  
}

protocol FeedCellDelegate {
  
  func handleUsernameTapped(for cell: FeedCell)
  func handleOptionsTapped(for cell: FeedCell)
  func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool)
  func handleCommentTapped(for cell: FeedCell)
  //func handleShowMessages(for cell: FeedCell)
  func handleConfigureLikeButton(for cell : FeedCell)
  func handleShowLikes(for:FeedCell)
  
}

protocol NotificationCellDelegate {
  
  func handlePostTapped(for cell: NotificationCell)
  func handleFollowTapped(for cell: NotificationCell)
}

protocol Printable {
  
  var description: String {get}
  
}

protocol CommentInputAccesoryViewDelegate {
  func didSubmit(forComment comment : String)
}
