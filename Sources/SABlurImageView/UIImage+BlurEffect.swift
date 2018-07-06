//
//  UIImage+BlurEffect.swift
//  SABlurImageView
//
//  Created by 鈴木大貴 on 2015/03/27.
//  Copyright (c) 2015年 鈴木大貴. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

import QuartzCore
import Accelerate

extension Image {
    #if os(iOS) || os(tvOS)
    class func blurEffect(_ cgImage: CGImage, boxSize: CGFloat) -> Image? {
        return UIImage(cgImage: (cgImage.blurEffect(boxSize) ?? cgImage))
    }
    #elseif os(macOS)
    class func blurEffect(_ cgImage: CGImage, boxSize: CGFloat, size: CGSize) -> Image? {
        return NSImage(cgImage: (cgImage.blurEffect(boxSize) ?? cgImage), size: size)
    }
    #endif
    
    func blurEffect(_ boxSize: CGFloat) -> Image? {
        guard let imageRef = bluredCGImage(boxSize) else { return nil }
        #if os(iOS) || os(tvOS)
        return UIImage(cgImage: imageRef)
        #elseif os(macOS)
        return NSImage(cgImage:  imageRef, size: size)
        #endif
    }
    
    func bluredCGImage(_ boxSize: CGFloat) -> CGImage? {
        #if os(iOS) || os(tvOS)
        return cgImage?.blurEffect(boxSize)
        #elseif os(macOS)
        var imageRect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        return cgImage(forProposedRect: &imageRect, context: nil, hints: nil)?.blurEffect(boxSize)
        #endif
    }

    func toCGImage() -> CGImage? {
        #if os(iOS) || os(tvOS)
        return cgImage
        #elseif os(macOS)
        var imageRect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        return cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        #endif
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
