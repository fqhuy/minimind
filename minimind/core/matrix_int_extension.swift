//
//  matrix_int_extension.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/12/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

//MARK: CREATORS
public func ones<T: IntType>(_ rows: Int, _ columns: Int) -> Matrix<T> {
    return Matrix<T>(rows: rows, columns: columns, repeatedValue: 1 as T)
}

public func zeros<T: IntType>(_ rows: Int, _ columns: Int) ->Matrix<T> {
    return Matrix<T>(rows: rows, columns: columns, repeatedValue: 0)
}

public func randMatrix(_ rows: Int,_ columns: Int) -> Matrix<Int> {
    return Matrix<Int>(rows, columns, randArray(n: rows * columns))
}

//MARK: ARITHMETIC

public func add<T: IntType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    checkMatrices(x, y, "same")
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] + y.grid[i] } )
}

public func add<T: IntType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] + y } )
}

public func add<T: IntType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return Matrix<T>( y.rows, y.columns, (0..<y.grid.count).map{ i in x + y.grid[i] } )
}

public func sub<T: IntType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    checkMatrices(x, y, "same")
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] - y.grid[i] } )
}

public func sub<T: IntType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] - y } )
}

public func sub<T: IntType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return Matrix<T>( y.rows, y.columns, (0..<y.grid.count).map{ i in x - y.grid[i] } )
}

public func mul<T: IntType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    checkMatrices(x, y, "same")
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] * y.grid[i] } )
}

public func mul<T: IntType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] * y } )
}

public func mul<T: IntType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return Matrix<T>( y.rows, y.columns, (0..<y.grid.count).map{ i in x * y.grid[i] } )
}

public func div<T: IntType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    checkMatrices(x, y, "same")
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] / y.grid[i] } )
}

public func div<T: IntType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return Matrix<T>( x.rows, x.columns, (0..<x.grid.count).map{ i in x.grid[i] / y } )
}

public func div<T: IntType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return Matrix<T>( y.rows, y.columns, (0..<y.grid.count).map{ i in x / y.grid[i] } )
}

public func +<T: IntType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    return add(x, y: y)
}

public func +<T: IntType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return add(x, y: y)
}

public func +<T: IntType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return add(x, y: y)
}

public func -<T: IntType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    return sub(x, y: y)
}

public func -<T: IntType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return sub(x, y: y)
}

public func -<T: IntType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return sub(x, y: y)
}

public func *<T: IntType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    return mul(x, y: y)
}

public func *<T: IntType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return mul(x, y: y)
}

public func *<T: IntType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return mul(x, y: y)
}

public func /<T: IntType>(_ x: Matrix<T>, y: Matrix<T>) -> Matrix<T> {
    return div(x, y: y)
}

public func /<T: IntType>(_ x: Matrix<T>, y: T) -> Matrix<T> {
    return div(x, y: y)
}

public func /<T: IntType>(_ x: T, y: Matrix<T>) -> Matrix<T> {
    return div(x, y: y)
}
