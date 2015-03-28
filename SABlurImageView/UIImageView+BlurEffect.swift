//
//  UIImageView+BlurEffect.swift
//  SABlurImageView
//
//  Created by 鈴木大貴 on 2015/03/27.
//  Copyright (c) 2015年 鈴木大貴. All rights reserved.
//

import UIKit
import QuartzCore

public class SABlurImageView : UIImageView {
    
    private var duration: CFTimeInterval?
    private var cgImages = [CGImage]()
    
    public func addBlurEffect(boxSize: Float, times: UInt = 1) {
        if var image = image {
            for _ in 0..<times {
                image = image.blurEffect(boxSize)
            }
            self.image = image
        }
    }
    
    public func configrationForBlurAnimation(#duration: CFTimeInterval) {
        if duration < 0 {
            return
        }
        
        var count = 10
        
        if var image = image {
            
            cgImages += [image.CGImage]
            let imageLayer = CALayer()
            imageLayer.contents = image.CGImage
            
            for index in 0..<count {
                image = image.blurEffect(Float(index * index))
                let cgImage = image.CGImage
                cgImages += [cgImage]
                let imageLayer = CALayer()
                imageLayer.contents = cgImage
            }
        }
        
        self.duration = duration
    }
    
    
    public func startBlurAnimation2() {
        
        if let duration = duration {
            
            let count = Double(cgImages.count)
            for (index, cgImage) in enumerate(cgImages) {
                
                let delay = (duration / count) * Double(NSEC_PER_SEC) * Double(index)
                let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(), {
                    
                    self.layer.contents = cgImage
                    
                    let transition = CATransition()
                    transition.duration = (duration) / count
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = kCATransitionFade
                    transition.fillMode = kCAFillModeForwards
                    transition.repeatCount = 1
                    transition.removedOnCompletion = false
                    self.layer.addAnimation(transition, forKey: "fade")
                })
            }
        }
    }
    
    public func startBlurAnimation() {
        let blurAnimation = CAKeyframeAnimation(keyPath: "contents")
        blurAnimation.calculationMode = kCAAnimationDiscrete
        if let duration = duration {
            blurAnimation.duration = duration
        }
        blurAnimation.values = cgImages
        blurAnimation.fillMode = kCAFillModeForwards
        blurAnimation.repeatCount = 1
        blurAnimation.removedOnCompletion = false
        blurAnimation.delegate = self
        layer.addAnimation(blurAnimation, forKey: "blurAnimation")
    }
    
    override public func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if flag {
            if let cgImage = cgImages.last {
                image = UIImage(CGImage: cgImage)
            }
            self.cgImages = cgImages.reverse()
            layer.removeAllAnimations()
        }
    }
}
