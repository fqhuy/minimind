//
//  matrix_int_extension.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/12/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

//MARK: EXTENSIONS
public extension Matrix where T: Integer {
    public var t: Matrix {
        get {
            var newmat = self
            for r in 0..<rows {
                for c in 0..<columns {
                    newmat[c, r] = self[r, c]
                }
            }
            return newmat
        }
    }
    
//    public func mean(_ axis: Int) -> Matrix {
//        if axis == 0 {
//            var m: Matrix = zeros(1, columns)
//            for col in 0..<columns {
//                m[0, col] = minimind.mean(self[column: col].grid)
//            }
//            return m
//        } else if axis == 1 {
//            var m: Matrix = zeros(rows, 1)
//            for row in 0..<rows {
//                m[row, 0] = minimind.mean(self[row].grid)
//            }
//            return m
//        } else {
//            return Matrix([[minimind.mean(grid)]])
//        }
//    }
    
    public func sum(_ axis: Int = -1) -> Matrix {
        if axis == 0 {
            var m: Matrix = zeros(1, columns)
            for col in 0..<columns {
                m[0, col] = minimind.sum(self[column: col].grid)
            }
            return m
        } else if axis == 1 {
            var m: Matrix = zeros(rows, 1)
            for row in 0..<rows {
                m[row, 0] = minimind.sum(self[row].grid)
            }
            return m
        } else {
            return Matrix([[minimind.sum(grid)]])
        }
    }
}

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
