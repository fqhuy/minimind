//
//  array.swift
//  minimind
//
//  Created by Phan Quoc Huy on 5/30/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

public prefix func -<T: SignedNumber>(arr: [T]) -> [T] {
    return arr.map{x in -x}
}

public func -<T: SignedNumber>(lhs: [T], rhs: [T]) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] - rhs[$0] }
}

public func -<T: SignedNumber>(lhs: T, rhs: [T]) -> [T] {
    return (0..<rhs.count).map{ lhs - rhs[$0] }
}

public func -<T: SignedNumber>(lhs: [T], rhs: T) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] - rhs }
}

public func +<T: FloatingPoint>(lhs: [T], rhs: [T]) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] + rhs[$0] }
}

public func +<T: FloatingPoint>(lhs: T, rhs: [T]) -> [T] {
    return (0..<rhs.count).map{ lhs + rhs[$0] }
}

public func +<T: FloatingPoint>(lhs: [T], rhs: T) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] + rhs }
}


public func * <T: FloatingPoint>(lhs: T, rhs: [T]) -> [T] {
    return rhs.map{ lhs * $0 }
}

public func * <T: FloatingPoint>(lhs: [T], rhs: [T]) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] * rhs[$0] }
}

public func * <T: FloatingPoint>(lhs: [T], rhs: T) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] * rhs }
}

public func abs<T: SignedNumber>(_ arr: [T]) -> [T] {
    return arr.map{ abs($0) }
}

public func randArray<T: FloatingPoint>(n: Int) -> [T] {
    return (0..<n).map{x in Randoms.randomFloat(0.0, 1.0) as! T}
}
