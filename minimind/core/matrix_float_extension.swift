//
//  matrix_float_extension.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/10/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Accelerate

public extension Matrix where T == Float {
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
    
    public func cumsum(_ axis: Int = -1) -> Matrix {
        if axis == 0 {
            var m: Matrix = zeros(rows, columns)
            for col in 0..<columns {
                m[0∶, col] = Matrix(rows, 1, self[column: col].grid.cumsum())
            }
            return m
        } else if axis == 1 {
            var m: Matrix = zeros(rows, columns)
            for row in 0..<rows {
                m[row, 0∶] = Matrix(1, columns, self[row].grid.cumsum())
            }
            return m
        } else {
            var m = self
            m.grid = grid.cumsum()
            return m
        }
    }
}

//MARK: ARITHMETIC
public func add(_ x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    precondition(x.rows == y.rows && x.columns == y.columns, "Matrix dimensions not compatible with addition")
    
    var results = y
    cblas_saxpy(Int32(x.grid.count), 1.0, x.grid, 1, &(results.grid), 1)
    
    return results
}

public func mul(_ alpha: Float, x: Matrix<Float>) -> Matrix<Float> {
    var results = x
    cblas_sscal(Int32(x.grid.count), alpha, &(results.grid), 1)
    
    return results
}

public func mul(_ x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    precondition(x.columns == y.rows, "Matrix dimensions not compatible with multiplication")
    
    var results = Matrix<Float>(rows: x.rows, columns: y.columns, repeatedValue: 0.0)
    cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, Int32(x.rows), Int32(y.columns), Int32(x.columns), 1.0, x.grid, Int32(x.columns), y.grid, Int32(y.columns), 0.0, &(results.grid), Int32(results.columns))
    
    return results
}

public func elmul(_ x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    precondition(x.rows == y.rows && x.columns == y.columns, "Matrix must have the same dimensions")
    var result = Matrix<Float>(rows: x.rows, columns: x.columns, repeatedValue: 0.0)
    result.grid = x.grid * y.grid
    return result
}


public func div(_ x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    let yInv = inv(y)
    precondition(x.columns == yInv.rows, "Matrix dimensions not compatible")
    return mul(x, y: yInv)
}

public func pow(_ x: Matrix<Float>, _ y: Float) -> Matrix<Float> {
    var result = Matrix<Float>(rows: x.rows, columns: x.columns, repeatedValue: 0.0)
    result.grid = pow(x.grid, y)
    return result
}

public func exp(_ x: Matrix<Float>) -> Matrix<Float> {
    var result = Matrix<Float>(rows: x.rows, columns: x.columns, repeatedValue: 0.0)
    result.grid = exp(x.grid)
    return result
}

public func + (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return add(lhs, y: rhs)
}

public func -(lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return lhs + (-rhs)
}

public func * (lhs: Float, rhs: Matrix<Float>) -> Matrix<Float> {
    return mul(lhs, x: rhs)
}

public func * (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return mul(lhs, y: rhs)
}

public func / (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return div(lhs, y: rhs)
}

public func += (lhs: inout Matrix<Float>, rhs: Matrix<Float>) {
    lhs = lhs + rhs
}

public func -= (lhs: inout Matrix<Float>, rhs: Matrix<Float>) {
    lhs = lhs - rhs
}

public func /= (lhs: inout Matrix<Float>, rhs: Matrix<Float>) {
    lhs = lhs / rhs
}

public func *= (lhs: inout Matrix<Float>, rhs: Matrix<Float>) {
    lhs = lhs * rhs
}

public func += (lhs: inout Matrix<Float>, rhs: Float) {
    lhs = lhs + rhs
}

public func -= (lhs: inout Matrix<Float>, rhs: Float) {
    lhs = lhs - rhs
}

public func /= (lhs: inout Matrix<Float>, rhs: Float) {
    lhs = lhs / rhs
}

public func *= (lhs: inout Matrix<Float>, rhs: Float) {
    lhs = lhs * rhs
}

public prefix func -(mat: Matrix<Float>) -> Matrix<Float> {
    return -1.0 * mat
}

public func +(lhs: Matrix<Float>, rhs: Float) -> Matrix<Float> {
    var mat = lhs
    mat.grid = mat.grid + rhs
    return mat
}

public func -(lhs: Matrix<Float>, rhs: Float) -> Matrix<Float> {
    var mat = lhs
    mat.grid = mat.grid - rhs
    return mat
}


//MARK: LINEAR ALGEBRA
public func inv(_ x : Matrix<Float>) -> Matrix<Float> {
    precondition(x.rows == x.columns, "Matrix must be square")
    
    var results = x
    
    var ipiv = [__CLPK_integer](repeating: 0, count: x.rows * x.rows)
    var lwork = __CLPK_integer(x.columns * x.columns)
    var work = [CFloat](repeating: 0.0, count: Int(lwork))
    var error: __CLPK_integer = 0
    var nc = __CLPK_integer(x.columns)
    
    sgetrf_(&nc, &nc, &(results.grid), &nc, &ipiv, &error)
    sgetri_(&nc, &(results.grid), &nc, &ipiv, &work, &lwork, &error)
    
    assert(error == 0, "Matrix not invertible")
    
    return results
}

public func inv(_ mat: Matrix<Float>, _ uplo: String) -> Matrix<Float> {
    
    if uplo == "N" {
        return inv(mat)
    } else if (uplo == "U" || uplo == "L")  {
        var A = mat
        var uplo: Int8 = ascii(uplo)
        var dia: Int8 = ascii("N")
        var n: __CLPK_integer = __CLPK_integer(A.rows)
        var info: __CLPK_integer = __CLPK_integer(0)
        
        strtri_(&uplo, &dia, &n, &(A.grid), &n, &info)
        return A
    } else {
        return mat
    }
}

public func cholesky(_ mat: Matrix<Float>, _ uplo: String = "U") -> Matrix<Float> {
    precondition(mat.rows == mat.columns, "Matrix must be square")
    var L = mat
    var _uplo: Int8 = ascii(uplo)
    var n: __CLPK_integer = __CLPK_integer(mat.rows)
    var info: __CLPK_integer = 0
    spotrf_(&_uplo, &n, &(L.grid), &n, &info )
    
    assert(info == 0, "Cholesky failed: " + String(info) )
    switch uplo {
    case "L":
        return triu(L).t
    case "U":
        return tril(L).t
    default:
        return triu(L).t
    }
}

public func ldlt(_ mat: Matrix<Float>, _ uplo: String = "L") -> Matrix<Float> {
    var L = mat
    var _uplo: Int8 = ascii(uplo)
    var n: __CLPK_integer = __CLPK_integer(mat.rows)
    var info: __CLPK_integer = 0
    var lwork = __CLPK_integer(mat.columns * mat.columns)
    var work = [CFloat](repeating: 0.0, count: Int(lwork))
    var ipiv: [__CLPK_integer] = [__CLPK_integer](repeating: 0, count: Int(n))
    ssytrf_(&_uplo, &n, &(L.grid), &n, &ipiv, &work, &lwork, &info)
    
    assert(info == 0, "LDLT failed")
    return L
}

public func svd(_ mat: Matrix<Float>, _ jobu: String = "A", _ jobv: String = "A", _ ldu: Int = 1, _ ldvt: Int = 1) -> (Matrix<Float>, Matrix<Float>, Matrix<Float>) {
    //    SGESVD
    var A = mat
    var m: __CLPK_integer = __CLPK_integer(mat.rows)
    var n: __CLPK_integer = __CLPK_integer(mat.columns)
    var _jobu = ascii(jobu)
    var _jobv = ascii(jobv)
    var s: Matrix<Float> = zeros(1, Int(min(m, n)))
    
    var _ldu = __CLPK_integer(ldu)
    if jobu == "A" || jobu == "S" {
        _ldu = m
    }
    
    var u: Matrix<Float> = Matrix()
    if jobu == "S" {
        u = zeros(Int(_ldu), Int(m))
    }
    else if jobu == "S" {
        u = zeros(Int(_ldu), Int(min(m,n)))
    }
    
    var _ldvt = __CLPK_integer(ldvt)
    if jobv == "A" {
        _ldvt = n
    } else if jobv == "S" {
        _ldvt = min(m, n)
    }
    
    var vt: Matrix<Float> = zeros(Int(_ldvt), Int(n))
    
    var info: __CLPK_integer = 0
    
    let (v1, v2) = (3 * min(m,n) + max(m,n), 5 * min(m,n))
    var lwork = __CLPK_integer(max(max(v1, v2), 1)) // __CLPK_integer(mat.columns * mat.columns)
    var work = [CFloat](repeating: 0.0, count: Int(lwork))
    sgesvd_(&_jobu, &_jobv, &m, &n, &(A.grid), &m, &(s.grid), &(u.grid), &_ldu, &(vt.grid), &_ldvt, &work, &lwork, &info)
    
    assert(info == 0, "SVD failed")
    
    return (u, s, vt)
}


public func logdet(_ mat: Matrix<Float>) -> Float {
    //    let L = cholesky(mat, "L")
    let L = ldlt(mat, "L")
    return (2.0 * reduce_sum(log(diag(L)))!)[0,0]
}

public func det(_ mat: Matrix<Float>) -> Float {
    //    let L = cholesky(mat, "L")
    let L = ldlt(mat, "L")
    return  powf(reduce_prod(diag(L))![0, 0], 2)
}

public func solve_triangular(_ A: Matrix<Float>, _ b: Matrix<Float>, _  uplo: String = "L", _ trans: String = "N") -> Matrix<Float> {
    var aa = A
    var bb = b
    var uplo: Int8 = ascii(uplo)
    var trans: Int8 = ascii("N")
    var dia: Int8 = ascii("N")
    var n: __CLPK_integer = __CLPK_integer(A.rows)
    var nrhs: __CLPK_integer = __CLPK_integer(b.columns)
    var info: __CLPK_integer = __CLPK_integer(0)
    
    strtrs_(&uplo, &trans, &dia, &n, &nrhs, &(aa.grid), &n, &(bb.grid), &n, &info)
    assert(info == 0, "solve triangular failed")
    
    return bb
}

public func cho_solve(_ A: Matrix<Float>, _ b: Matrix<Float>, _  uplo: String = "L") -> Matrix<Float> {
    var aa = A
    var bb = b
    var _uplo: Int8 = ascii(uplo)
    var n: __CLPK_integer = __CLPK_integer(A.rows)
    var nrhs: __CLPK_integer = __CLPK_integer(b.columns)
    var info: __CLPK_integer = __CLPK_integer(0)
    
    spotrs_(&_uplo, &n, &nrhs, &(aa.grid), &n, &(bb.grid), &n, &info)
    assert(info == 0, "Cholesky solve failed")
    
    return bb
}

public func eigh(_ mat: Matrix<Float>, _ uplo: String) -> (Matrix<Float>, Matrix<Float>) {
    var A = mat
    var uplo: Int8 = ascii(uplo)
    var n = __CLPK_integer(A.rows)
    var d = [CFloat](repeating: 0.0, count: A.rows)
    var e = [CFloat](repeating: 0.0, count: A.rows - 1)
    var tau = [CFloat](repeating: 0.0, count: A.rows - 1)
    // CHECK THIS
    var lwork = __CLPK_integer(mat.columns * mat.columns)
    var work = [CFloat](repeating: 0.0, count: Int(lwork))
    var info: __CLPK_integer = 0
    
    ssytrd_(&uplo, &n, &(A.grid), &n, &d, &e, &tau, &work, &lwork, &info)
    
    assert(info == 0, "QTQ failed")
    
    sorgtr_(&uplo, &n, &(A.grid), &n, &tau, &work, &lwork, &info)
    
    assert(info == 0, "Q computation failed")
    
    var compz: Int8 = ascii("V")
    ssteqr_(&compz, &n, &d, &e, &(A.grid), &n, &work, &info)
    
    assert(info == 0, "QR failed")
    
    return (Matrix<Float>(1, Int(n), d), A)
}

public func transpose(_ x: Matrix<Float>) -> Matrix<Float> {
    var results = Matrix<Float>(rows: x.columns, columns: x.rows, repeatedValue: 0.0)
    vDSP_mtrans(x.grid, 1, &(results.grid), 1, vDSP_Length(results.rows), vDSP_Length(results.columns))
    
    return results
}

postfix operator ′
public postfix func ′ (value: Matrix<Float>) -> Matrix<Float> {
    return transpose(value)
}

infix operator ⊗
//Kronecker product
public func ⊗ (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    var mat: Matrix<Float> = zeros(lhs.rows * rhs.rows, lhs.columns * rhs.columns)
    for lr in 0..<lhs.rows {
        for lc in 0..<lhs.columns {
            for rr in 0..<rhs.rows {
                for rc in 0..<rhs.columns {
                    mat[lr * rhs.rows + rr, lc * rhs.columns + rc] = lhs[lr, lc] * rhs[rr, rc]
                }
            }
        }
        
    }
    return mat
}

//MARK: MATH FUNCTIONS

public func norm(_ mat: Matrix<Float>, _ ord: String) -> Float {
    var n = __CLPK_integer(mat.columns)
    var m = __CLPK_integer(mat.rows)
    var a = mat
    var norm = ascii(ord)
    var work = [__CLPK_real](repeatElement(0.0, count: Int(m)))
    
    let re = slange_(&norm, &m, &n, &(a.grid), &m, &work)
    return Float(re)
}

public func log(_ mat: Matrix<Float>) -> Matrix<Float> {
    return Matrix<Float>(mat.rows, mat.columns, log(mat.grid))
}

//MARK: CREATORS
public func randMatrix(_ rows: Int,_ columns: Int) -> Matrix<Float> {
    return Matrix<Float>(rows, columns, randArray(n: rows * columns))
}
