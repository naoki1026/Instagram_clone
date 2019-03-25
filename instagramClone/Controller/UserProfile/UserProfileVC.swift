//
//  UIProfileVC.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/25.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  //Mark: -Properties

    override func viewDidLoad() {
        super.viewDidLoad()

      
      
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
      
        //カスタムヘッダーを登録する
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
      
      //background color
      self.collectionView.backgroundColor = .white

        //fetch user data
      fetchCurrentUserData()
    }
  
    // -MARK: UICollectionView

    //セクションは分けないため１としている
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }
  
  
  //ヘッダーの大きさを定義,rederenceと入力する
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    
    return CGSize(width: view.frame.width, height: 200)
    
  }
  
  //ヘッダーを宣言している
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    //ヘッダーの宣言
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
    //ヘッダーを返却している
    return header
  }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        return cell
    }
  
  //Mark: -API
  func fetchCurrentUserData(){
    
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    
    //print("Current user id is \(currentUid)")
    
    //Firebaseのusersのカテゴリの中のusernameの情報を取得してくるということをここでは表している
    //このsnapshotの中にユーザー名の情報が入っている
    Database.database().reference().child("users").child(currentUid).child("username").observeSingleEvent(of: .value) { (snapshot) in
      
      
      guard let username = snapshot as? String else {return}
       //ここでユーザー名が表示される
      //print(snapshot)
      self.navigationItem.title = username
      
    }
  }
}
