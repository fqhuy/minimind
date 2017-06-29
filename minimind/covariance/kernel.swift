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
    typealias MatrixT = Matrix<ScalarT>
    
    var parametersData: [ScalarT] {get set}
    var parametersIds: [String:[IndexType]] {get set}
    var trainables: [String] {get set}
    var trainableIds: [IndexType] {get}
    var X: MatrixT {get}
    var nFeatures: Int {get}
    var nDataPoints: Int {get}
    
    init()
    
    func K(_ X: MatrixT, _ Y: MatrixT) -> MatrixT
    
    /// comute the gradient of K w.r.t all parameters
    /// - Parameter X, Y: data points
    /// - Parameter dLdK: gradient of an objective function w.r.t this kernel
    /// - Returns: gradient of the parameters
    func gradient(_ X: MatrixT, _ Y: MatrixT, _ dLdK: MatrixT) -> MatrixT
    
    /// each kernel should know how to set it parameters, all combined in a single 1xP vector
    mutating func setParams(_ params: MatrixT)
    
    /// return a vector of concatenated parameters
    func getParams() -> MatrixT
    
    /// return a reasonable initialisation for all parameters
    func initParams() -> MatrixT
    
    /// number of hyper parameters
    var nDims: Int {get}
    
    /// parameters in log space
    //    var theta: MatrixT {get set}
    
    /// log prior
    var logPrior: ScalarT {get}
}

extension Kernel {
    public var trainableIds: [IndexType] {
        get {
            var ids: [IndexType] = []
            for t in trainables {
                ids.append(contentsOf: parametersIds[t]!)
            }
            return ids
        }
    }
    
    public mutating func setParams(_ params: MatrixT) {
        precondition(trainableIds.count == params.size)
        parametersData[trainableIds] = params.grid
    }
    
    public func getParams() -> MatrixT {
        return MatrixT([parametersData[trainableIds]])
    }
}
