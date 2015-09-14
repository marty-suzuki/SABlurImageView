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

public class SABlurImageView : UIImageView {
    
    private typealias AnimationFunction = Void -> ()
    
    //MARK: - Static Properties
    static private let FadeAnimationKey = "Fade"
    
    //MARK: - Instance Properties
    private let kMaxImageCount: Int = 10
    private var cgImages: [CGImage] = [CGImage]()
    private var nextBlurLayer: CALayer?
    private var previousImageIndex: Int = -1
    private var previousPercentage: Float = 0.0
    private var animations: [AnimationFunction]?
    
    deinit {
        cgImages.removeAll(keepCapacity: false)
        nextBlurLayer?.removeFromSuperlayer()
        nextBlurLayer = nil
        animations?.removeAll(keepCapacity: false)
        animations = nil
        layer.removeAllAnimations()
    }
}

//MARK: = Life Cycle
public extension SABlurImageView {
    public override func layoutSubviews() {
        super.layoutSubviews()
        nextBlurLayer?.frame = bounds
    }
}

//MARK: - Public Methods
public extension SABlurImageView {
    public func addBlurEffect(boxSize: Float, times: UInt = 1) {
        if var image = image {
            for _ in 0..<times {
                image = image.blurEffect(boxSize)
            }
            self.image = image
        }
    }
    
    public func configrationForBlurAnimation(boxSize: Float = 100) {
        guard var image = image else {
            return
        }
        
        if let cgImage = image.CGImage {
            cgImages += [cgImage]
        }
            
        var newBoxSize = boxSize
        if newBoxSize > 200 {
            newBoxSize = 200
        } else if newBoxSize < 0 {
            newBoxSize = 0
        }
        
        let number = sqrt(Double(newBoxSize)) / Double(kMaxImageCount)
        for index in 0..<kMaxImageCount {
            
            let value = Double(index) * number
            let boxSize = value * value
            
            image = image.blurEffect(Float(boxSize))
            
            if let cgImage = image.CGImage {
                cgImages += [cgImage]
            }
        }
    }
    
    public func blur(percentage: Float) {
        var newPercentage = percentage
        if newPercentage < 0.0 {
            newPercentage = 0.0
        } else if newPercentage > 1.0 {
            newPercentage = 0.99
        }
        
        if previousPercentage - newPercentage  > 0 {
            
            let index = Int(floor(newPercentage * 10)) + 1
            if index > 0 {
                setLayers(index, percentage: newPercentage, currentIndex: index - 1, nextIndex: index)
            }
            
        } else {
            
            let index = Int(floor(newPercentage * 10))
            if index < cgImages.count - 1 {
                setLayers(index, percentage: newPercentage, currentIndex: index, nextIndex: index + 1)
            }
        }
        previousPercentage = newPercentage
    }
    
    private func setLayers(index: Int, percentage: Float, currentIndex: Int, nextIndex: Int) {
        if index != previousImageIndex {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            layer.contents = cgImages[currentIndex]
            CATransaction.commit()
            
            if nextBlurLayer == nil {
                let nextBlurLayer = CALayer()
                nextBlurLayer.frame = bounds
                layer.addSublayer(nextBlurLayer)
                self.nextBlurLayer = nextBlurLayer
            }
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            nextBlurLayer?.contents = cgImages[nextIndex]
            nextBlurLayer?.opacity = 1.0
            CATransaction.commit()
        }
        previousImageIndex = index
        
        let minPercentage = percentage * 100.0
        var alpha = (minPercentage - Float(Int(minPercentage / 10.0)  * 10)) / 10.0
        if alpha > 1.0 {
            alpha = 1.0
        } else if alpha < 0.0 {
            alpha = 0.0
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        nextBlurLayer?.opacity = alpha
        CATransaction.commit()
    }
    
    public func startBlurAnimation(duration _duration: Double) {
        if animations == nil {
            animations = [AnimationFunction]()
        }
        
        let count = Double(cgImages.count)
        for cgImage in cgImages {
            animations?.append() { [weak self] in
                let transition = CATransition()
                transition.duration = (_duration) / count
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                transition.type = kCATransitionFade
                transition.fillMode = kCAFillModeForwards
                transition.repeatCount = 1
                transition.removedOnCompletion = false
                transition.delegate = self
                self?.layer.addAnimation(transition, forKey: SABlurImageView.FadeAnimationKey)
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
        guard let _ = anim as? CATransition else {
            return
        }
        
        layer.removeAllAnimations()
        if let animation = animations?.first {
            animation()
            let _ = animations?.removeFirst()
        } else {
            animations?.removeAll(keepCapacity: false)
            animations = nil
        }
    }
}
