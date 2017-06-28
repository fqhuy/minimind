//
//  error_handling.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/27/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation


enum MatrixError: Error {
    case notInvertible
    case notPSD
    case notPD
}

enum ParameterError: Error {
    case invalidParams
    case negativeParams
    case positiveParams
    case infiniteParams
}

public func checkPSD(_ mat: Matrix<Float>) -> Bool {
    do {
        try cholesky(mat)
    } catch MatrixError.notPSD {
        return false
    } catch {
        return false
    }
    return true
}
