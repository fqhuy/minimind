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

public extension Matrix {
    public init(rows: Int, columns: Int, data: [Element]) {
        precondition(data.count == rows * columns, "data.count != rows * columns")

        self.rows = rows
        self.columns = columns
        
        self.grid = data
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Matrix(rows: 0, columns: 0, repeatedValue: 0.0)
    }
}

public extension Matrix where T == Float {
        public var t: Matrix {
            get {
                let newmat = self
                return transpose(newmat)
            }
        }
}

public extension Matrix where T == Double {
    public var t: Matrix {
        get {
            let newmat = self
            return transpose(newmat)
        }
    }
}

// ARITHMETIC

public prefix func -(mat: Matrix<Float>) -> Matrix<Float> {
    return -1.0 * mat
}

public func -(lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return lhs + (-1.0 * rhs)
}

public prefix func -(mat: Matrix<Double>) -> Matrix<Double> {
    return -1.0 * mat
}

public func -(lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    return lhs + (-1.0 * rhs)
}

public func *(lhs: Matrix<Float>, rhs: Float) -> Matrix<Float> {
    return rhs * lhs
}

public func •<T: FloatType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    var newmat = lhs
    newmat.grid = (0..<lhs.grid.count).map{ lhs.grid[$0] * rhs.grid[$0] }
    return newmat
}


//public prefix func -<T: ExpressibleByFloatLiteral & FloatingPoint>(lhs: Matrix<T>) -> Matrix<T> {
//    var newmat = lhs
//    newmat.grid = -newmat.grid
//    return newmat
//}
//
//public func - <T: ExpressibleByFloatLiteral & FloatingPoint>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
//    return lhs - rhs
//}
//
//
//public func +<T: ExpressibleByFloatLiteral & FloatingPoint>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
//    return lhs + rhs // add(lhs, y: rhs)
//}
//
//
//public func *<T: ExpressibleByFloatLiteral & FloatingPoint>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
//    return lhs * rhs
//}
//
//public func -<T: FloatType>(lhs: Matrix<T>, rhs: T) -> Matrix<T> {
//    return lhs - rhs
//}
//
//public func +<T: FloatType>(lhs: Matrix<T>, rhs: T) -> Matrix<T> {
//    return lhs + rhs
//}
//
//public func *<T: FloatType>(lhs: Matrix<T>, rhs: T) -> Matrix<T> {
//    return lhs * rhs
//}
//
//public func /<T: FloatType>(lhs: Matrix<T>, rhs: T) -> Matrix<T> {
//    return lhs / rhs
//}
//
//public func - <T: FloatType>(lhs: T, rhs: Matrix<T>) -> Matrix<T> {
//    return lhs - rhs
//}
//
//public func +<T: FloatType>(lhs: T, rhs: Matrix<T>) -> Matrix<T> {
//    return rhs + lhs
//}
//
//public func *<T: FloatType>(lhs: T, rhs: Matrix<T>) -> Matrix<T> {
//    return rhs * lhs
//}
//
//public func /<T: FloatType>(lhs: T, rhs: Matrix<T>) -> Matrix<T> {
//    return rhs / lhs
//}

// MATH FUNCTIONS

public func abs<T: FloatingPoint & ExpressibleByFloatLiteral>(_ mat: Matrix<T>) -> Matrix<T> {
    var newmat = mat
    newmat.grid = abs(newmat.grid)
    return newmat
}

public func max<T: FloatingPoint & ExpressibleByFloatLiteral>(_ mat: Matrix<T>) -> T {
    return mat.grid.max()!
}

public func min<T: FloatingPoint & ExpressibleByFloatLiteral>(_ mat: Matrix<T>) -> T {
    return mat.grid.min()!
}

public func cross_add<T: FloatType>(_ lhs: Matrix<T>, _ rhs: Matrix<T>) -> Matrix<T> {
    precondition((lhs.columns == 1) && (rhs.columns == 1), "lhs and rhs must have shape (N, 1)")
    
    var re: Matrix<T> = zeros(lhs.rows, rhs.rows)
    for i in 0..<lhs.rows {
        for j in 0..<rhs.rows {
            re[i, j] = lhs[i, 0] + rhs[j, 0]
        }
    }
    return re
}

// TRAVERSE

public func reduce_sum<T: FloatingPoint & ExpressibleByFloatLiteral>(_ mat: Matrix<T>,_ axis: Int?) -> Matrix<T>? {
    if axis == nil {
        var newmat = Matrix<T>([[0.0]])
        newmat[0,0] = mat.grid.reduce(0.0, {x , y in x + y})
        return newmat
    } else if axis! == 1 {
        var newmat = Matrix<T>(rows: mat.rows, columns: 1, repeatedValue: 0.0)
        for i in 0..<mat.rows {
            newmat.grid[i] = mat[i].reduce(0.0, {x,y in x+y})
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

// ACCESS
public func diag<T: FloatType>(_ mat: Matrix<T>) -> Matrix<T> {
    var dmat = Matrix<T>(rows: 1, columns: mat.columns)
    for i in 0..<mat.columns {
        dmat[0, i] = mat[i, i]
    }
    return dmat
}

// TRANSFORMERS
//public func transpose<T: FloatingPoint & ExpressibleByFloatLiteral>(_ mat: Matrix<T>) -> Matrix<T> {
//    return transpose(mat)
//}

public func tile<T: FloatType>(_ mat: Matrix<T>, _ shape: [Int]) -> Matrix<T> {
    var newmat: Matrix<T> = zeros(mat.rows * shape[0], mat.columns * shape[1])
    for row in 0..<shape[0] {
        for col in 0..<shape[1] {
            for i in 0..<mat.rows {
                for j in 0..<mat.columns {
                    newmat[row * mat.rows + i, col * mat.columns + j] = mat[i, j]
                }
            }
        }
    }
    return newmat
}

// CREATORS
public func ones<T: FloatType>(_ rows: Int, _ columns: Int) -> Matrix<T> {
    return Matrix<T>(rows: rows, columns: columns, repeatedValue: 1.0 as T)
}


public func zeros<T: FloatType>(_ rows: Int, _ columns: Int) -> Matrix<T> {
    return Matrix<T>(rows: rows, columns: columns, repeatedValue: 0.0 as T)
}

public func eye<T: FloatingPoint & ExpressibleByFloatLiteral>(_ D: Int) -> Matrix<T> {
    var mat = Matrix<T>(rows: D, columns: D, repeatedValue: 0.0)
    for i in 0..<D {
        mat[i, i] = 1.0
    }
    return mat
}

//public func rand<T: FloatType>(rows: Int, columns: Int) -> Matrix<T> {
//    var mat = Matrix<T>(rows: rows, columns: columns, repeatedValue: 0.0)
//    mat.grid = arc4random_uniform(10)
//}

public func randMatrix<T: FloatType>(_ rows: Int,_ columns: Int) -> Matrix<T> {
    return Matrix<T>(rows: rows, columns: columns, data: randArray(n: rows * columns))
}
