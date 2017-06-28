//
//  util.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/2/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

extension Character {
    var asciiValue: UInt32? {
        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
    }
}

public func pow<T: ScalarType>(_ val: T, _ e: Int) -> T {
    switch e {
    case 0:
        return T.one
    case 1:
        return val
    case 2: return val * val
    case 3: return val * val * val
    case 4: return val * val * val * val
    default:
        return T.zero
    }
}

public func ascii(_ c: String) -> Int8 {
    let keys = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
                "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
                "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    
    let vals: [Int8] = Array(65..<91) + Array(97..<123)
    return vals[keys.index(of: c)!] // Int8(D[c]!)
}

public func len<T>(_ arr: [T]) -> Int {
    return arr.count
}

public func len<T>(_ mat: Matrix<T>) -> Int {
    return mat.rows
}

//MARK: checking matrix and array
public func checkMatrices<T>(_ lhs: Matrix<T>, _ rhs: Matrix<T>, _ mode: String) {
    let (lr, lc) = lhs.shape
    let (rr, rc) = rhs.shape
    switch mode {
    case "rows=cols":
        assert(lhs.columns == rhs.rows)
    case "rows=rows":
        assert(lhs.rows == rhs.rows)
    case "cols=cols":
        assert(lhs.columns == rhs.columns)
    case "same":
        assert(lhs.shape == rhs.shape)
    case "transpose":
        assert(lr == rc && lc == rr)
    default:
        fatalError("unrecognized check mode")
    }
}

public func checkMatrices<T>(_ mats: [Matrix<T>], _ mode: String ) {
    if len(mats) == 0{
        return
    }
    
    let (r, c) = mats[0].shape
    
    switch mode {
        
        case "sameRows":
            assert(all( (0..<mats.count).map{ mats[$0].rows == r } ), "matrices's rows are not euqal")
        case "same":
            assert(all( (0..<mats.count).map{ (mats[$0].rows == r) && (mats[$0].columns == c) } ), "matrices's shapes are not euqal")
        case "sameColumns":
            assert(all( (0..<mats.count).map{ mats[$0].columns == c } ), "matrices's columns are not euqal")
        default:
            fatalError("unrecognized check mode")
    }
}

public func checkArray<T>(_ arr1: [T], _ arr2: [T], _ mode: String = "sameCount") {
    switch mode {
    case "sameCount":
        assert(arr1.count == arr2.count, "arrays must have the same count")
    default:
        fatalError("unrecognized check mode")
    }
}
