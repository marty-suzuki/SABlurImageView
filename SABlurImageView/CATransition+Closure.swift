//
//  CATransition+Closure.swift
//  SABlurImageView
//
//  Created by 鈴木大貴 on 2016/01/21.
//  Copyright (c) 2015年 鈴木大貴. All rights reserved.
//

import UIKit
import QuartzCore

extension CATransaction {
    class func animationWithDuration(_ duration: TimeInterval, animation: () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        animation()
        CATransaction.commit()
    }
}
