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
    switch c {
    case "U":
        return 85
    case "L":
        return 76
    case "N":
        return 78
    case "I":
        return 73
    case "V":
        return 86
    default:
        return 0
    }
//    return Int8(c[c.startIndex].asciiValue!)
}
