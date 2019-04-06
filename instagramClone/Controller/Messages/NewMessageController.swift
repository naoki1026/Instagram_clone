//
//  NewMessageController.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/04/03.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "NewMessageCell"

class NewMessagesController : UITableViewController {
  
  //MARK:Properties
  var users = [User]()
  var messagesController : MessagesController?
  
  
  
  
  //MARK:Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureNavitagionBar()
    
    //register cell
    tableView.register(NewMessageCell.self, forCellReuseIdentifier: reuseIdentifier)
    
    //fetch users
    fetchUsers()
    
    
  }
  
  //MARK:UITableView
  
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 75
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NewMessageCell
    cell.user = users[indexPath.row]
    return cell
    
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    self.dismiss(animated: true) {
      
      let user = self.users[indexPath.row]
      
      self.messagesController?.showChatController(forUser:user)
      
    }
  }

  //MARK:Handlers
  
  func configureNavitagionBar(){
    
    navigationItem.title = "New message"
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    navigationItem.leftBarButtonItem?.tintColor = AppColors.black
  
  }
  
  @objc func handleCancel (){
    
    dismiss(animated: true, completion: nil)
    
  }
  
  //MARK:API
  
  func fetchUsers(){
    
    USER_REF.observe(.childAdded){(snapshot) in
      
      let uid = snapshot.key
      if uid != Auth.auth().currentUser?.uid {
        
        Database.fetchUser(with: uid, completion: { (user) in
          
          self.users.append(user)
          self.tableView.reloadData()
          
        })
        
        
      }
      
    }
    
  }
  
}
