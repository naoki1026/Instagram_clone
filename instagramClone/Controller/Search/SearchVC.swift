//
//  SearchVCTableViewController.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/25.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "SearchUserCell"

class SearchVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  
  
  //MARK: -Properties
  var users = [User]()
  var filteredUsers = [User]()
  var searchBar = UISearchBar()
  var inSearchMode = false
  var collectionView : UICollectionView!
  var collectionViewEnabled = true
  var posts = [Post]()
  var currentKey: String?
  var userCurrentKey : String?
  

    override func viewDidLoad() {
        super.viewDidLoad()
      
      //セルを定義する、ここではSearchUserCell
      tableView.register(SearchUserCell.self, forCellReuseIdentifier: "SearchUserCell")
      
      //separator in sets
      //画像からセルの線を離す
      tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
    
      //configure search bar
      configureSearchBar()
      
      //configure collectionView
      configureCollectionView()
      
      //configure refresh control
      configureRefreshControll()
      
      //fetch posts
      fetchPosts()
      
//      //fetch users
//      fetchUsers()

    }

    // MARK: - Table view data source
  
  //セルの高さ
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }

  //セクションの数
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

  
  //セルの数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if inSearchMode {
        
        return filteredUsers.count
        
      } else {
        
        return  users.count
      }
    }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    if users.count > 3 {
      
      if indexPath.item == users.count - 1 {
        
        fetchUsers()
      }
      
    }
    
    
  }
  
  //セルをタップしたときの処理
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    var user : User!
    
    if inSearchMode {
      
      user = filteredUsers[indexPath.row]
    } else {
      
      user = users[indexPath.row]
    }
    
//    //選択されたセルのユーザーですよ
//    let user = users[indexPath.row]
    
    //create instance of user profile vc
    let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
    
    //ユーザ情報をUserProfileVCに渡す
    userProfileVC.user = user
    
    //プロフィール画面を表示する
    navigationController?.pushViewController(userProfileVC, animated: true)
  }
  
  //セルの中身
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for:  indexPath) as! SearchUserCell
    
    var user: User!
    
    //ここでは配列のインデックスに合わせて名前を画像が表示されるようになる
    //cell.user = users[indexPath.row]
    
    if inSearchMode {
      
      user = filteredUsers[indexPath.row]
    } else {
      
      user = users[indexPath.row]
    }
    
    cell.user = user
    return cell
  }
  
  //UICollectionView
  
  func configureCollectionView(){
    
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    
    let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - (tabBarController?.tabBar.frame.height)! - (navigationController?.navigationBar.frame.height)! - 45)
    
    collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.alwaysBounceVertical = true
    collectionView.backgroundColor = .white
    
    tableView.addSubview(collectionView)
    collectionView.register(SearchPostCell.self, forCellWithReuseIdentifier: "SearchPostCell")
    tableView.separatorColor = .clear
    
  }
  
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
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
    if posts.count > 20  {
      if indexPath.item == posts.count - 1 {
        
        fetchPosts()
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return posts.count
    
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchPostCell", for: indexPath) as! SearchPostCell
    
    cell.post = posts[indexPath.item]
 
    return cell
    
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
    
    //ここで１枚しか選択されていないという情報をFeedVCに送っている
    feedVC.viewSinglePost = true
    feedVC.post = posts[indexPath.item]
    navigationController?.pushViewController(feedVC, animated: true)
    
  }
  
  //MARK: Handlers
  
  //サーチバーの追加について
  func configureSearchBar (){
    
    searchBar.sizeToFit()
    searchBar.delegate = self
    navigationItem.titleView = searchBar
    searchBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    searchBar.tintColor = .black
    
  }
  
  //MARK:UISearchBar
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = true
    
    fetchUsers()
    
    collectionView.isHidden = true
    collectionViewEnabled = false
    tableView.separatorColor = AppColors.lightGray
    
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    //handle search text change
    let searchText = searchText.lowercased()
    if searchText.isEmpty || searchText == "" {
      inSearchMode = false
      tableView.reloadData()
    } else {
      
      inSearchMode = true
      filteredUsers = users.filter({ (user) -> Bool in
        return user.username.contains(searchText)
      })
      
      tableView.reloadData()
    }
    
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    
    //この並べる順番は大事
    searchBar.endEditing(true)
    searchBar.showsCancelButton = false
    searchBar.text = nil
    inSearchMode = false
    
    collectionViewEnabled = true
    collectionView.isHidden = false
    tableView.separatorColor = .clear
    
    tableView.reloadData()
  
  }
  
  //MARK: Handlers
  
  //MARK: Handlers
  @objc func handleRefresh(){
    posts.removeAll(keepingCapacity: false)
    self.currentKey = nil
    fetchPosts()
    collectionView?.reloadData()
    //collectionView?.refreshControl?.endRefreshing()
  }
  
  func configureRefreshControll () {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    self.tableView?.refreshControl = refreshControl
    
  }
  
  
  
  //MARK: - API
  
  func fetchUsers() {
    
    if userCurrentKey == nil {
      
      USER_REF.queryLimited(toLast: 4).observeSingleEvent(of: .value) { (snapshot) in
        
        guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
        guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
        
        allObjects.forEach({ (snapshot) in
          let uid = snapshot.key
          
          Database.fetchUser(with: uid, completion: { (user) in
            self.users.append(user)
            self.tableView.reloadData()
            
          })
          
        })
        self.userCurrentKey = first.key
      }
      
    } else {
      
      USER_REF.queryOrderedByKey().queryEnding(atValue: self.userCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
        guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
        guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
        
        allObjects.forEach({ (snapshot) in
          let uid = snapshot.key
          
          if uid != self.userCurrentKey {
            
            Database.fetchUser(with: uid, completion: { (user) in
              self.users.append(user)
              self.tableView.reloadData()
              
            })
            
          }
          
        })
        
        self.userCurrentKey = first.key
        
      })
    }
    
  }
  
      
//      //snapshot value cast as dictionary
//      guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
//
//      //construct user
//      let user = User(uid: uid, dictionary: dictionary)
//
//      //append user data
//      self.users.append(user)
//
//      //reload our table view
//      self.tableView.reloadData()
      

  
  //画像データを取得してくる
  func fetchPosts(){
    
    if currentKey == nil {
      
      POSTS_REF.queryLimited(toLast: 21).observeSingleEvent(of: .value, with:  { (snapshot) in
         self.tableView.refreshControl?.endRefreshing()
        
      guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
      guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
        
       
        
        allObjects.forEach({ (snapshot) in
          let postId = snapshot.key
          
          Database.fetchPost(with: postId, completion: { (post) in
            self.posts.append(post)
            self.collectionView.reloadData()
          })
        })
        
        self.currentKey = first.key
        
      })
    } else {
      
      //paginate here
      POSTS_REF.queryOrderedByKey().queryEnding(atValue:  self.currentKey).queryLimited(toLast: 10).observeSingleEvent(of: .value, with:  { (snapshot) in
        guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
        guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
        
        allObjects.forEach({ (snapshot) in
          let postId = snapshot.key
        
        if postId != self.currentKey {
          
            Database.fetchPost(with: postId, completion: { (post) in
              self.posts.append(post)
              self.collectionView.reloadData()
            
          })
        }
      })
        self.currentKey = first.key
        
    })
  }
 }
  
}

//posts.removeAll()
//POSTS_REF.observe(.childAdded){(snapshot) in
//
//  let postId = snapshot.key
//
//  Database.fetchPost(with: postId, completion: { (post) in
//
//    self.posts.append(post)
//    self.collectionView.reloadData()
//
//  })
//
//}
