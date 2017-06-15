//
//  array_double_extension.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/12/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Accelerate

//MARK: Array extensions

public extension Array where Element == Double {
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

public func searchsorted(_ arr1: [Double], _ arr2: [Double]) -> [Int] {
    var re: [Int] = []
    for t in 0..<arr2.count {
        re.append(binarysearch(arr1, arr2[t]))
    }
    return re
}

public func binarysearch(_ arr: [Double], _ t: Double) -> Int {
    precondition(arr.count > 0)
    var (l, r, m) = (Double(0.0), Double(arr.count - 1), Double(0.0))
    if t < arr.first! {
        return 0
    } else if t > arr.last! {
        return arr.count
    }
    while true {
        m = floor((l + r) / 2.0)
        
        if arr[Int(m)] < t {
            l = m + 1
        } else if arr[Int(m)] > t {
            r = m - 1
        }
        
        if (arr[Int(m)] == t){
            return Int(m)
        }
        
        if Int(l) >= Int(r) {
            if arr[Int(m)] > t {
                return Int(m)
            } else {
                return Int(m + 1)
            }
        }
    }
}

//MARK: ARITHMETIC

public func std(_ arr: [Double]) -> Double {
    var m: Double = 0.0
    var s: Double = 0.0
    vDSP_normalizeD(arr, 1, nil, 1, &m, &s, vDSP_Length(arr.count) )
    return s
}

public func cumsum(_ arr: [Double]) -> [Double] {
    var tmp = Double(0.0)
    var re: [Double] = []
    for i in 0..<arr.count {
        tmp += arr[i]
        re.append(tmp)
    }
    return re
}
