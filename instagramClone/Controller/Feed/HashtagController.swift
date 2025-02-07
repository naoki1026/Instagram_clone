//
//  HashtagController.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/04/04.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "HashtagCell"

class HashtagController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  //MARK: Properties
  
  var posts = [Post]()
  var hashtag : String?
  

  //MARK: Int
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    configureNavigationBar()
    collectionView?.backgroundColor = .white
    collectionView?.register(HashtagCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    fetchPosts()

  }
  
  
  //MARK: UICollectionView
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    
    return 1
    
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (view.frame.width - 2 ) / 3
    return CGSize (width: width, height: width)
  }
  
  //MARK: UICollectionViewDataSource
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return posts.count
    
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HashtagCell
    
    cell.post = posts[indexPath.item]
    
    return cell
    
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
    
    //ここで１枚しか選択されていないという情報をFeedVCに送っている
    feedVC.viewSinglePost = true
    feedVC.post = posts[indexPath.item]
    navigationController?.pushViewController(feedVC, animated: true)
    
    
  }
  
  //MARK:Handlers
  
  func configureNavigationBar() {
    
    guard let hashtag = self.hashtag else {return}
    navigationItem.title = hashtag
    
    
  }
  
  //MARK: API
  func fetchPosts(){
    
    guard let hashtag = self.hashtag else {return}
    
    HASHTAG_POST_REF.child(hashtag).observe(.childAdded) {(snapshot) in
      
      let postId = snapshot.key
      
      Database.fetchPost(with: postId, completion: { (post) in
        self.posts.append(post)
        self.collectionView?.reloadData()
        
      })
      
    }
    
  }
  
  
  
}
