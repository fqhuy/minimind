//
//  base_estimator.swift
//  minimind
//
//  Created by Phan Quoc Huy on 7/20/16.
//  Copyright © 2016 Phan Quoc Huy. All rights reserved.
//

import Foundation
//import Surge

public protocol BaseEstimator {
    associatedtype ScalarT
    typealias MatrixT = Matrix<ScalarT>
    
    func getParams() -> [String:Any]
    func setParams(params: [String:Any])
}

public protocol Regressor {
    associatedtype ScalarT
    typealias MatrixT = Matrix<ScalarT>
    
    func score(X: MatrixT, y: MatrixT) -> ScalarT
    func fit(X: MatrixT, Y: MatrixT)
    func predict(Xstar: MatrixT) -> MatrixT
}

public protocol Classifier {
    
}

extension BaseEstimator {
    public func getParams() -> [String:Any] {
        return [:]
    }
    
    public func setParams(params: [String:Any]) {
        
    }
}
