//
//  FeedVC.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/25.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController {
  
  // MARK: - Properties
  
  

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
      
      //configure logout button
      configureLogOutButton()

    }
  
  // MARK: -UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        return cell
    }

  // MARK: -Handlers
  
  func configureLogOutButton() {
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    
  }
  
  @objc func handleLogout(){
    
    //declare alret controller
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    //add alret logout action
    alertController.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { (_) in
      
      do {
        //サインアウトを試みる
        try Auth.auth().signOut()
        
       let loginVC = LoginVC()
        
        //present login controller
        let navController = UINavigationController(rootViewController: loginVC)
        self.present(navController, animated: true, completion: nil)
        print("Successfully logged user out")
        
      } catch {

        //handle error
        print("Falied to sign out")
        
      }
    }))
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alertController, animated: true, completion: nil)
    
  }

}
