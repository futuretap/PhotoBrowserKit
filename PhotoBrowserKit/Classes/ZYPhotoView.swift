//
//  ZYPhotoView.swift
//  PhotoBrowserKit
//
//  Created by Zoey Shi on 2017/5/29.
//  Copyright © 2017年 Zoey Shi. All rights reserved.
//  Copyright © 2021 FutureTap GmbH. All rights reserved.
//

import UIKit
import SDWebImage

class ZYPhotoView: UIScrollView {

	lazy var imageView: UIImageView = {
		let iv = UIImageView()
		iv.backgroundColor = .darkGray
		iv.contentMode = .scaleAspectFill
		iv.clipsToBounds = true
		return iv
	}()

	lazy var progressLayer: ZYProgressLayer = {
		let progressLayer = ZYProgressLayer(frame: CGRect(x: 0, y: 0, width: 40, height: 40) )
		progressLayer.isHidden = true
		return progressLayer
	}()

	var item: ZYPhotoItem?
	private let _imageManager: ZYImageManager

	init(frame: CGRect, imageManager: ZYImageManager ) {
		self._imageManager = imageManager
		super.init(frame: frame)
		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setup() {
		backgroundColor = UIColor.clear
		bouncesZoom = true
		maximumZoomScale = CGFloat(ZYConstant.photoViewMaxScale)
		isMultipleTouchEnabled = true
		showsHorizontalScrollIndicator = true
		showsVerticalScrollIndicator = true
		delegate = self

		addSubview(imageView)
		resizeImageView()
		layer.addSublayer(progressLayer)
		progressLayer.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
	}

	func setItem(_ item: ZYPhotoItem?, determinate: Bool) {
		self.item = item
		if let item = item {
			if let image = item.image {
				imageView.image = image
				item.finished = true
				progressLayer.stopSpin()
				progressLayer.isHidden = true
				resizeImageView()
				return
			}
			progressLayer.startSpin()
			progressLayer.isHidden = false
			imageView.image = item.thumbImage
			imageView.sd_setImage(with: item.imageURL, placeholderImage: item.thumbImage, options: []) { [weak self] (image, err, _, _) in
				guard let strongSelf = self else { return }
				if err == nil {
					strongSelf.resizeImageView()
					strongSelf.progressLayer.stopSpin()
					strongSelf.progressLayer.isHidden = true
					strongSelf.item?.finished = true
					strongSelf.item?.image = image
				} else {
					print(err?.localizedDescription ?? "")
				}
			}
		} else {
			progressLayer.stopSpin()
			progressLayer.isHidden = true
			imageView.image = nil
		}
		resizeImageView()
	}

	func resizeImageView() {
		if let image = imageView.image {
			imageView.frame = CGRect(origin: .zero, size: image.size.limiting(size: bounds.size))
			imageView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
		} else {
			let width = frame.width - 2 * ZYConstant.photoViewPadding
			imageView.frame = CGRect(x: 0, y: 0, width: width, height: width*2/3)
			imageView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
		}
		contentSize = imageView.frame.size
	}

	func isScrollViewOnTopOrBottom() -> Bool {
		let transition = panGestureRecognizer.translation(in: self)
		if transition.y > 0 && contentOffset.y <= 0 {
			return true
		}
		let maxOffsetY = floor( contentSize.height - bounds.size.height )
		if transition.y < 0 && contentOffset.y >= maxOffsetY {
			return true
		}
		return false
	}
}

extension CGSize {
	func limiting(size: CGSize) -> CGSize {
		if height == 0 {
			return self
		}
		let aspectRatio = width / height
		let width = min(width, size.width)
		let newHeight = min(width / aspectRatio, size.height)
		let newWidth = newHeight * aspectRatio
		return CGSizeMake(newWidth, newHeight)
	}
}

// MARK: - UIScrollViewDelegate, UIGestureRecognizerDelegate
extension ZYPhotoView: UIScrollViewDelegate, UIGestureRecognizerDelegate {

	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}

	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		let offsetX = scrollView.bounds.width > scrollView.contentSize.width ? (scrollView.bounds.width - scrollView.contentSize.width) * 0.5 : 0
		let offsetY = scrollView.bounds.height > scrollView.contentSize.height ? (scrollView.bounds.height - scrollView.contentSize.height) * 0.5 : 0

		imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
	}

	override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		if gestureRecognizer == panGestureRecognizer, gestureRecognizer.state == .possible, isScrollViewOnTopOrBottom() {
			return false
		}
		return true
	}
}
