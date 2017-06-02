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
    public init(_ rows: Int,_ columns: Int,_ data: [Element]) {
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

public func * <T: FloatType>(lhs: Matrix<T>, rhs: T) -> Matrix<T> {
    var newmat = lhs
    newmat.grid = newmat.grid / rhs
    return newmat}

public func /<T: FloatType> (lhs: Matrix<T>, rhs: T) -> Matrix<T> {
    var newmat = lhs
    newmat.grid = newmat.grid / rhs
    return newmat
}

public func div (mat: Matrix<Float>, scalar: Float) -> Matrix<Float> {
    return mat / scalar 
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

public func log(_ mat: Matrix<Float>) -> Matrix<Float> {
    return Matrix<Float>(mat.rows, mat.columns, log(mat.grid))
}

public func log(_ mat: Matrix<Double>) -> Matrix<Double> {
    return Matrix<Double>(mat.rows, mat.columns, log(mat.grid))
}


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

public func cholesky(_ mat: Matrix<Float>, _ uplo: String = "U") -> Matrix<Float> {
    precondition(mat.rows == mat.columns, "Matrix must be square")
    var L = mat
    var _uplo: Int8 = ascii(uplo)
    var n: __CLPK_integer = __CLPK_integer(mat.rows)
    var info: __CLPK_integer = 0
    spotrf_(&_uplo, &n, &(L.grid), &n, &info )
    
    assert(info == 0, "Cholesky failed")
    switch uplo {
    case "L":
        return triu(L).t
    case "U":
        return tril(L).t
    default:
        return triu(L).t
    }
}

public func cholesky(_ mat: Matrix<Double>, _ uplo: String = "U") -> Matrix<Double> {
    precondition(mat.rows == mat.columns, "Matrix must be square")
    var L = mat
    var _uplo: Int8 = ascii(uplo)
    var n: __CLPK_integer = __CLPK_integer(mat.rows)
    var info: __CLPK_integer = 0
    dpotrf_(&_uplo, &n, &(L.grid), &n, &info )
    
    assert(info == 0, "Cholesky failed")
    switch uplo {
    case "L":
        return triu(L).t
    case "U":
        return tril(L).t
    default:
        return triu(L).t
    }
}

public func logdet(_ mat: Matrix<Float>) -> Float {
    let L = cholesky(mat, "L")
    return (2.0 * reduce_sum(log(diag(L)))!)[0,0]
}

public func solve_triangular(_ A: Matrix<Float>, _ b: Matrix<Float>, _  uplo: String = "U", _ trans: String = "N") -> Matrix<Float> {
    var aa = A
    var bb = b
    var uplo: Int8 = ascii(uplo)
    var trans: Int8 = ascii("N")
    var dia: Int8 = ascii("N")
    var n: __CLPK_integer = __CLPK_integer(A.rows)
    var nrhs: __CLPK_integer = __CLPK_integer(b.rows)
    var info: __CLPK_integer = 0
    
    strtrs_(&uplo, &trans, &dia, &n, &nrhs, &(aa.grid), &n, &(bb.grid), &nrhs, &info)
    
    assert(info == 0, "solve triangular failed")
    
    return bb
}

public func solve_triangular(_ A: Matrix<Double>, _ b: Matrix<Double>, _ lower: Bool = false) -> Matrix<Double> {
    var aa = A
    var bb = b
    var uplo: Int8 = lower ? ascii("L") : ascii("U")
    var trans: Int8 = ascii("N")
    var dia: Int8 = ascii("N")
    var n: __CLPK_integer = __CLPK_integer(A.rows)
    var nrhs: __CLPK_integer = __CLPK_integer(b.rows)
    var info: __CLPK_integer = 0
    
    dtrtrs_(&uplo, &trans, &dia, &n, &nrhs, &(aa.grid), &n, &(bb.grid), &nrhs, &info)
    
    assert(info == 0, "solve triangular failed")
    
    return bb
}

// TRAVERSE

public func reduce_sum<T: FloatingPoint & ExpressibleByFloatLiteral>(_ mat: Matrix<T>,_ axis: Int? = nil) -> Matrix<T>? {
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

public func tril<T: FloatType>(_ mat: Matrix<T>) -> Matrix<T> {
    var dmat = mat
    for i in 0..<mat.rows{
        for j in 0...i {
            if i != j {
                dmat[j, i] = 0
            }
        }
    }
    return dmat
}

public func triu<T: FloatType>(_ mat: Matrix<T>) -> Matrix<T> {
    var dmat = mat
    for i in 0..<mat.rows{
        for j in 0...i {
            if i != j {
                dmat[i, j] = 0
            }
        }
    }
    return dmat
}

// TRANSFORMERS

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


public func randMatrix<T: FloatType>(_ rows: Int,_ columns: Int) -> Matrix<T> {
    return Matrix<T>(rows, columns, randArray(n: rows * columns))
}
