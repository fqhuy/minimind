//
//  array_float_extension.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/12/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Accelerate

//MARK: Array extensions

public extension Array where Element == Float {
    public func mean() -> Element {
        return minimind.mean(self)
    }
    
    public func std() -> Element {
        return minimind.std(self)
    }
    
    public func sum() -> Element {
        return minimind.sum(self)
    }
    
    public func norm() -> Element {
        return sqrt((self ** 2).sum())
    }
    
    public func cumsum() -> [Element] {
        return minimind.cumsum(self)
    }
}

//MARK: Search & Sort

public func searchsorted(_ arr1: [Float], _ arr2: [Float]) -> [Int] {
    var re: [Int] = []
    for t in 0..<arr2.count {
        re.append(binarysearch(arr1, arr2[t]))
    }
    return re
}

//MARK: ARITHMETIC

public func std(_ arr: [Float]) -> Float {
    var m: Float = 0.0
    var s: Float = 0.0
    vDSP_normalize(arr, 1, nil, 1, &m, &s, vDSP_Length(arr.count) )
    return s
}

public func cumsum(_ arr: [Float]) -> [Float] {
    var tmp = Float(0.0)
    var re: [Float] = []
    for i in 0..<arr.count {
        tmp += arr[i]
        re.append(tmp)
    }
    return re
}
