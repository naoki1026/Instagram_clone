//
//  CustomImageView.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/30.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit

var imageCache = [String : UIImage]()

class CustomImageView : UIImageView {
  
  var lastImgUrlUsedToLoadImage : String?
  
  //UIImageをアップロードするときに使用する関数である
  //画像を取得するのは毎回ではなくて良いため、キャッシュを使用する
  func loadImage(with urlString : String) {
  
    // set image to nil、毎回呼ばれる
    self.image = nil
    
    //set lastImgUrlusedToLoadImage
    lastImgUrlUsedToLoadImage = urlString
    
    //キャッシュに画像が存在するかを確認する
    if let cachedImage = imageCache[urlString] {
      self.image = cachedImage
      return
      
    }
    
    //キャッシュが存在しない場合
    guard let url = URL(string:urlString) else {return}
    
    //画像を取得してくる
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      
      //エラーを扱う
      if let error = error {
        
        print("Failed to load image with error.", error.localizedDescription)
        
      }
      
      if self.lastImgUrlUsedToLoadImage != url.absoluteString {
        return
      }
      
      
      //画像
      guard let imageData = data else {return}
      
      //ユーザの画像を登録する
      let photoImage = UIImage(data: imageData)
      
      //キーと値を登録する
      //NSURL型をString型に変更する場合にabsoluteStringを使用する
      imageCache[url.absoluteString] = photoImage
      
      //画像を登録
      DispatchQueue.main.async {
        
        self.image = photoImage
        
      }
      
      //中断されている場合にタスクを再開する
      }.resume()
  }
  
  
  
  
}


