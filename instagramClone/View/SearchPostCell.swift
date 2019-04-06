//
//  SearchPhotoCell.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/04/03.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit

class SearchPostCell: UICollectionViewCell {
  
  var post: Post? {
    
    didSet {
      
      //これが表示されるべき画像+１表示される理由は、異なる関数でそれぞれセルがreload
      //されているためである
      //print("Old set post")
      
      guard let imageUrl = post?.imageUrl else {return}
      postImageView.loadImage(with: imageUrl)
      
    }
  }
  
  let postImageView : CustomImageView = {
    
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = AppColors.lightGray
    return iv
  }()
  
  override init(frame: CGRect){
    super.init(frame:frame)
    
    addSubview(postImageView)
    postImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    
    fatalError("init(coder:) has not been implemented")
    
  }
  
}
