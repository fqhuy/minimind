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
