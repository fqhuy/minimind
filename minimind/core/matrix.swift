//
//  matrix.swift
//  minimind
//
//  Created by Phan Quoc Huy on 5/29/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Surge

public typealias FloatType = ExpressibleByFloatLiteral & FloatingPoint

extension Matrix {
    func copy(with zone: NSZone? = nil) -> Any {
        return Matrix(rows: 0, columns: 0, repeatedValue: 0.0)
    }
}

public func * <T: ExpressibleByFloatLiteral & FloatingPoint>(lhs: T, rhs: Matrix<T>) -> Matrix<T> {
    return lhs * rhs
}

public prefix func -<T: ExpressibleByFloatLiteral & FloatingPoint>(lhs: Matrix<T>) -> Matrix<T> {
    var newmat = lhs
    newmat.grid = -newmat.grid
    return newmat
}

public func - <T: ExpressibleByFloatLiteral & FloatingPoint>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    return lhs - rhs
}

//public func - (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
//    return lhs + (-rhs)
//}

public func +<T: ExpressibleByFloatLiteral & FloatingPoint>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    return lhs + rhs
}

public func *<T: ExpressibleByFloatLiteral & FloatingPoint>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    return lhs * rhs
}

public func abs<T: FloatingPoint & ExpressibleByFloatLiteral>(_ mat: Matrix<T>) -> Matrix<T> {
    var newmat = mat
    for i in 0..<newmat.rows {
        for j in 0..<newmat.columns {
            newmat[i, j] = abs(newmat[i, j])
        }
    }
    return newmat
}

public func max<T: FloatingPoint & ExpressibleByFloatLiteral>(_ mat: Matrix<T>) -> T {
    return mat.grid.max()!
}

public func min<T: FloatingPoint & ExpressibleByFloatLiteral>(_ mat: Matrix<T>) -> T {
    return mat.grid.min()!
}

public func reduce_sum<T: FloatingPoint & ExpressibleByFloatLiteral>(_ mat: Matrix<T>,_ axis: Int?) -> Matrix<T>? {
    if axis == nil {
        var newmat = Matrix<T>([[0.0]])
        newmat[0,0] = mat.grid.reduce(0.0, {x , y in x + y})
        return newmat
    } else if axis! == 1 {
        var newmat = Matrix<T>(rows: mat.rows, columns: 1, repeatedValue: 0.0)
        for i in 0..<mat.rows {
            newmat.grid[i] = mat[row: i].reduce(0.0, {x,y in x+y})
        }

        return newmat
    } else if axis! == 0 {
        var newmat = Matrix<T>(rows: 1, columns: mat.columns, repeatedValue: 0.0)
        for i in 0..<mat.columns {
            newmat.grid[i] = mat[column: i].reduce(0.0, {x,y in x+y})
        }
        return newmat
    } else {
        return nil
    }
}
