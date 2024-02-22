//
//  ZYImageManager.swift
//  PhotoBrowserKit
//
//  Created by Zoey Shi on 2017/5/29.
//  Copyright © 2017年 Zoey Shi. All rights reserved.
//  Copyright © 2021 FutureTap GmbH. All rights reserved.
//

import UIKit
import SDWebImage

class ZYImageManager: NSObject {

  func setImage(_ imageView: UIImageView?, imageUrl: URL?, placeHoder: UIImage?, complete: @escaping ((_ image: UIImage?, _ url: URL?) -> Void)) {
	  imageView?.sd_setImage(with: imageUrl, placeholderImage: placeHoder, options: []) { (image, _, _, url) in
		  complete(image, url)
	  }
  }

  func imageFromMemoryForURL(_ url: URL) -> UIImage? {
	  let key = SDWebImageManager.shared.cacheKey(for: url)
	  return SDImageCache.shared.imageFromMemoryCache(forKey: key)
  }
}
