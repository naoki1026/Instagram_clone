//
//  SignUpVC.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/23.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

//pickercontrollerとnavigationControllerの２つのスーパークラスが必要
class SignUpVC: UIViewController,UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  var imageSelected = false
  
  let plusPhotoBtn : UIButton = {
    
    let button = UIButton(type: .system)
    //.withRendaringModeにすることで一色に塗りつぶされることを防ぐ
    button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
    button.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
    return button
    
  }()
  
  let emailTextField : UITextField = {
    
    let tf = UITextField()
    tf.placeholder = "Email"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
    
    return tf
    
  }()
  
  let passwordTextField : UITextField = {
    
    let tf = UITextField()
    tf.placeholder = "Password"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.isSecureTextEntry = true
    tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
    
    return tf
    
  }()
  
  let fullNameTextField : UITextField = {
    
    let tf = UITextField()
    tf.placeholder = "Fullname"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
    
    return tf
    
  }()
  
  
  let userNameTextField : UITextField = {
    
    let tf = UITextField()
    tf.placeholder = "Username"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
    
    return tf
    
  }()
  
  let signUpButton : UIButton = {
    
    let button = UIButton(type: .system)
    button.setTitle("Sign Up", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = AppColors.lightBlue
    button.layer.cornerRadius = 5
    button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
    button.isEnabled = false
    return button
    
  }()
  
  
  let alreadyHaveAccountButton : UIButton = {
    let button = UIButton(type: .system)
    
    let attributedTitle = NSMutableAttributedString(string: "Already have an account?", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    
    attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: AppColors.lightBlue]))
    
    button.setAttributedTitle(attributedTitle, for: .normal)
    button.addTarget(self, action: #selector(handleShowLogIn), for: .touchUpInside)
    return button
    
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //背景は白
    view.backgroundColor = .white
    
    view.addSubview(plusPhotoBtn)
    plusPhotoBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
    plusPhotoBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    
    view.addSubview(emailTextField)
    view.addSubview(passwordTextField)
    view.addSubview(fullNameTextField)
    view.addSubview(userNameTextField)
    
    emailTextField.delegate = self
    passwordTextField.delegate = self
    fullNameTextField.delegate = self
    userNameTextField.delegate = self
    
    
    configureViewComponent()
    
    view.addSubview(alreadyHaveAccountButton)
    alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    //selected image
    guard let profileImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
      
      imageSelected = false
      return
    }
    
    //set imageselected to true
    imageSelected = true
    
    //configure plus photoBtn with selected Image
    plusPhotoBtn.layer.cornerRadius = plusPhotoBtn.frame.width / 2
    plusPhotoBtn.layer.masksToBounds = true
    plusPhotoBtn.layer.borderColor = UIColor.black.cgColor
    plusPhotoBtn.layer.borderWidth = 2
    plusPhotoBtn.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
    self.dismiss(animated: true, completion: nil)
    
  }
  
  @objc func handleSelectProfilePhoto() {
    
    //イメージピッカーを表示するための準備
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    
    //イメージピッカーの表示
    self.present(imagePicker, animated: true, completion: nil)
    
  }
  
  @objc func handleShowLogIn () {
    
    //print("Handle show sign up here...")
    //let loginVC = LoginVC()
    //navigationController?.pushViewController(loginVC, animated: true)
    
    //遷移前の画面に戻る
    _ = navigationController?.popViewController(animated: true)
    
  }
  
  @objc func handleSignUp() {
    
    //print("Handle sign up here")
    //守るよ、もしもこれが空っぽだったらね、returnつまり終了させます！
    //ここで入力されたユーザー情報を変数の中に入れている
    guard let email = emailTextField.text else {return}
    guard let password = passwordTextField.text else {return}
    guard let fullName = fullNameTextField.text else {return}
    guard let userName = userNameTextField.text else {return}
    
    //メールアドレスとパスワードをもとにユーザーを作成している
    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
      
      if  let error = error {
        
        print("Faile to create user with error:", error.localizedDescription)
        return
        
      }
      //プロフィール画像を変数の中に入れている
      guard let profileImage = self.plusPhotoBtn.imageView?.image else {return}
      
      //upload data, JPEG形式にしてデータを返してくれる
      //guard let uploadData = UIImageJPEGRepresentation(profileImage, 0.3) else {return}
      guard let uploadData = profileImage.jpegData(compressionQuality: 0.3) else {return}
      
      //place image in firebase storage
      //アプリ内でユニークIDを作成している
      let filename = NSUUID().uuidString
      
      //firebase用に参照用のパスを作成している
      let storageRef = Storage.storage().reference().child("profile_images").child(filename)
      storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
        
        if let error = error {
          print("Faild to upload image to Firebase Storage with error", error.localizedDescription)
          return
         }
        
        // プロフィールイメージを特定のURLに登録している
        storageRef.downloadURL(completion: { (downloadURL, error) in
          guard let profileImageUrl = downloadURL?.absoluteString else {
            print("DEBUG: Profile image url is nil")
            return
          }
          
          //ユーザーIDを作成している
          guard let uid = Auth.auth().currentUser?.uid else { return }
         // guard let fcmToken = Messaging.messaging().fcmToken else { return }
          
          //辞書型で保有している
          let dictionaryValues = ["name": fullName,
                                  //"fcmToken": fcmToken,
                                  "username": userName,
                                  "profileImageUrl": profileImageUrl]
          
          //データベースにアップするためのデータをvaluesの中に入れている
          let values = [uid: dictionaryValues]
          
          // save user info to database
          Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, ref) in
              print("Successfully created user and saved information database")
            
            //guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else { return }
            
            // configure view controllers in maintabvc
            //mainTabVC.configureViewControllers()
            //mainTabVC.isInitialLoad = true
            
            // dismiss login controller
            //self.dismiss(animated: true, completion: nil)
            
          })
        })
      })
    }
  }
  
  
  @objc func formValidation() {
    
    //すべての条件が満たした場合に先に進める
    //画像だけが登録されていない状態で、画像登録後に再度パスワードを入力する必要がある
    guard emailTextField.hasText,
      passwordTextField.hasText,
      fullNameTextField.hasText,
      userNameTextField.hasText,
      imageSelected == true else {
        
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = AppColors.lightBlue
        
        return
        
    }
    
    signUpButton.isEnabled = true
    signUpButton.backgroundColor = AppColors.blue
    return
    
  }
  
  func configureViewComponent() {
    
    let stackView = UIStackView(arrangedSubviews: [emailTextField,fullNameTextField,userNameTextField,passwordTextField,signUpButton])
    
    //axisは軸、distrubutionは配分
    stackView.axis = .vertical
    stackView.spacing = 10
    stackView.distribution = .fillEqually
    
    //ここでviewの大きさと位置を取り決めている
    view.addSubview(stackView)
    
    //ロゴのviewの下に合わせてトップを変更している
    stackView.anchor(top: plusPhotoBtn.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 240)
    
  }
  
}

extension SignUpVC {
  
  //空いているところをクリックした時にキーボードを閉じる
  override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    emailTextField.resignFirstResponder()
    passwordTextField.resignFirstResponder()
    fullNameTextField.resignFirstResponder()
    userNameTextField.resignFirstResponder()
    
  }
  
  //リターンキーをクリックした時にキーボードを閉じる
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    //キーボードを閉じる
    emailTextField.resignFirstResponder()
    passwordTextField.resignFirstResponder()
    fullNameTextField.resignFirstResponder()
    userNameTextField.resignFirstResponder()
    
    return true
    
  }
  
}
