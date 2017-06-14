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
public typealias ScalarType = HasZero & HasOne & HasNumericalOps & HasComparisonOps

public protocol HasZero {
    static var zero: Self {get}
}

public protocol HasOne {
    static var one: Self {get}
}

public protocol HasNumericalOps {
    static func +(lhs: Self, rhs: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
}

public protocol HasComparisonOps {
    static func > (lhs: Self, rhs: Self) -> Bool
    static func < (lhs: Self, rhs: Self) -> Bool
    static func >= (lhs: Self, rhs: Self) -> Bool
    static func <= (lhs: Self, rhs: Self) -> Bool
    static func == (lhs: Self, rhs: Self) -> Bool
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
            return lhs && rhs
        }
    
        public static func -(lhs: Bool, rhs: Bool) -> Bool {
            return lhs || rhs
        }
    
        public static func *(lhs: Bool, rhs: Bool) -> Bool {
            return lhs || rhs
        }
}

