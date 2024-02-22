//
//  ZYPhotoItem.swift
//  PhotoBrowserKit
//
//  Created by Zoey Shi on 2017/5/29.
//  Copyright © 2017年 Zoey Shi. All rights reserved.
//

import UIKit

@objc public class ZYPhotoItem: NSObject {
	public var thumbImage: UIImage?
	public var image: UIImage?
	public var imageURL: URL?
	public var finished: Bool = false
	public var sourceView: UIView?
}
