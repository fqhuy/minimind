//
//  matrix_double_extension.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/10/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Accelerate

public extension Matrix where T == Double {
    public var t: Matrix {
        get {
            let newmat = self
            return transpose(newmat)
        }
    }
    
    public func mean(_ axis: Int) -> Matrix {
        if axis == 0 {
            var m: Matrix = zeros(1, columns)
            for col in 0..<columns {
                m[0, col] = minimind.mean(self[column: col].grid)
            }
            return m
        } else if axis == 1 {
            var m: Matrix = zeros(rows, 1)
            for row in 0..<rows {
                m[row, 0] = minimind.mean(self[row].grid)
            }
            return m
        } else {
            return Matrix([[minimind.mean(grid)]])
        }
    }
    
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

//MARK: ARITHMETIC

public func add(_ x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    precondition(x.rows == y.rows && x.columns == y.columns, "Matrix dimensions not compatible with addition")
    
    var results = y
    cblas_daxpy(Int32(x.grid.count), 1.0, x.grid, 1, &(results.grid), 1)
    
    return results
}

public func mul(_ alpha: Double, x: Matrix<Double>) -> Matrix<Double> {
    var results = x
    cblas_dscal(Int32(x.grid.count), alpha, &(results.grid), 1)
    
    return results
}

public func mul(_ x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    precondition(x.columns == y.rows, "Matrix dimensions not compatible with multiplication")
    
    var results = Matrix<Double>(rows: x.rows, columns: y.columns, repeatedValue: 0.0)
    cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, Int32(x.rows), Int32(y.columns), Int32(x.columns), 1.0, x.grid, Int32(x.columns), y.grid, Int32(y.columns), 0.0, &(results.grid), Int32(results.columns))
    
    return results
}

public func elmul(_ x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    precondition(x.rows == y.rows && x.columns == y.columns, "Matrix must have the same dimensions")
    var result = Matrix<Double>(rows: x.rows, columns: x.columns, repeatedValue: 0.0)
    result.grid = x.grid * y.grid
    return result
}

public func div(_ x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    let yInv = inv(y)
    precondition(x.columns == yInv.rows, "Matrix dimensions not compatible")
    return mul(x, y: yInv)
}

public func pow(_ x: Matrix<Double>, _ y: Double) -> Matrix<Double> {
    var result = Matrix<Double>(rows: x.rows, columns: x.columns, repeatedValue: 0.0)
    result.grid = pow(x.grid, y)
    return result
}

public func exp(_ x: Matrix<Double>) -> Matrix<Double> {
    var result = Matrix<Double>(rows: x.rows, columns: x.columns, repeatedValue: 0.0)
    result.grid = exp(x.grid)
    return result
}

public func sum(_ x: Matrix<Double>, axies: MatrixAxies = .column) -> Matrix<Double> {
    
    switch axies {
    case .column:
        var result = Matrix<Double>(rows: 1, columns: x.columns, repeatedValue: 0.0)
        for i in 0..<x.columns {
            result.grid[i] = sum(x[column: i].grid)
        }
        return result
        
    case .row:
        var result = Matrix<Double>(rows: x.rows, columns: 1, repeatedValue: 0.0)
        for i in 0..<x.rows {
            result.grid[i] = sum(x[i].grid)
        }
        return result
    }
}

public func + (lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    return add(lhs, y: rhs)
}

public func -(lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    return lhs + (-rhs)
}

public func * (lhs: Double, rhs: Matrix<Double>) -> Matrix<Double> {
    return mul(lhs, x: rhs)
}

public func * (lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    return mul(lhs, y: rhs)
}

public func / (lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    return div(lhs, y: rhs)
}

public func += (lhs: inout Matrix<Double>, rhs: Matrix<Double>) {
    lhs = lhs + rhs
}

public func -= (lhs: inout Matrix<Double>, rhs: Matrix<Double>) {
    lhs = lhs - rhs
}

public func /= (lhs: inout Matrix<Double>, rhs: Matrix<Double>) {
    lhs = lhs / rhs
}

public func *= (lhs: inout Matrix<Double>, rhs: Matrix<Double>) {
    lhs = lhs * rhs
}

public func += (lhs: inout Matrix<Double>, rhs: Double) {
    lhs = lhs + rhs
}

public func -= (lhs: inout Matrix<Double>, rhs: Double) {
    lhs = lhs - rhs
}

public func /= (lhs: inout Matrix<Double>, rhs: Double) {
    lhs = lhs / rhs
}

public func *= (lhs: inout Matrix<Double>, rhs: Double) {
    lhs = lhs * rhs
}

public prefix func -(mat: Matrix<Double>) -> Matrix<Double> {
    return -1.0 * mat
}

public func +(lhs: Matrix<Double>, rhs: Double) -> Matrix<Double> {
    var mat = lhs
    mat.grid = mat.grid + rhs
    return mat
}

public func -(lhs: Matrix<Double>, rhs: Double) -> Matrix<Double> {
    var mat = lhs
    mat.grid = mat.grid - rhs
    return mat
}

//MARK: LINEAR ALGEBRA
public func inv(_ x : Matrix<Double>) -> Matrix<Double> {
    precondition(x.rows == x.columns, "Matrix must be square")
    
    var results = x
    
    var ipiv = [__CLPK_integer](repeating: 0, count: x.rows * x.rows)
    var lwork = __CLPK_integer(x.columns * x.columns)
    var work = [CDouble](repeating: 0.0, count: Int(lwork))
    var error: __CLPK_integer = 0
    var nc = __CLPK_integer(x.columns)
    
    dgetrf_(&nc, &nc, &(results.grid), &nc, &ipiv, &error)
    dgetri_(&nc, &(results.grid), &nc, &ipiv, &work, &lwork, &error)
    
    assert(error == 0, "Matrix not invertible")
    
    return results
}

public func transpose(_ x: Matrix<Double>) -> Matrix<Double> {
    var results = Matrix<Double>(rows: x.columns, columns: x.rows, repeatedValue: 0.0)
    vDSP_mtransD(x.grid, 1, &(results.grid), 1, vDSP_Length(results.rows), vDSP_Length(results.columns))
    
    return results
}

public postfix func ′ (value: Matrix<Double>) -> Matrix<Double> {
    return transpose(value)
}

//MARK: CREATORS
public func randMatrix(_ rows: Int,_ columns: Int) -> Matrix<Double> {
    return Matrix<Double>(rows, columns, randArray(n: rows * columns))
}