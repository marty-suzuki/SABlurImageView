//
//  Gap.swift
//  SABlurImageView
//
//  Created by marty-suzuki on 2018/07/07.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

#if swift(>=4.1)
// nothing
#else
extension Sequence {
    public func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        return try flatMap(transform)
    }
}
#endif
