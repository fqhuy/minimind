//
//  stationary.swift
//  minimind
//
//  Created by Phan Quoc Huy on 5/29/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Surge

public protocol Kernel {
    associatedtype ScalarT
    associatedtype MatrixT
    
    init()
    
    func K(_ X: MatrixT, _ Y: MatrixT) -> MatrixT
    
    /// comute the gradient of K w.r.t all parameters
    /// - Parameter X, Y: data points
    /// - Parameter dLdK: gradient of an objective function w.r.t this kernel
    /// - Returns: gradient of the parameters
    func gradient(_ X: MatrixT, _ Y: MatrixT, _ dLdK: MatrixT) -> MatrixT
    
    /// each kernel should know how to set it parameters, all combined in a single 1xP vector
    func set_params(_ params: MatrixT)
    
    /// return a vector of concatenated parameters
    func get_params() -> MatrixT
    
    /// return a reasonable initialisation for all parameters
    func init_params() -> MatrixT
}


