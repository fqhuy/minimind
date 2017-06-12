//
//  matrix_bool_extension.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/10/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Accelerate

//MARK: COMPARISONS

public func all(_ mat: Matrix<Bool>) -> Bool {
    return all(mat.grid)
}

public func any(_ mat: Matrix<Bool>) -> Bool {
    return any(mat.grid)
}

public func ==<T: Equatable>(_ mat: Matrix<T>, _ t: T) -> Matrix<Bool> {
    return Matrix<Bool>(mat.rows, mat.columns, (mat.grid == t))
}

public func >=<T: Comparable>(_ mat: Matrix<T>, _ t: T) -> Matrix<Bool> {
    return Matrix<Bool>(mat.rows, mat.columns, (mat.grid >= t))
}

public func <= <T: Comparable>(_ mat: Matrix<T>, _ t: T) -> Matrix<Bool> {
    return Matrix<Bool>(mat.rows, mat.columns, (mat.grid <= t))
}

public func > <T: Comparable>(_ mat: Matrix<T>, _ t: T) -> Matrix<Bool> {
    return Matrix<Bool>(mat.rows, mat.columns, (mat.grid > t))
}

public func < <T: Comparable>(_ mat: Matrix<T>, _ t: T) -> Matrix<Bool> {
    return Matrix<Bool>(mat.rows, mat.columns, (mat.grid < t))
}

public func ==<T: Equatable>(_ t: T, _ mat: Matrix<T>) -> Matrix<Bool> {
    return Matrix<Bool>(mat.rows, mat.columns, (mat.grid == t))
}

public func >=<T: Comparable>(_ t: T, _ mat: Matrix<T>) -> Matrix<Bool> {
    return Matrix<Bool>(mat.rows, mat.columns, (mat.grid >= t))
}

public func <= <T: Comparable>(_ t: T, _ mat: Matrix<T>) -> Matrix<Bool> {
    return Matrix<Bool>(mat.rows, mat.columns, (mat.grid <= t))
}

public func > <T: Comparable>(_ t: T, _ mat: Matrix<T>) -> Matrix<Bool> {
    return Matrix<Bool>(mat.rows, mat.columns, (mat.grid > t))
}

public func < <T: Comparable>(_ t: T, _ mat: Matrix<T>) -> Matrix<Bool> {
    return Matrix<Bool>(mat.rows, mat.columns, (mat.grid < t))
}

public func ==<T: Equatable>(_ lhs: Matrix<T>, _ rhs: Matrix<T>) -> Matrix<Bool> {
    checkMatrices(lhs, rhs, "same")
    return Matrix<Bool>(lhs.rows, lhs.columns, (lhs.grid == rhs.grid))
}

public func >=<T: Comparable>(_ lhs: Matrix<T>, _ rhs: Matrix<T>) -> Matrix<Bool> {
    checkMatrices(lhs, rhs, "same")
    return Matrix<Bool>(lhs.rows, lhs.columns, (lhs.grid >= rhs.grid))
}

public func <= <T: Comparable>(_ lhs: Matrix<T>, _ rhs: Matrix<T>) -> Matrix<Bool> {
    checkMatrices(lhs, rhs, "same")
    return Matrix<Bool>(lhs.rows, lhs.columns, (lhs.grid <= rhs.grid))
}

public func > <T: Comparable>(_ lhs: Matrix<T>, _ rhs: Matrix<T>) -> Matrix<Bool> {
    checkMatrices(lhs, rhs, "same")
    return Matrix<Bool>(lhs.rows, lhs.columns, (lhs.grid > rhs.grid))
}

public func < <T: Comparable>(_ lhs: Matrix<T>, _ rhs: Matrix<T>) -> Matrix<Bool> {
    checkMatrices(lhs, rhs, "same")
    return Matrix<Bool>(lhs.rows, lhs.columns, (lhs.grid < rhs.grid))
}
