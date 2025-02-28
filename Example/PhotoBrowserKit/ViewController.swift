//
//  ViewController.swift
//  PhotoBrowserKit
//
//  Created by Zoey Shi on 2017/5/29.
//  Copyright © 2017年 Zoey Shi. All rights reserved.
//

import UIKit
import PhotoBrowserKit

class ViewController: UIViewController {

  @IBOutlet weak var collectionView:UICollectionView!
  fileprivate var urls:[String] = []
  fileprivate var url2:[String] = []
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Photo Browser"
    self.view.backgroundColor = UIColor.white
    collectionView.backgroundColor = UIColor.white
    collectionView.delegate = self
    collectionView.dataSource = self
	  urls = ["http://ww4.sinaimg.cn/bmiddle/a15bd3a5jw1f12r9ku6wjj20u00mhn22.jpg",
			  "http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1f01hkxyjhej20u00jzacj.jpg",
			  "http://ww4.sinaimg.cn/bmiddle/a15bd3a5jw1f01hhs2omoj20u00jzwh9.jpg",
			  "http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1ey1oyiyut7j20u00mi0vb.jpg",
			  "http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1exkkw984e3j20u00miacm.jpg",
			  "http://ww4.sinaimg.cn/bmiddle/a15bd3a5jw1ezvdc5dt1pj20ku0kujt7.jpg",
			  "http://ww3.sinaimg.cn/bmiddle/a15bd3a5jw1ew68tajal7j20u011iacr.jpg",
			  "http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1eupveeuzajj20hs0hs75d.jpg",
			  "http://ww2.sinaimg.cn/bmiddle/d8937438gw1fb69b0hf5fj20hu13fjxj.jpg",
			  "http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1eupveeuzajj20hs0hs75d.jpg",
			  "http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1ey1oyiyut7j20u00mi0vb.jpg",
			  "http://ww2.sinaimg.cn/bmiddle/d8937438gw1fb69b0hf5fj20hu13fjxj.jpg"
	  ]
	  
	  
    url2 = ["http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1eupveeuzajj20hs0hs75d.jpg",
            "http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1ey1oyiyut7j20u00mi0vb.jpg",
    "http://ww2.sinaimg.cn/bmiddle/d8937438gw1fb69b0hf5fj20hu13fjxj.jpg"]
    
  }

  @IBAction func reload(_ sender: Any) {
    self.collectionView.reloadData()
  }
}




// MARK: - UICollectionViewDelegate,UICollectionViewDataSource

extension ViewController: UICollectionViewDelegate,UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
    if let url = URL(string: urls[indexPath.row]) {
      cell.imageView.sd_setImage(with: url)
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return urls.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    var items: [ZYPhotoItem] = []
    for i in 0..<urls.count {
      let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? PhotoCell
      // big url
      let bigUrl = urls[i].replacingOccurrences(of: "bmiddle", with: "large")
      let item = ZYPhotoItem()
      // imageView
      item.sourceView = cell?.imageView
      item.imageURL = URL(string: bigUrl)
      item.thumbImage = cell?.imageView.image
      items.append(item)
    }
    

    var item2s: [ZYPhotoItem] = []
    for i in 0..<url2.count {
      let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? PhotoCell
      // big url
      let bigUrl = url2[i].replacingOccurrences(of: "bmiddle", with: "large")
      let item = ZYPhotoItem()
      // imageView
      item.sourceView = cell?.imageView
      item.imageURL = URL(string: bigUrl)
      item.thumbImage = cell?.imageView.image
      item2s.append(item)
    }
    
    let browser = ZYPhotoBrowser(photoItems: items, selectedIndex: indexPath.row)
    browser.showFromViewController(self)
    browser.photoItemGroup = [items,item2s]
    
    browser.delegate = self
  }
}

extension ViewController: ZYPhotoBrowserDelegate {
  func zy_photoBrowser(_ browser: ZYPhotoBrowser, didSelect item: ZYPhotoItem, at index: Int) {
    
    print("did selected index is \(index)")
    
  }
}






