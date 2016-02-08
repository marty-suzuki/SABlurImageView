//
//  UIImage+BlurEffect.swift
//  SABlurImageView
//
//  Created by 鈴木大貴 on 2015/03/27.
//  Copyright (c) 2015年 鈴木大貴. All rights reserved.
//

import UIKit
import QuartzCore
import Accelerate

extension UIImage {
    class func blurEffect(cgImage: CGImageRef, boxSize: CGFloat) -> UIImage! {
        return UIImage(CGImage: cgImage.blurEffect(boxSize))
    }
    
    func blurEffect(boxSize: CGFloat) -> UIImage! {
        return UIImage(CGImage: bluredCGImage(boxSize))
    }
    
    func bluredCGImage(boxSize: CGFloat) -> CGImageRef! {
        return CGImage!.blurEffect(boxSize)
    }
}

extension CGImage {
    func blurEffect(boxSize: CGFloat) -> CGImageRef! {
        
        let boxSize = boxSize - (boxSize % 2) + 1
        
        let inProvider = CGImageGetDataProvider(self)
        
        let height = vImagePixelCount(CGImageGetHeight(self))
        let width = vImagePixelCount(CGImageGetWidth(self))
        let rowBytes = CGImageGetBytesPerRow(self)
        
        let inBitmapData = CGDataProviderCopyData(inProvider)
        let inData = UnsafeMutablePointer<Void>(CFDataGetBytePtr(inBitmapData))
        var inBuffer = vImage_Buffer(data: inData, height: height, width: width, rowBytes: rowBytes)
        
        let outData = malloc(CGImageGetBytesPerRow(self) * CGImageGetHeight(self))
        var outBuffer = vImage_Buffer(data: outData, height: height, width: width, rowBytes: rowBytes)
        
        vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, vImage_Flags(kvImageEdgeExtend))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGBitmapContextCreate(outBuffer.data, Int(outBuffer.width), Int(outBuffer.height), 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(self).rawValue)
        let imageRef = CGBitmapContextCreateImage(context)
        
        free(outData)
        
        return imageRef
    }
}