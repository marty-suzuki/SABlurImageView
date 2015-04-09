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
    
    private let kFadeAnimationKey = "Fade"
    private let kMaxImageCount = 10
    private var cgImages = [CGImage]()
    private var nextBlurLayer: CALayer?
    private var previousImageIndex: Int = -1
    private var previousPercentage: Float = 0.0
    
    public func addBlurEffect(boxSize: Float, times: UInt = 1) {
        if var image = image {
            for _ in 0..<times {
                image = image.blurEffect(boxSize)
            }
            self.image = image
        }
    }
    
    public func configrationForBlurAnimation(boxSize: Float = 100) {
        if var image = image {
            
            cgImages += [image.CGImage]
            
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
                
                let cgImage = image.CGImage
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
    
    public func startBlurAnimation(#duration: Double) {
        
        let count = Double(cgImages.count)
        for (index, cgImage) in enumerate(cgImages) {
            
            let delay = (duration / count) * Double(NSEC_PER_SEC) * Double(index)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                
                let transition = CATransition()
                transition.duration = (duration) / count
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                transition.type = kCATransitionFade
                transition.fillMode = kCAFillModeForwards
                transition.repeatCount = 1
                transition.removedOnCompletion = false
                transition.delegate = self
                self.layer.addAnimation(transition, forKey: self.kFadeAnimationKey)
                
                self.layer.contents = cgImage
            })
        }
        
        cgImages = cgImages.reverse()
    }
    
    override public func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if flag {
            if let transition = anim as? CATransition {
                layer.removeAnimationForKey(kFadeAnimationKey)
            }
        }
    }
}
