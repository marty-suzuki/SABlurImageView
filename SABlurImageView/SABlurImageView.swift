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
    private struct AnimationKey {
        static let fade = "FadeAnimationKey"
        static let contents = "contents"
    }
    
    //MARK: - Static Properties
    static private let maxImageCount: Int = 10
    
    //MARK: - Instance Properties
    private var cgImages: [CGImage] = [CGImage]()
    private var nextBlurLayer: CALayer?
    private var previousImageIndex: Int = -1
    private var previousPercentage: CGFloat = 0.0
    public private(set) var isBlurAnimating: Bool = false
    
    deinit {
        clearMemory()
    }

    //MARK: - Life Cycle
    public override func layoutSubviews() {
        super.layoutSubviews()
        nextBlurLayer?.frame = bounds
    }
    
    public func configrationForBlurAnimation(_ boxSize: CGFloat = 100) {
        guard let image = image else { return }
        let baseBoxSize = max(min(boxSize, 200), 0)
        let baseNumber = sqrt(CGFloat(baseBoxSize)) / CGFloat(SABlurImageView.maxImageCount)
        let baseCGImages = [image].flatMap { $0.cgImage }
        cgImages = bluredCGImages(images: baseCGImages, sourceImage: image, at: 0, to: SABlurImageView.maxImageCount, baseNumber: baseNumber)
    }
    
    private func bluredCGImages(images: [CGImage], sourceImage: UIImage?, at index: Int, to limit: Int, baseNumber: CGFloat) -> [CGImage] {
        guard index < limit else { return images }
        let newImage = sourceImage?.blurEffect(pow(CGFloat(index) * baseNumber, 2))
        let newImages = images + [newImage].flatMap { $0?.cgImage }
        return bluredCGImages(images: newImages, sourceImage: newImage, at: index + 1, to: limit, baseNumber: baseNumber)
    }
    
    public func clearMemory() {
        cgImages.removeAll(keepingCapacity: false)
        nextBlurLayer?.removeFromSuperlayer()
        nextBlurLayer = nil
        previousImageIndex = -1
        previousPercentage = 0.0
        layer.removeAllAnimations()
    }

    //MARK: - Add single blur
    public func addBlurEffect(_ boxSize: CGFloat, times: UInt = 1) {
        guard let image = image else { return }
        self.image = addBlurEffectTo(image, boxSize: boxSize, remainTimes: times)
    }
    
    private func addBlurEffectTo(_ image: UIImage, boxSize: CGFloat, remainTimes: UInt) -> UIImage {
        return remainTimes > 0 ? addBlurEffectTo(image.blurEffect(boxSize), boxSize: boxSize, remainTimes: remainTimes - 1) : image
    }
    
    //MARK: - Percentage blur
    public func blur(_ percentage: CGFloat) {
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
    
    private func setLayers(_ index: Int, percentage: CGFloat, currentIndex: Int, nextIndex: Int) {
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

    //MARK: - Animation blur
    public func startBlurAnimation(duration: TimeInterval) {
        if isBlurAnimating { return }
        isBlurAnimating = true
        let count = cgImages.count
        let group = CAAnimationGroup()
        group.animations = cgImages.enumerated().flatMap {
            guard $0.offset < count - 1 else { return nil }
            let anim = CABasicAnimation(keyPath: AnimationKey.contents)
            anim.fromValue = $0.element
            anim.toValue = cgImages[$0.offset + 1]
            anim.fillMode = kCAFillModeForwards
            anim.isRemovedOnCompletion = false
            anim.duration = duration / TimeInterval(count)
            anim.beginTime = anim.duration * TimeInterval($0.offset)
            return anim
        }
        group.duration = duration
        group.delegate = self
        group.isRemovedOnCompletion = false
        group.fillMode = kCAFillModeForwards
        layer.add(group, forKey: AnimationKey.fade)
        cgImages = cgImages.reversed()
    }
    
    override public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let _ = anim as? CAAnimationGroup else { return }
        layer.removeAnimation(forKey: AnimationKey.fade)
        isBlurAnimating = false
        guard let cgImage = cgImages.first else { return }
        image = UIImage(cgImage: cgImage)
    }
}
