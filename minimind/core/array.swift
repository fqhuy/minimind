//
//  array.swift
//  minimind
//
//  Created by Phan Quoc Huy on 5/30/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

//MARK: EXTENSIONS
extension Array where Element: ScalarType {

}

//MARK: Arithmetic

public func **(lhs: [Float], rhs: Float) -> [Float] {
    return lhs.map{ powf($0, 2.0) }
}

public func **(lhs: [Double], rhs: Double) -> [Double] {
    return lhs.map{ pow($0, 2.0) }
}


public func +=<T: ScalarType>(lhs: inout [T], rhs: T) {
    lhs = lhs + rhs
}

public func +=<T: ScalarType>(lhs: inout [T], rhs: [T]){
    lhs = lhs + rhs
}

public func -=<T: ScalarType>(lhs: inout [T], rhs: T) {
    lhs = lhs - rhs
}

public func -=<T: ScalarType>(lhs: inout [T], rhs: [T]) {
    lhs = lhs - rhs
}

public func *=<T: ScalarType>(lhs: inout [T], rhs: T)  {
    lhs = lhs * rhs
}

//public func *=<T: ScalarType>(lhs: T, rhs: [T]) -> [T] {
//    return rhs * lhs
//}

public func *=<T: ScalarType>(lhs: inout [T], rhs: [T])  {
    lhs =  lhs * rhs
}

public func /=<T: ScalarType>(lhs: inout [T], rhs: T)  {
    lhs = lhs / rhs
}

//public func /=<T: ScalarType>(lhs: T, rhs: [T]) -> [T] {
//    return rhs / lhs
//}

public func /=<T: ScalarType>(lhs: inout [T], rhs: [T])  {
    lhs = lhs / rhs
}

public prefix func -<T: ScalarType>(arr: [T]) -> [T] {
    return arr.map{x in -x}
}

public func -<T: ScalarType>(lhs: [T], rhs: [T]) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] - rhs[$0] }
}

public func -<T: ScalarType>(lhs: T, rhs: [T]) -> [T] {
    return (0..<rhs.count).map{ lhs - rhs[$0] }
}

public func -<T: ScalarType>(lhs: [T], rhs: T) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] - rhs }
}

public func +<T: ScalarType>(lhs: [T], rhs: [T]) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] + rhs[$0] }
}

public func +<T: ScalarType>(lhs: T, rhs: [T]) -> [T] {
    return (0..<rhs.count).map{ lhs + rhs[$0] }
}

public func +<T: ScalarType>(lhs: [T], rhs: T) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] + rhs }
}


public func * <T: ScalarType>(lhs: T, rhs: [T]) -> [T] {
    return rhs.map{ lhs * $0 }
}

public func * <T: ScalarType>(lhs: [T], rhs: [T]) -> [T] {
    precondition(lhs.count == rhs.count, "rhs.count must == lhs.count")
    return (0..<lhs.count).map{ lhs[$0] * rhs[$0] }
}

public func * <T: ScalarType>(lhs: [T], rhs: T) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] * rhs }
}

public func / <T: ScalarType>(lhs: T, rhs: [T]) -> [T] {
    return rhs.map{ lhs / $0 }
}

public func / <T: ScalarType>(lhs: [T], rhs: [T]) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] / rhs[$0] }
}

public func / <T: ScalarType>(lhs: [T], rhs: T) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] / rhs }
}


//MARK: Math
public func sqrt<T: FloatingPoint>(_ arr: [T]) -> [T] {
    return arr.map{ sqrt($0) }
}

public func abs<T: ScalarType>(_ arr: [T]) -> [T] {
    return arr.map{ T.abs($0) }
}

public func clip<T: ScalarType>(_ arr: [T], _ floor: T,_ ceil: T) -> [T] {
    return arr.map{ $0 < floor ? floor : $0}.map{ $0 > ceil ? ceil : $0 }
}

public func minimum<T: ScalarType>(_ arr1: [T], _ arr2: [T]) -> [T] {
    return (0..<arr1.count).map{ i in arr1[i] <= arr2[i] ? arr1[i] : arr2[i] }
}

public func maximum<T: ScalarType>(_ arr1: [T], _ arr2: [T]) -> [T] {
    return (0..<arr1.count).map{ i in arr1[i] >= arr2[i] ? arr1[i] : arr2[i] }
}

public func sum<T: ScalarType>(_ arr: [T]) -> T {
    return arr.reduce(T.zero, {x,y in x + y})
}

public func prod<T: ScalarType>(_ arr: [T]) -> T {
    return arr.reduce(T.zero, {x,y in x * y})
}

public func max<T: HasComparisonOps>(_ arr: [T]) -> T {
    return arr.max(by: {x, y in x <= y})!
}

public func min<T: HasComparisonOps>(_ arr: [T]) -> T {
    return arr.min(by: {x, y in x <= y})!
}

public func argmax<T: HasComparisonOps>(_ arr: [T]) -> IndexType {
    let (_, idx) = find(arr, {(x, y) -> Bool in x <= y} )
    return idx
}

public func argmin<T: HasComparisonOps>(_ arr: [T]) -> IndexType {
    let (_, idx) = find(arr, {(x, y) -> Bool in x >= y} )
    return idx
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

infix operator ∷

public func ∷ (from: Int, step: Int) -> ((Int) -> [Int]) {
    return { x in arange(from, x, step) }
}

infix operator ∶
public  func ∶(_ from: Int, _ to: Int) -> [Int] {
    return arange(from, to, 1)
}

postfix operator ∶
public postfix func ∶(_ from: Int) -> ((Int) -> [Int]) {
    return { n in arange(from, n, 1)}
}

prefix operator ∶
public prefix func ∶(_ to: Int) -> ((Int) -> [Int]) {
    return { n in arange(0, to, 1)}
}

infix operator ∪
public func ∪<T>(_ lhs: [T], _ rhs: [T]) -> [T] {
    var re = lhs
    for i in 0..<rhs.count {
        re.append(rhs[i])
    }
    return re
}

public let forall = { i in arange(0, i, 1)}

//MARK: Tuples

public func tuple<T>(_ arr: [T]) -> (T, T) {
    return (arr[0], arr[1])
}

//MARK: Array<Bool>

public func all(_ arr: [Bool]) -> Bool {
    return arr.reduce(true, {x, y in x && y})
}

public func any(_ arr: [Bool]) -> Bool {
    return arr.reduce(false, {x,y in x || y})
}

public func nonzero(_ arr: [Bool]) -> [IndexType] {
    var re: [IndexType] = []
    for i in 0..<arr.count {
        if arr[i] {
            re.append(i)
        }
    }
    return re
}

public func ==<T: Equatable>(_ arr: [T], _ t: T) -> [Bool] {
    return arr.map{ $0 == t }
}

public func >=<T: Comparable>(_ arr: [T], _ t: T) -> [Bool] {
    return arr.map{ $0 >= t }
}

public func <=<T: Comparable>(_ arr: [T], _ t: T) -> [Bool] {
    return arr.map{ $0 <= t }
}

public func > <T: Comparable>(_ arr: [T], _ t: T) -> [Bool] {
    return arr.map{ $0 > t }
}

public func < <T: Comparable>(_ arr: [T], _ t: T) -> [Bool] {
    return arr.map{ $0 < t }
}

public func ==<T: Equatable>(_ t: T, _ arr: [T]) -> [Bool] {
    return arr.map{ $0 == t }
}

public func >=<T: Comparable>(_ t: T, _ arr: [T]) -> [Bool] {
    return arr.map{ $0 >= t }
}

public func <=<T: Comparable>(_ t: T, _ arr: [T]) -> [Bool] {
    return arr.map{ $0 <= t }
}

public func > <T: Comparable>(_ t: T, _ arr: [T]) -> [Bool] {
    return arr.map{ $0 > t }
}

public func < <T: Comparable>(_ t: T, _ arr: [T]) -> [Bool] {
    return arr.map{ $0 < t }
}

public func ==<T: Equatable>(_ lhs: [T], _ rhs: [T]) -> [Bool] {
    return (0..<lhs.count).map{ lhs[$0] == rhs[$0]}
}

public func >=<T: Comparable>(_ lhs: [T], _ rhs: [T]) -> [Bool] {
    return (0..<lhs.count).map{ lhs[$0] >= rhs[$0]}
}

public func <=<T: Comparable>(_ lhs: [T], _ rhs: [T]) -> [Bool] {
    return (0..<lhs.count).map{ lhs[$0] <= rhs[$0]}
}

public func > <T: Comparable>(_ lhs: [T], _ rhs: [T]) -> [Bool] {
    return (0..<lhs.count).map{ lhs[$0] > rhs[$0]}
}

public func < <T: Comparable>(_ lhs: [T], _ rhs: [T]) -> [Bool] {
    return (0..<lhs.count).map{ lhs[$0] < rhs[$0]}
}

//MARK: ALGORITHMS
extension Array {
    public mutating func swap(_ i1: IndexType, _ i2: IndexType) {
        let tmp = self[i1]
        self[i1] = self[i2]
        self[i2] = tmp
    }
}

public func binarysearch<T: ScalarType>(_ arr: [T], _ t: T) -> Int {
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

public func quicksort<T: Comparable>(_ arr: [T]) -> ([T], [IndexType]) {
    func _partition(_ arr: inout [T], _ iarr: inout [IndexType], _ from: IndexType, _ to: IndexType) -> IndexType {
        let pivot = from
        var left = from + 1
        var right = to
        
        while true {
            // Slide left and right until an exchange point is found
            while (arr[left] <= arr[pivot]) && (right >= left) {
                left += 1
            }
            
            while (arr[right] >= arr[pivot]) && (right >= left) {
                right -= 1
            }
            
            // Stop condition
            if (right < left) {
                arr.swap(pivot, right)
                iarr.swap(pivot, right)
                return right
            }
            
            // Exchange left and right
            arr.swap(left, right)
            iarr.swap(left, right)
        }
    }
    
    func _sort(_ arr: inout [T], _ iarr: inout [IndexType], _ from: IndexType, _ to: IndexType) {
        if from < to - 1 {
            let splitPoint = _partition(&arr, &iarr, from, to)
            _sort(&arr, &iarr, from, splitPoint - 1)
            _sort(&arr, &iarr, splitPoint + 1, to)
        }
    }
    var newarr = arr
    var iarr: [IndexType] = arange(0, arr.count, 1)
    _sort(&newarr, &iarr, 0, arr.count - 1)
    return (newarr, iarr)
}


public func find<T>(_ arr: [T], _ f: (T, T) -> Bool) -> (T, IndexType) {
    var idx: IndexType = 0
    var item = arr[0]
    
    for i in 1..<arr.count {
        if f(item, arr[i]) {
            item = arr[i]
            idx = i
        }
    }
    
    return (item, idx)
}
