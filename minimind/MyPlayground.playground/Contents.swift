//: Playground - noun: a place where people can play

import UIKit
var str = "Hello, playground"

import Surge
//import minimind

var m = Matrix<Float>([[1.0, 2.0],[1.0, 1.0]])
let v = m
//let v1 = -1.0 * m

func * <T:ExpressibleByFloatLiteral & FloatingPoint>(lhs: T, rhs: Matrix<T>) -> Matrix<T> {
    return lhs * rhs
}

prefix func -<T: ExpressibleByFloatLiteral & FloatingPoint>(mat: Matrix<T>) -> Matrix<T> {
    var newmat = mat
    newmat.grid = -newmat.grid
    return newmat
}

prefix func -<T: SignedNumber>(arr: [T]) -> [T] {
    return arr.map{x in -x}
}

func * <T: FloatingPoint>(lhs: T, rhs: [T]) -> [T] {
    return rhs.map{ lhs * $0 }
}

func -<T: SignedNumber>(lhs: [T], rhs: [T]) -> [T] {
    return (0..<lhs.count).map{ lhs[$0] - rhs[$0] }
}

let s = [1.0, 2.0]
s - [1.0, 1.0]


let x: Int? = 10
let y = x