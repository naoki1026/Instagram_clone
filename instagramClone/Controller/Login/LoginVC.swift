//
//  LoginVC.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/20.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate {
  
  let logoContainerView : UIView = {
    
    let view = UIView()
    let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
    logoImageView.contentMode = .scaleAspectFill
    view.addSubview(logoImageView)
    logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
    
    //水平、垂直、
    logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    view.backgroundColor = AppColors.green
    return view
    
  }()
  
  //テキストの設定(名前の入力欄）
  let emailTextField : UITextField = {
    
    let tf = UITextField()
    
    //textの背景に表示したい文字
    tf.placeholder = "Email"
    
    //背景の色
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    
    //アウトラインを表示
    tf.borderStyle = .roundedRect
    
    //フォントの種類とサイズを設定
    tf.font = UIFont.systemFont(ofSize: 14)
    
    //正しく入力されていることを確認
    tf.addTarget(self, action: #selector(formaValidation), for: .editingChanged)
    
    return tf
    
  }()
  
  //テキストの設定（パスワードの入力欄）
  let passwordTextField : UITextField = {
    
    let tf = UITextField()
    tf.placeholder = "Password"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.addTarget(self, action: #selector(formaValidation), for: .editingChanged)
    tf.isSecureTextEntry = true
    
    return tf
    
  }()
  
  let loginButton : UIButton = {
    
    let button = UIButton(type: .system)
    button.setTitle("Login", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = AppColors.lightBlue
    button.addTarget(self, action:#selector(handlelogin), for: .touchUpInside)
    button.layer.cornerRadius = 5
    button.isEnabled = false
    return button
    
  }()
  
  //attributeは属性
  let dontHaveAccountButton : UIButton = {
  let button = UIButton(type: .system)
    
  let attributedTitle = NSMutableAttributedString(string: "Don't have an account?", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    
    attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: AppColors.lightBlue]))
    
    //ボタンがタップされたタイミングでhandleShowSignUp関数が発動する
    button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
    button.setAttributedTitle(attributedTitle, for: .normal)
    return button
    
  }()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      //背景色を設定する
      view.backgroundColor = .white
      
      //AppDelegateで設定されたナビゲーションバーを非表示にする
      navigationController?.navigationBar.isHidden = true
      
      //テキストを表示させる
      view.addSubview(emailTextField)
      view.addSubview(logoContainerView)
      configureViewComponent()
      logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
      
      view.addSubview(dontHaveAccountButton)
      dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
      
      emailTextField.delegate = self
      passwordTextField.delegate = self
      
      //emailTextFieldに対して制約を設定する
//     emailTextField.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 40)
    
  }
  
  @objc func handleShowSignUp () {
    
    //print("Handle show sign up here...")
    let signUpVC = SignUpVC()
    navigationController?.pushViewController(signUpVC, animated: true)
  }
  
  @objc func handlelogin() {
    
    guard let email = emailTextField.text,
      let password = passwordTextField.text else { return }
    
    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
      
      
      //エラーの場合
      if let error = error {
        print("Unable to sign user in with error", error.localizedDescription)
        return
        }
      
      //成功した場合
       print("successfully signed user in")
//      let mainTabVC = MainTabVC()
//      self.present(mainTabVC, animated: true, completion: nil)
      
      //最前面のViewControllerを取得
      guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else {return}
      
      //confiogure view controllers in maintabVC
      mainTabVC.configureViewControllers()
      
      //dismiss login controller
      self.dismiss(animated: true, completion: nil)
      
      }
    }
  
  @objc func formaValidation () {
    
    guard
    emailTextField.hasText,
      passwordTextField.hasText else {
        
        //入力内容を満たしていない場合
        loginButton.isEnabled = false
        loginButton.backgroundColor = AppColors.lightBlue
        return
    }
    
       //正しく入力されている場合
       loginButton.isEnabled = true
       loginButton.backgroundColor = AppColors.blue
       return
  }
  
  func configureViewComponent() {
    
    let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
    
    //axisは軸、distrubutionは配分
    stackView.axis = .vertical
    stackView.spacing = 10
    stackView.distribution = .fillEqually
    
    //ここでviewの大きさと位置を取り決めている
    view.addSubview(stackView)
    
    //ロゴのviewの下に合わせてトップを変更している
    stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
    
  }
}

extension LoginVC {
  
  //空いているところをクリックした時にキーボードを閉じる
  override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    emailTextField.resignFirstResponder()
    passwordTextField.resignFirstResponder()
    
  }
  
  //リターンキーをクリックした時にキーボードを閉じる
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    //キーボードを閉じる
    emailTextField.resignFirstResponder()
    passwordTextField.resignFirstResponder()
    
    return true
    
  }
  
}
