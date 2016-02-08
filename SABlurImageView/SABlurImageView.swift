//
//  UIImageView+BlurEffect.swift
//  SABlurImageView
//
//  Created by 鈴木大貴 on 2015/03/27.
//  Copyright (c) 2015年 鈴木大貴. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore

public class SABlurImageView: UIImageView {
    
    private typealias AnimationFunction = Void -> ()
    
    //MARK: - Static Properties
    static private let FadeAnimationKey = "FadeAnimationKey"
    static private let MaxImageCount: Int = 10
    
    //MARK: - Instance Properties
    private var cgImages: [CGImage] = [CGImage]()
    private var nextBlurLayer: CALayer?
    private var previousImageIndex: Int = -1
    private var previousPercentage: CGFloat = 0.0
    private var animations: [AnimationFunction]?
    
    deinit {
        clearMemory()
    }
}

//MARK: - Life Cycle
public extension SABlurImageView {
    public override func layoutSubviews() {
        super.layoutSubviews()
        nextBlurLayer?.frame = bounds
    }
    
    public func configrationForBlurAnimation(boxSize: CGFloat = 100) {
        guard var image = image else { return }
        if let cgImage = image.CGImage {
            cgImages += [cgImage]
        }
        let newBoxSize = max(min(boxSize, 200), 0)
        let number = sqrt(CGFloat(newBoxSize)) / CGFloat(self.dynamicType.MaxImageCount)
        (0..<self.dynamicType.MaxImageCount).forEach {
            let value = CGFloat($0) * number
            let boxSize = value * value
            image = image.blurEffect(boxSize)
            if let cgImage = image.CGImage {
                cgImages += [cgImage]
            }
        }
    }
    
    public func clearMemory() {
        cgImages.removeAll(keepCapacity: false)
        nextBlurLayer?.removeFromSuperlayer()
        nextBlurLayer = nil
        previousImageIndex = -1
        previousPercentage = 0.0
        animations?.removeAll(keepCapacity: false)
        animations = nil
        layer.removeAllAnimations()
    }
}

//MARK: - Add single blur
public extension SABlurImageView {
    public func addBlurEffect(boxSize: CGFloat, times: UInt = 1) {
        guard let image = image else { return }
        self.image = addBlurEffectTo(image, boxSize: boxSize, remainTimes: times)
    }
    
    private func addBlurEffectTo(image: UIImage, boxSize: CGFloat, remainTimes: UInt) -> UIImage {
        return remainTimes > 0 ? addBlurEffectTo(image.blurEffect(boxSize), boxSize: boxSize, remainTimes: remainTimes - 1) : image
    }
}

//MARK: - Percentage blur
public extension SABlurImageView {
    public func blur(percentage: CGFloat) {
        let percentage = min(max(percentage, 0.0), 0.99)
        if previousPercentage - percentage  > 0 {
            let index = Int(floor(percentage * 10)) + 1
            if index > 0 {
                setLayers(index, percentage: percentage, currentIndex: index - 1, nextIndex: index)
            }
        } else {
            let index = Int(floor(percentage * 10))
            if index < cgImages.count - 1 {
                setLayers(index, percentage: percentage, currentIndex: index, nextIndex: index + 1)
            }
        }
        previousPercentage = percentage
    }
    
    private func setLayers(index: Int, percentage: CGFloat, currentIndex: Int, nextIndex: Int) {
        if index != previousImageIndex {
            CATransaction.animationWithDuration(0) { layer.contents = self.cgImages[currentIndex] }
            
            if nextBlurLayer == nil {
                let nextBlurLayer = CALayer()
                nextBlurLayer.frame = bounds
                layer.addSublayer(nextBlurLayer)
                self.nextBlurLayer = nextBlurLayer
            }
            
            CATransaction.animationWithDuration(0) {
                self.nextBlurLayer?.contents = self.cgImages[nextIndex]
                self.nextBlurLayer?.opacity = 1.0
            }
        }
        previousImageIndex = index
        
        let minPercentage = percentage * 100.0
        let alpha = min(max((minPercentage - CGFloat(Int(minPercentage / 10.0)  * 10)) / 10.0, 0.0), 1.0)
        CATransaction.animationWithDuration(0) { self.nextBlurLayer?.opacity = Float(alpha) }
    }
}

//MARK: - Animation blur
public extension SABlurImageView {
    public func startBlurAnimation(duration duration: NSTimeInterval) {
        let count = Double(cgImages.count)
        animations = cgImages.map { cgImage in
            return { [weak self] in
                let transition = CATransition()
                transition.duration = (duration) / count
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                transition.type = kCATransitionFade
                transition.fillMode = kCAFillModeForwards
                transition.repeatCount = 1
                transition.removedOnCompletion = false
                transition.delegate = self
                self?.layer.addAnimation(transition, forKey: self?.dynamicType.FadeAnimationKey)
                self?.layer.contents = cgImage
            }
        }
        
        if let animation = animations?.first {
            animation()
            let _ = animations?.removeFirst()
        }
        cgImages = cgImages.reverse()
    }
    
    override public func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        guard let _ = anim as? CATransition else { return }
        layer.removeAnimationForKey(self.dynamicType.FadeAnimationKey)
        guard let animation = animations?.first else {
            animations?.removeAll(keepCapacity: false)
            animations = nil
            return
        }
        animation()
        let _ = animations?.removeFirst()
    }
}