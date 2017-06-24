//
//  SwiftRandom.swift
//
//  Created by Furkan Yilmaz on 7/10/15.
//  Copyright (c) 2015 Furkan Yilmaz. All rights reserved.
//

//import UIKit

import Foundation

public func rand<T: BinaryFloatingPoint>(_ lower: T = 0.0, _ upper: T = 1.0) -> T {
    return (T(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
}

public extension Bool {
    /// SwiftRandom extension
    public static func random() -> Bool {
        return Int.random() % 2 == 0
    }
}

public extension Int {
    /// SwiftRandom extension
    public static func random(_ range: Range<Int>) -> Int {
        #if swift(>=3)
            return random(range.lowerBound, range.upperBound - 1)
        #else
            return random(range.upperBound, range.lowerBound)
        #endif
    }

    /// SwiftRandom extension
    public static func random(_ range: ClosedRange<Int>) -> Int {
        return random(range.lowerBound, range.upperBound)
    }

    /// SwiftRandom extension
    public static func random(_ lower: Int = 0, _ upper: Int = 100) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}

public extension Int32 {
    /// SwiftRandom extension
    public static func random(_ range: Range<Int>) -> Int32 {
        return random(range.upperBound, range.lowerBound)
    }

    /// SwiftRandom extension
    ///
    /// - note: Using `Int` as parameter type as we usually just want to write `Int32.random(13, 37)` and not `Int32.random(Int32(13), Int32(37))`
    public static func random(_ lower: Int = 0, _ upper: Int = 100) -> Int32 {
        let r = arc4random_uniform(UInt32(Int64(upper) - Int64(lower)))
        return Int32(Int64(r) + Int64(lower))
    }
}

public extension Double {
    /// SwiftRandom extension
    public static func random(_ lower: Double = 0, _ upper: Double = 100) -> Double {
        return (Double(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
}

public extension Float {
    /// SwiftRandom extension
    public static func random(_ lower: Float = 0, _ upper: Float = 100) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
}

public extension Array {
    /// SwiftRandom extension
    public func randomItem() -> Element? {
        guard self.count > 0 else {
            return nil
        }

        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

public extension ArraySlice {
    /// SwiftRandom extension
    public func randomItem() -> Element? {
        guard self.count > 0 else {
            return nil
        }

        #if swift(>=3)
            let index = Int.random(self.startIndex, self.count - 1)
        #else
            let index = Int.random(self.startIndex, self.endIndex)
        #endif

        return self[index]
    }
}


public struct Randoms {
    public static func randomBool() -> Bool {
        return Bool.random()
    }

    public static func randomInt(_ range: Range<Int>) -> Int {
        return Int.random(range)
    }

    public static func randomInt(_ lower: Int = 0, _ upper: Int = 100) -> Int {
        return Int.random(lower, upper)
    }

    public static func randomInt32(_ range: Range<Int>) -> Int32 {
        return Int32.random(range)
    }

    public static func randomInt32(_ lower: Int = 0, _ upper: Int = 100) -> Int32 {
        return Int32.random(lower, upper)
    }

    public static func randomPercentageisOver(_ percentage: Int) -> Bool {
        return Int.random() > percentage
    }

    public static func randomDouble(_ lower: Double = 0, _ upper: Double = 100) -> Double {
        return Double.random(lower, upper)
    }

    public static func randomFloat(_ lower: Float = 0, _ upper: Float = 100) -> Float {
        return Float.random(lower, upper)
    }

}
