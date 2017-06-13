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

public func checkMatrices<T>(_ lhs: Matrix<T>, _ rhs: Matrix<T>, _ mode: String) {
    let (lr, lc) = lhs.shape
    let (rr, rc) = rhs.shape
    switch mode {
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
