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
    class func blurEffect(_ cgImage: CGImage, boxSize: CGFloat) -> UIImage? {
        return UIImage(cgImage: (cgImage.blurEffect(boxSize) ?? cgImage))
    }
    
    func blurEffect(_ boxSize: CGFloat) -> UIImage? {
        guard let imageRef = bluredCGImage(boxSize) else { return nil }
        return UIImage(cgImage: imageRef)
    }
    
    func bluredCGImage(_ boxSize: CGFloat) -> CGImage? {
        return cgImage?.blurEffect(boxSize)
    }
}

extension CGImage {
    func blurEffect(_ boxSize: CGFloat) -> CGImage? {
        
        let boxSize = boxSize - (boxSize.truncatingRemainder(dividingBy: 2)) + 1
        
        let inProvider = self.dataProvider
        
        let height = vImagePixelCount(self.height)
        let width = vImagePixelCount(self.width)
        let rowBytes = self.bytesPerRow
        
        let inBitmapData = inProvider?.data
        let inData = UnsafeMutableRawPointer(mutating: CFDataGetBytePtr(inBitmapData))
        var inBuffer = vImage_Buffer(data: inData, height: height, width: width, rowBytes: rowBytes)
        
        let outData = malloc(self.bytesPerRow * self.height)
        var outBuffer = vImage_Buffer(data: outData, height: height, width: width, rowBytes: rowBytes)
        
        vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, vImage_Flags(kvImageEdgeExtend))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: outBuffer.data, width: Int(outBuffer.width), height: Int(outBuffer.height), bitsPerComponent: 8, bytesPerRow: outBuffer.rowBytes, space: colorSpace, bitmapInfo: self.bitmapInfo.rawValue)
        let imageRef = context?.makeImage()

        free(outData)
        
        return imageRef
    }
}
