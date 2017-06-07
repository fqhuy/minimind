//
//  array.swift
//  minimind
//
//  Created by Phan Quoc Huy on 5/30/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

//MARK: Arithmetic

public func **(lhs: [Float], rhs: Float) -> [Float] {
    return lhs.map{ powf($0, 2.0) }
}

public func **(lhs: [Double], rhs: Double) -> [Double] {
    return lhs.map{ pow($0, 2.0) }
}


public func +=<T: FloatingPoint>(lhs: inout [T], rhs: T) {
    lhs = lhs + rhs
}

public func +=<T: FloatingPoint>(lhs: inout [T], rhs: [T]){
    lhs = lhs + rhs
}

public func -=<T: FloatingPoint>(lhs: inout [T], rhs: T) {
    lhs = lhs - rhs
}

public func -=<T: FloatingPoint>(lhs: inout [T], rhs: [T]) {
    lhs = lhs - rhs
}

public func *=<T: FloatingPoint>(lhs: inout [T], rhs: T)  {
    lhs = lhs * rhs
}

public func *=<T: FloatingPoint>(lhs: inout [T], rhs: [T])  {
    lhs =  lhs * rhs
}

public func /=<T: FloatingPoint>(lhs: inout [T], rhs: T)  {
    lhs = lhs / rhs
}

public func /=<T: FloatingPoint>(lhs: inout [T], rhs: [T])  {
    lhs = lhs / rhs
}

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
    precondition(lhs.count == rhs.count, "rhs.count must == lhs.count")
    return (0..<lhs.count).map{ lhs[$0] * rhs[$0] }
}

public func * <T: FloatingPoint>(lhs: [T], rhs: T) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] * rhs }
}

public func / <T: FloatingPoint>(lhs: T, rhs: [T]) -> [T] {
    return rhs.map{ lhs / $0 }
}

public func / <T: FloatingPoint>(lhs: [T], rhs: [T]) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] / rhs[$0] }
}

public func / <T: FloatingPoint>(lhs: [T], rhs: T) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] / rhs }
}


//MARK: Math
public func sqrt<T: FloatingPoint>(_ arr: [T]) -> [T] {
    return arr.map{ sqrt($0) }
}

public func abs<T: SignedNumber>(_ arr: [T]) -> [T] {
    return arr.map{ abs($0) }
}

public func clip<T: FloatingPoint>(_ arr: [T], _ floor: T,_ ceil: T) -> [T] {
    return arr.map{ $0 < floor ? floor : $0}.map{ $0 > ceil ? ceil : $0 }
}


//MARK: Creators
public func randArray(n: Int) -> [Float] {
    return (0..<n).map{x in Randoms.randomFloat(0.0, 1.0)}
}

public func randArray(n: Int) -> [Double] {
    return (0..<n).map{x in Randoms.randomDouble(0.0, 1.0)}
}

public func randArray(n: Int) -> [Int] {
    return (0..<n).map{x in Randoms.randomInt(0, 100)}
}

public func arange(_ minValue: Float, _ maxValue: Float, _ step: Float) -> [Float] {
    let n: Int = Int(floorf((maxValue - minValue) / step))
    return (0..<n).map{ Float($0) * step + minValue }
}

public func arange(_ minValue: Double, _ maxValue: Double, _ step: Double) -> [Double] {
    let n: Int = Int(floor((maxValue - minValue) / step))
    return (0..<n).map{ Double($0) * step + minValue }
}

public func arange(_ minValue: Int, _ maxValue: Int, _ step: Int) -> [Int] {
    let n: Int = Int((maxValue - minValue) / step)
    return (0..<n).map{ $0 * step + minValue }
}

infix operator ..

public func .. (from: Int, step: Int) -> ((Int) -> [Int]) {
    return { x in arange(from, x, step) }
}

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
}

//public func log<T: FloatingPoint>(_ arr: [T]) -> [T] {
//    return arr.map{_log($0)}
//}
