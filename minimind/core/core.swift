//
//  core.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/14/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

public typealias FloatType = ExpressibleByFloatLiteral & FloatingPoint
public typealias IntType = Integer
public typealias IndexType = Int 

//MARK: Can ScalaType be SignedNumber ?

public typealias ScalarType = HasSign & HasZero & HasOne & HasArithmeticOps & HasComparisonOps & HasNaN
public typealias FloatingPointScalarType = ScalarType & BinaryFloatingPoint

public protocol HasNaN {
    var isNaN: Bool {get}
}

public protocol HasSign {
    prefix static func -(x: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
    static func abs(_ x: Self) -> Self
}

public protocol HasZero {
    static var zero: Self {get}
}

public protocol HasOne {
    static var one: Self {get}
}

public protocol HasArithmeticOps {
    static func +(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
}

extension HasArithmeticOps{
    static func +=(lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    static func *=(lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
    static func /=(lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
}

extension HasArithmeticOps where Self: HasSign {
    static func -=(lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
}

public protocol HasComparisonOps {
    static func > (lhs: Self, rhs: Self) -> Bool
    static func < (lhs: Self, rhs: Self) -> Bool
    static func >= (lhs: Self, rhs: Self) -> Bool
    static func <= (lhs: Self, rhs: Self) -> Bool
    static func == (lhs: Self, rhs: Self) -> Bool
}

//extension ScalarType where Self: BinaryFloatingPoint {
//    
//}

extension BinaryFloatingPoint where Self: ScalarType {

    public static var zero: Self {
        get {
            return 0.0
        }
    }
    
    public static var one: Self {
        get {
            return 1.0
        }
    }
}

extension Float: ScalarType  {
    public static var zero: Float {
        get {
            return Float(0.0)
        }
    }
    
    public static var one: Float {
        get {
            return Float(1.0)
        }
    }
    
}

extension Double: ScalarType {
    public static var zero: Double {
        get {
            return Double(0.0)
        }
    }
    public static var one: Double {
        get {
            return Double(1.0)
        }
    }
}

extension Int: ScalarType {
    //TODO: very inappropriate for now
    public var isNaN: Bool {
        return self == Int.min
    }

    public static func abs(_ x: Int) -> Int {
        return abs(x)
    }

    public static var zero: Int {
        get {
            return 0
        }
    }
    public static var one: Int {
        get {
            return 1
        }
    }
}

extension Bool: ScalarType {
    public var isNaN: Bool {
        return false
    }

    public static func abs(_ x: Bool) -> Bool {
        return x
    }
    
    public prefix static func -(x: Bool) -> Bool {
        return !x
    }

    public static func /(lhs: Bool, rhs: Bool) -> Bool {
        return lhs && rhs
    }

    public static func <=(lhs: Bool, rhs: Bool) -> Bool {
        return (lhs < rhs) || (lhs == rhs)
    }

    public static func >=(lhs: Bool, rhs: Bool) -> Bool {
        return (lhs > rhs) || (rhs == lhs)
    }

    public static func >(lhs: Bool, rhs: Bool) -> Bool {
        return lhs && !rhs
    }

    public static func <(lhs: Bool, rhs: Bool) -> Bool {
        return !lhs && rhs
    }

    public static var zero: Bool {
        get {
            return false
        }
    }
    
    public static var one: Bool {
        get {
            return true
        }
    }
    
    public static func +(lhs: Bool, rhs: Bool) -> Bool {
        return lhs || rhs
    }
    
    public static func -(lhs: Bool, rhs: Bool) -> Bool {
        return lhs && (!rhs)
    }
    
    public static func *(lhs: Bool, rhs: Bool) -> Bool {
        return lhs && rhs
    }
}

//MARK: Scalar operators
public func close<T: FloatingPointScalarType>(_ a: T, _ b: T, _ tol: T=1e-4) -> Bool {
    return abs(a - b) < tol
}

