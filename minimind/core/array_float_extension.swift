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
    public func std() -> Element {
        let m = mean()
        let v = mean(self.map{ powf(($0 - m), 2.0)})
        return sqrtf(v)
    }
    
    public func mean() -> Element {
        return sum() / Element(count)
    }
    
    public func mean(_ arr: [Element]) -> Element {
        return sum(arr) / Element(arr.count)
    }
    
    public func sum() -> Element {
        return self.reduce(0.0, {x, y in x + y} )
    }
    
    public func sum(_ arr: [Element]) -> Element {
        return arr.reduce(0.0, {x, y in x + y} )
    }
    
    public func norm() -> Element {
        return sqrt((self ** 2).sum())
    }
    
    public func cumsum() -> [Element] {
        var tmp = Element(0.0)
        var re: [Element] = []
        for i in 0..<count {
            tmp += self[i]
            re.append(tmp)
        }
        return re
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

public func binarysearch(_ arr: [Float], _ t: Float) -> Int {
    precondition(arr.count > 0)
    var (l, r, m) = (Float(0.0), Float(arr.count - 1), Float(0.0))
    if t < arr.first! {
        return 0
    } else if t > arr.last! {
        return arr.count
    }
    while true {
        m = floorf((l + r) / 2.0)
        
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
