//
//  SelectImageVC.swift
//  instagramClone
//
//  Created by Naoki Arakawa on 2019/03/29.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "SelectPhotoCell"
private let headerIdentifier = "SelectPhotoHeader"

class SelectImageVC : UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  //MARK: Properties
  var images = [UIImage]()
  var assets = [PHAsset]()
  var selectedImage : UIImage?
  var header : SelectPhotoHeader?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //register cell classes
    collectionView?.register(SelectPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    collectionView?.register(SelectPhotoHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    
    collectionView?.backgroundColor = AppColors.white
    
    //configure navbutton
    configureNavigationButton()
    
    //fetch Phots
    fetchPhotos()
    
  }
  
  //MARK: UICollectionViewFlowLayout
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    
    let width = view.frame.width
    return CGSize(width: width, height: width)
    
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let width = (view.frame.width - 3) / 4
    return CGSize(width: width, height: width)

  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 1
    
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 1
    
  }
  
  //MARK: UICollectionViewDataSource
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    //ライブラリに保存されている画像の分だけスクリーンに表示される
    return images.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! SelectPhotoHeader
    
    self.header = header
    
    //以下の記述することで中心の画像が表示されるようになる
    if let selectedImage = self.selectedImage {
      
      //header.photoImageView.image = selectedImage
      if let index = self.images.index(of: selectedImage) {
        
        //asset associated with selected image
        let selectedAsset = self.assets[index]
        
        //写真の解像度をよくしている
        let imageManager = PHImageManager.default()
        let targetSize = CGSize(width: 600, height: 600)
        
        //request image
        imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { (image, info) in
          
          header.photoImageView.image = image
            
        }
      }
    }
    
    return header
    
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SelectPhotoCell
    
    //ここで大きな画像より下の画像が表示されるようになる
    cell.photoImageView.image = images[indexPath.row]
    
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    //ここを追加することで選択した画面がヘッダー部分に表示されるようになる
    self.selectedImage = images[indexPath.row]
    self.collectionView.reloadData()
    
   //スクロール画面で選択したら上まで戻るようになっている
    let indexPath = IndexPath(item: 0, section: 0)
    collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    
  }
  
  //MARK: Handlers
  
  @objc func handleCancel () {
    
    self.dismiss(animated: true, completion: nil)
    
  }
  
  @objc func handleNext() {
    
    let uploadPostVC =  UploadPostVC()
    
    //解像度を変更した画像を指定している
    uploadPostVC.selectedImage = header?.photoImageView.image
    uploadPostVC.uploadAction = UploadPostVC.UploadAction(index: 0)
    navigationController?.pushViewController(uploadPostVC, animated: true)
    
  }
    
  //上のナビゲーションバーに表示する項目について定義
  func configureNavigationButton(){
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    
  }
  
  func getAssetFetchOptions() -> PHFetchOptions {
    
     let options = PHFetchOptions()
    
    //fetch limit
    options.fetchLimit = 45
    
    //sort photos by date
    let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
    
    //set sort descriptor for option
    options.sortDescriptors = [sortDescriptor]
    
    //return options
    return options
    
  }
  
  func fetchPhotos() {
    
    let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions())
    
    print("Function runnning")
    
    //fetch images on background thread
    DispatchQueue.global(qos: .background).async {
      
      //enumarate objects
      allPhotos.enumerateObjects({ (asset, count, stop) in
        
        //print("Count is \(count)")
        
        let imageManager = PHImageManager.default()
        let targetSize = CGSize(width: 200, height: 200)
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
        //request image representations specified asset
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
          
          if let image = image {
            
            //append image to data source
            self.images.append(image)
            
            //append assets to data source
            self.assets.append(asset)
            
            //set selected image
            if self.selectedImage == nil {
              self.selectedImage = image
            }
            
            //reload collection View with images once count has completed
            if count == allPhotos.count - 1 {
              
              //reload collection view on the main thread
              DispatchQueue.main.async {
                self.collectionView?.reloadData()
                
              }
              
            }
            
          }
          
        })
        
      })
      
    }
    
  }
  
}
