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
    let D = ["U" : 85, "L": 76, "N":  78, "I": 73, "V": 86, "A": 65, "S": 83, "O":79]
    return Int8(D[c]!)
}
