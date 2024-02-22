//
//  ZYPhotoBrowser.swift
//  PhotoBrowserKit
//
//  Created by Zoey Shi on 2017/5/29.
//  Copyright © 2017年 Zoey Shi. All rights reserved.
//  Copyright © 2021 FutureTap GmbH. All rights reserved.
//

import UIKit
import Photos

@objc public protocol ZYPhotoBrowserDelegate: NSObjectProtocol {
	@objc optional func zy_photoBrowser(_ browser: ZYPhotoBrowser, didSelect item: ZYPhotoItem, at index: Int)
	@objc optional func zy_photoBrowser(_ browser: ZYPhotoBrowser, didShare item: ZYPhotoItem, via: String)
}

@objc public class ZYPhotoBrowser: UIViewController {

	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.isPagingEnabled = true
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.alwaysBounceHorizontal = true
		scrollView.delegate = self
		return scrollView
	}()

	private lazy var pageControl: UIPageControl = {
		let pager = UIPageControl()
		pager.isUserInteractionEnabled = false
		return pager
	}()

	lazy var captionLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = .clear
		label.lineBreakMode = .byTruncatingTail
		label.textAlignment = .center
		label.numberOfLines = 0
		label.textColor = .white
		label.shadowColor = UIColor(white: 0, alpha: 0.5)
		label.shadowOffset = CGSize(width: 0, height: 1)
		return label
	}()
	
	private lazy var _imageManager = ZYImageManager()
	
	private var currentPage: Int
	private var photoItems: [ZYPhotoItem]
	private var currentGroupIndex: Int = 0
	
	public var photoItemGroup: [[ZYPhotoItem]] = [[]]
	
	private var visibleItemViews: [ZYPhotoView] = []
	private var reusableItemViews: [ZYPhotoView] = []
	private var _presented = false
	private var startLocation = CGPoint.zero
	private var startFrame = CGRect.zero

	@objc public weak var delegate: ZYPhotoBrowserDelegate?

	private var statusBarHidden = false {
		didSet {
			setNeedsStatusBarAppearanceUpdate()
		}
	}
	override public var prefersStatusBarHidden: Bool {
		return statusBarHidden
	}
	
	public init(photoItems: [ZYPhotoItem] , selectedIndex index:Int) {
		self.currentPage = index
		self.photoItems = photoItems

		super.init(nibName: nil, bundle: nil)
		self.modalPresentationStyle = .custom
		self.modalTransitionStyle = .coverVertical
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = UIColor.clear
		view.addSubview(scrollView)
		view.addSubview(pageControl)

		layoutUI()
	}
	
	override public func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		willAppear()
	}
	
	override public func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		layoutUI()
	}


// MARK: - setup ui
	func layoutUI() {
		
		// layout scrollview
		var rect = view.bounds
		rect.origin.x -= ZYConstant.photoViewPadding
		rect.size.width += 2 * ZYConstant.photoViewPadding
		scrollView.frame = rect
		let contentSize = CGSize(width: rect.width * CGFloat(photoItems.count), height: rect.height)
		scrollView.contentSize = contentSize

		// layout pageControl
		pageControl.frame = CGRect(x: 0, y: rect.height - 40, width: view.bounds.width, height: 20)
		pageControl.numberOfPages = photoItems.count
		configLabelWithPage(currentPage)
				
		setupGestureRecognizers()
		let contentOffset = CGPoint(x: scrollView.frame.width * CGFloat(currentPage), y: 0)
		scrollView.setContentOffset(contentOffset, animated: false)
		if contentOffset.x == 0 {
			self.scrollViewDidScroll(scrollView)
		}
	}
	
	func reloadItems() {
		scrollView.contentOffset.x = 0
		currentPage = 0
		configLabelWithPage(currentPage)
		
		var rect = view.bounds
		rect.origin.x -= ZYConstant.photoViewPadding
		rect.size.width += 2 * ZYConstant.photoViewPadding
		// setup other
		let contentSize = CGSize(width: rect.width * CGFloat(photoItems.count), height: rect.height)
		scrollView.contentSize = contentSize
		
		let contentOffset = CGPoint(x: scrollView.frame.width * CGFloat(currentPage), y: 0)
		scrollView.setContentOffset(contentOffset, animated: false)
		if contentOffset.x == 0 {
			self.scrollViewDidScroll(scrollView)
		}
	}
	
	func willAppear() {
		let item = self.photoItems.zy_safeIndex(currentPage)
		let photoView = self.photoViewForPage(currentPage)
		if let url = item?.imageURL {
			if let _ = _imageManager.imageFromMemoryForURL(url) {
				photoView?.setItem(item, determinate: true)
			} else {
				photoView?.imageView.image = item?.thumbImage
				photoView?.resizeImageView()
			}
		}
		
		guard let item = item else { return }
		guard let photoView = photoView else { return }
		let endRect = photoView.imageView.frame
		var sourceRect :CGRect = CGRect.zero
		
		if let superView = item.sourceView?.superview {
			sourceRect = superView.convert(item.sourceView?.frame ?? CGRect.zero, to: photoView)
			photoView.imageView.frame = sourceRect
		}
		
		UIView.animate(withDuration: ZYConstant.springAnimationDuration , delay: 0, animations: {
			photoView.imageView.frame = endRect
			self.view.backgroundColor = UIColor.black
		}) { (finished) in
			photoView.setItem(item, determinate: true)
			self._presented = true
			self.statusBarHidden = true
		}
	}
	
	private var hideCaptionTimer: Timer?
	func setCaption(visible: Bool) {
		hideCaptionTimer?.invalidate()
		UIView.animate(withDuration: 0.1, animations: {
			self.captionLabel.alpha = visible ? 1.0 : 0
		}, completion: { (_) -> Void in
			if visible {
				self.hideCaptionTimer = Timer(timeInterval: 5.0, repeats: false, block: { _ in
					UIView.animate(withDuration: 1.0) {
						self.captionLabel.alpha = 0
					}
				})
				RunLoop.current.add(self.hideCaptionTimer!, forMode: .common)
			}
		})
	}
	
	public func showFromViewController(_ vc:UIViewController) {
		vc.present(self, animated: false, completion: nil)
	}
}

// MARK: - some calculate
extension ZYPhotoBrowser {
	func configLabelWithPage(_ page: Int) {
		pageControl.currentPage = page
		let item = photoItems.zy_safeIndex(page)
		captionLabel.text = "foo"
		captionLabel.frame = CGRect(x: 20, y: 0, width: view.bounds.width - 40, height: view.bounds.height)
		captionLabel.sizeToFit()
		captionLabel.frame = CGRect(x: 20, y: view.bounds.height - captionLabel.bounds.height - 60,
									width: view.bounds.width - 40, height: captionLabel.bounds.height)
	}
	func updateReuseableItemViews() {
		var viewsToRemove: [ZYPhotoView] = []

		for photoView in visibleItemViews {
			if photoView.frame.origin.x + photoView.frame.width < scrollView.contentOffset.x - scrollView.frame.width
				|| photoView.frame.origin.x > scrollView.contentOffset.x + 2 * scrollView.frame.width {
				photoView.removeFromSuperview()
				photoView.setItem(nil, determinate: false)
				viewsToRemove.append(photoView)
				self.reusableItemViews.append(photoView)
			}
		}

		for view in viewsToRemove {
			visibleItemViews = visibleItemViews.filter { $0.tag != view.tag }
		}
	}
	
	/// Get the ZYPhotoView of a page, if not, fetch it from the buffer pool
	///
	/// - Parameter page: page number
	/// - Returns: ZYPhotoView
	func photoViewForPage(_ page: Int) -> ZYPhotoView? {
		return visibleItemViews.first(where: {$0.tag == page})
	}
	
	/// return a reused ZYPhotoView or create one
	/// - Returns: ZYPhotoView
	func dequeueReusableItemView() -> ZYPhotoView? {
		var photoView = reusableItemViews.last
		if photoView == nil {
			photoView = ZYPhotoView(frame: scrollView.bounds, imageManager: _imageManager)
		} else {
			reusableItemViews.removeLast()
		}
		photoView?.tag = -1
		return photoView
	}
	
	/// Page number change
	func configItemViews() {
		let page = Int(scrollView.contentOffset.x / scrollView.frame.width + 0.5)
		for i in page - 1 ... page + 1 {
			if i < 0 || i >= photoItems.count {
				continue
			}
			var photoView = photoViewForPage(i)
			if photoView == nil {
				photoView = self.dequeueReusableItemView()
				var rect = scrollView.bounds
				rect.origin.x = CGFloat(i) * scrollView.bounds.width
				photoView?.frame = rect
				photoView?.tag = i
				scrollView.addSubview(photoView!)
				visibleItemViews.append(photoView!)
			}
			guard let photoView = photoView else {
				return
			}
			if photoView.item == nil && _presented {
				let item = photoItems.zy_safeIndex(i)
				photoView.setItem(item, determinate: true)
			}
		}
		
		if page != currentPage && _presented && page>=0 && page<photoItems.count {
			let item = photoItems[page]
			self.currentPage = page
			self.configLabelWithPage(page)
			delegate?.zy_photoBrowser?(self, didSelect: item, at: page)
		}
	}
}


// MARK: - UIScrollViewDelegate
extension ZYPhotoBrowser: UIScrollViewDelegate {
	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		setCaption(visible: false)
	}
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		updateReuseableItemViews()
		configItemViews()
	}
	
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		setCaption(visible: true)
	}
}

// MARK: - Gestures
extension ZYPhotoBrowser {
	
	func setupGestureRecognizers() {
		let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(_:)))
		doubleTap.numberOfTapsRequired = 2
		view.addGestureRecognizer(doubleTap)
		
		let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTap(_:)))
		singleTap.numberOfTapsRequired = 1
		singleTap.require(toFail: doubleTap)
		view.addGestureRecognizer(singleTap)
		
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
		view.addGestureRecognizer(longPress)
		
		let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
		view.addGestureRecognizer(pan)
	}

	@objc func didSingleTap(_ gesture: UITapGestureRecognizer) {
		showDismissalAnimation()
	}

	@objc func didDoubleTap(_ gesture: UITapGestureRecognizer) {
		guard let photoView = photoViewForPage(currentPage) else { return }
		let item = photoItems[currentPage]
		if !item.finished {
			return // Not finished loading
		}
		
		if photoView.zoomScale > 1 {
			photoView.setZoomScale(1, animated: true)
		} else {
			let location = gesture.location(in: view)
			let maxZoomScale = photoView.maximumZoomScale
			let width = view.bounds.size.width / maxZoomScale
			let height = view.bounds.height / maxZoomScale
			photoView.zoom(to: CGRect(x: location.x - width/2, y: location.y - height/2, width: width, height: height), animated: true)
		}
	}
	
	@objc func didLongPress(_ gesture:UILongPressGestureRecognizer) {
		guard let photoView = self.photoViewForPage(self.currentPage) else { return }
		if let image = photoView.imageView.image {
			// present sharing VC
		}
	}
	
	/// - Parameter gesture: gesture
	@objc func handlePan(_ gesture: UIPanGestureRecognizer) {
		guard let photoView = self.photoViewForPage(currentPage) else { return }
		if photoView.zoomScale > 1.1 {
			return
		}
		
		let point = gesture.translation(in: view)
		let location = gesture.location(in: view)
		let velocity = gesture.velocity(in: view)
		guard let photoView = photoViewForPage(currentPage) else { return }
		
		switch gesture.state {
		case .began:
			startLocation = location
			startFrame = photoView.imageView.frame
			guard let photoView = self.photoViewForPage(currentPage) else { return }
			let item = self.photoItems[currentPage]
			statusBarHidden = false
			photoView.progressLayer.isHidden = true
			item.sourceView?.alpha = 0
			setCaption(visible: false)
		case .changed:
			var percent = 1 - abs(point.y) / view.frame.height
			percent = max(percent, 0)
			let s = max(percent, 0.3)
			let width = startFrame.width * s
			let height = startFrame.height * s
			
			let rateX = (startLocation.x - startFrame.minX) / startFrame.width
			let x = location.x - width * rateX
			
			let rateY = (startLocation.y - startFrame.minY) / startFrame.height
			let y = location.y - height * rateY
			
			photoView.imageView.frame = CGRect(x: x, y: y, width: width, height: height)
			view.backgroundColor = UIColor(white: 0, alpha: percent)
			pageControl.alpha = percent
		case .ended, .cancelled:
			if abs(point.y) > 100 || abs(velocity.y) > 500 {
				showDismissalAnimation()
			} else {
				showCancellationAnimation()
			}
		default:
			break
		}
	}
	
	/// cancel interactive dismiss
	func showCancellationAnimation() {
		guard let item = self.photoItems.zy_safeIndex(currentPage) else { return }
		guard let photoView = self.photoViewForPage(currentPage) else { return }
		item.sourceView?.alpha = 1
		if !item.finished {
			photoView.progressLayer.isHidden = false
		}
		UIView.animate(withDuration: ZYConstant.springAnimationDuration, animations: {
			photoView.imageView.frame = self.startFrame
			self.view.backgroundColor = UIColor.black
			self.pageControl.alpha = 1.0
		}, completion: { (_) in
			self.statusBarHidden = true
			photoView.setItem(item, determinate: true)
		})
		setCaption(visible: true)
	}

	func showDismissalAnimation() {
		guard let item = self.photoItems.zy_safeIndex(currentPage) else { return }
		guard let photoView = self.photoViewForPage(currentPage) else { return }
		statusBarHidden = false
		if item.sourceView == nil {
			UIView.animate(withDuration: 0.3, animations: {
				self.view.alpha = 0
			}, completion: { (_) in
				self.dismissAnimated(false)
			})
			return
		}

		photoView.progressLayer.isHidden = true
		item.sourceView?.alpha = 0

		var sourceRect = CGRect.zero
		sourceRect = item.sourceView?.superview?.convert(item.sourceView!.frame, to: photoView) ?? CGRect.zero
		UIView.animate(withDuration: ZYConstant.springAnimationDuration, delay: 0, animations: {
			photoView.imageView.frame = sourceRect
			self.view.backgroundColor = UIColor.clear
			self.pageControl.alpha = 0
			self.captionLabel.alpha = 0
		}, completion: { (_) in
			self.dismissAnimated(false)
		})
	}

	func dismissAnimated(_ animated: Bool) {
		let item = photoItems[currentPage]
		if animated {
			UIView.animate(withDuration: 0.3) {
				item.sourceView?.alpha = 1
			}
		} else {
			item.sourceView?.alpha = 1
		}
		self.dismiss(animated: false, completion: nil)
	}
}
