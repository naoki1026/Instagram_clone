//
//  MessagesVC.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/04/03.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "MessagesCell"


class MessagesController : UITableViewController {
  
  //MARK:Properties
  var messages = [Message]()
  var messagesDictionary = [String : Message]()
  
  
  //:MARK Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureNavitagionBar()
    
    //register cell
    tableView.register(MessagesCell.self, forCellReuseIdentifier: reuseIdentifier)
    
    fetchMessages()
    
  }
  
  //MARK:UITableView
  
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 75
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MessagesCell
    cell.message = messages[indexPath.row]

    return cell
    
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let message = messages[indexPath.row]
    let chatPartnerId = message.getChatPartnerId()
    Database.fetchUser(with: chatPartnerId) { (user) in
      self.showChatController(forUser: user)
    }
    
  }
  
  //MARK: Handlers
  @objc func handleNewMessages(){
    
    let newMessagesController = NewMessagesController()
    newMessagesController.messagesController = self
    let navigationController = UINavigationController(rootViewController: newMessagesController)
    self.present(navigationController, animated: true, completion: nil)
    
  }
  
  func showChatController(forUser user: User) {
    
    let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
    chatController.user = user
    navigationController?.pushViewController(chatController, animated: true)
    
  }
  
  func configureNavitagionBar(){
    
    navigationItem.title = "Messages"
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessages))
    
  }
  
  //MARK: API
  
  func fetchMessages(){
    
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    
    self.messages.removeAll()
    self.messagesDictionary.removeAll()
    self.tableView.reloadData()
    
    USER_MESSAGES_REF.child(currentUid).observe(.childAdded) {(snapshot) in
      
      let uid = snapshot.key
      
      USER_MESSAGES_REF.child(currentUid).child(uid).observe(.childAdded, with: { (snapshot) in
      
        let messageId = snapshot.key
        
        self.fetchMessage(withMessageId : messageId)
        
      })
    }
  }
  
  
  func fetchMessage(withMessageId messageId: String ){
    MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
      
      guard let dictionary = snapshot.value as? Dictionary < String, AnyObject > else {return}
      
      let message = Message( dictionary : dictionary )
      
      let chatPatrnerId = message.getChatPartnerId()
      self.messagesDictionary[chatPatrnerId] = message
      self.messages = Array(self.messagesDictionary.values)
      
      //self.messages.append(message)
      self.tableView?.reloadData()
      
    }
    
  }
 
}
