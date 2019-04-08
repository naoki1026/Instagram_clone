//
//  EditProfileController.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/04/06.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

class EditProfileController : UIViewController {
  
  
  //MARK:Properties
  
  var user : User?
  var imageChanged = false
  var usernameChanged = false
  var userProfileController : UserProfileVC?
  var updatedUsername : String?
  
  //プロフィール画面の左上に表示するぷプロフィール画像
  let profileImageView : CustomImageView = {
    
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = AppColors.lightGray
    return iv
  }()
  
  let changePhotoButton : UIButton = {
    
    let button = UIButton(type: .system)
    button.setTitle("Change Profile Photo", for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    button.addTarget(self, action: #selector(handleChangeProfile), for: .touchUpInside)
    
    return button
    
    }()
  
  let separatorView : UIView = {
    
    let view = UIView()
    view.backgroundColor = AppColors.lightGray
    return view
    
  }()
  
  let usernameTextField : UITextField = {
    
    let tf = UITextField()
    tf.textAlignment = .left
    tf.borderStyle = .none
    return tf
    
    
  }()
  
  
  let fullnameTextField : UITextField = {
    
    let tf = UITextField()
    tf.textAlignment = .left
    tf.borderStyle = .none
    tf.isUserInteractionEnabled = false
    return tf
    
  }()
  
  let usernameLabel : UILabel = {
    
    let label = UILabel()
    label.text = "Username"
    label.font = UIFont.systemFont(ofSize: 16)
    return label
    
  }()
  
  let fullnameLabel : UILabel = {
    
    let label = UILabel()
    label.text = "Full Name"
    label.font = UIFont.systemFont(ofSize: 16)
    return label
    
  }()
  
  let fullnameSeparatorView : UIView = {
    
    let view = UIView()
    view.backgroundColor = AppColors.lightGray
    return view
    
  }()
  
  let usernameSeparatorView : UIView = {
    
    let view = UIView()
    view.backgroundColor = AppColors.lightGray
    return view
    
  }()
  
  
  
  //MARK:Init
  override func viewDidLoad(){
    super.viewDidLoad()
    
    view.backgroundColor = AppColors.white
    configureNavigationBar()
    
    configureViewComponents()
    
    usernameTextField.delegate = self
    
    loadUserData()
  }
  
  //Handlers
  @objc func handleChangeProfile(){
    
 let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.allowsEditing = true
    present(imagePickerController, animated: true, completion: nil)
  }
  
  
  
  @objc func handleCancel (){
    self.dismiss(animated: true, completion: nil)
    
    
  }
  
  @objc func handleDone(){
    
   view.endEditing(true)
    if usernameChanged {
      
      updateUsername()
      
    }
    
    if imageChanged {
      
      updateProfileImage()
      
    }
 
    
  }
  
  func loadUserData(){
    
    guard let user = self.user else {return}
    profileImageView.loadImage(with: user.profileImageUrl)
    fullnameTextField.text = user.name
    usernameTextField.text = user.username
    
    
  }

  func configureNavigationBar() {
    
    navigationItem.title = "Edit Profile"
    
    navigationController?.navigationBar.tintColor = AppColors.black
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleDone))

  }
  
  func configureViewComponents(){
    
    view.backgroundColor = AppColors.white
    
    let frame = CGRect(x: 0, y: 65, width: view.frame.width, height: 180)
    let containerView = UIView(frame: frame)
    
    //いい感じの色になるみたい
    containerView.backgroundColor = UIColor.groupTableViewBackground
    view.addSubview(containerView)
    
    containerView.addSubview(profileImageView)
    profileImageView.anchor(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
    
    //centerXancro
    profileImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
    profileImageView.layer.cornerRadius = 80 / 2
    
    
    containerView.addSubview(changePhotoButton)
    changePhotoButton.anchor(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    changePhotoButton.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
    
    containerView.addSubview(separatorView)
    separatorView.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor , paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    
    view.addSubview(fullnameLabel)
    fullnameLabel.anchor(top: containerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0 )
    
    
    view.addSubview(usernameLabel)
      usernameLabel.anchor(top: fullnameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0 )
    
    view.addSubview(fullnameTextField)
    fullnameTextField.anchor(top: containerView.bottomAnchor, left: fullnameLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: (view.frame.width / 1.6), height: 0)
    
    view.addSubview(usernameTextField)
    usernameTextField.anchor(top: fullnameTextField.bottomAnchor, left: fullnameLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: (view.frame.width / 1.6), height: 0)
    
    view.addSubview(fullnameSeparatorView)
    fullnameSeparatorView.anchor(top: nil, left: fullnameTextField.leftAnchor, bottom: fullnameTextField.bottomAnchor, right: fullnameTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 12, width: 0, height: 0.5)
    
    view.addSubview(usernameSeparatorView)
    usernameSeparatorView.anchor(top: nil, left: usernameTextField.leftAnchor, bottom: usernameTextField.bottomAnchor, right: usernameTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 12, width: 0, height: 0.5)
 
  }
  
  
  
  
 //API
  
  func updateUsername(){
    
    
    guard let updatedUsername = self.updatedUsername else {return}
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    guard usernameChanged == true else {return}
    
    USER_REF.child(currentUid).child("username").setValue(updatedUsername) {(err, ref) in
      
      guard let userProfileController = self.userProfileController else {return}
      userProfileController.fetchCurrentUserData()
      self.dismiss(animated: true, completion: nil)
      
    }
    
    
    
  }
  
  func updateProfileImage() {
    guard imageChanged == true else { return }
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    guard let user = self.user else { return }
    
    Storage.storage().reference(forURL: user.profileImageUrl).delete(completion: nil)
    
    let filename = NSUUID().uuidString
    
    guard let updatedProfileImage = profileImageView.image else { return }
    guard let imageData = updatedProfileImage.jpegData(compressionQuality: 0.3) else { return }
    
    STORAGE_PROFILE_IMAGES_REF.child(filename).putData(imageData, metadata: nil) { (metadata, error) in
      
      if let error = error {
        print("Failed to upload image to storage with error: ", error.localizedDescription)
      }
      
      STORAGE_PROFILE_IMAGES_REF.child(filename).downloadURL(completion: { (url, error) in
        USER_REF.child(currentUid).child("profileImageUrl").setValue(url?.absoluteString, withCompletionBlock: { (err, ref) in
          
          guard let userProfileController = self.userProfileController else { return }
          userProfileController.fetchCurrentUserData()
          
          self.dismiss(animated: true, completion: nil)
          
        })
      })
    }
  }
}


extension EditProfileController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      
      profileImageView.image = selectedImage
      self.imageChanged = true
      
    }
    
    dismiss(animated: true, completion: nil)
  }
  
}

extension EditProfileController : UITextFieldDelegate {
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let user = self.user else {return}
    
    let trimmedString = usernameTextField.text?.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    guard user.username != trimmedString else {
      
      print("You did not change your username")
      usernameChanged = false
      return
      
    }
    
    guard trimmedString != "" else {
      print("ERROE: Please enter a valid username")
      usernameChanged = false
      return
    }
    
    updatedUsername = trimmedString?.lowercased()
    usernameChanged = true
    
  }
  
  
  
}
