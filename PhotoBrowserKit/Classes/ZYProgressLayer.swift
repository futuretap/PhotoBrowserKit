//
//  ZYProgressLayer.swift
//  PhotoBrowserKit
//
//  Created by duzhe on 2017/5/31.
//  Copyright © 2017年 Zoey Shi. All rights reserved.
//

import UIKit

class ZYProgressLayer: CAShapeLayer {
	
	fileprivate var isSpinning = false
	
	override init(layer: Any) {
		super.init(layer: layer)
	}

	init(frame: CGRect) {
		super.init()
		self.frame = frame
		setup()
	}
	
	func setup() {
		self.cornerRadius = 20
		self.fillColor = UIColor.clear.cgColor
		self.strokeColor = UIColor.white.cgColor
		self.lineWidth = 4
		self.lineCap = .round
		self.strokeStart = 0
		self.strokeEnd = 0.01
		self.backgroundColor = UIColor(white: 0, alpha: 0.5).cgColor
		let path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: 2, dy: 2), cornerRadius: 20 - 2)
		self.path = path.cgPath
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func startSpin() {
		self.isSpinning = true
		self.strokeEnd = 0.33
		let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
		rotationAnimation.toValue = CGFloat(Double.pi - 0.5)
		rotationAnimation.duration = 0.4
		rotationAnimation.isCumulative = true
		rotationAnimation.repeatCount = Float.infinity
		self.add(rotationAnimation, forKey: nil)
	}
	
	func stopSpin() {
		self.isSpinning = false
		self.removeAllAnimations()
	}
}
