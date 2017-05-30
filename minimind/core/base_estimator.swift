//
//  base_estimator.swift
//  minimind
//
//  Created by Phan Quoc Huy on 7/20/16.
//  Copyright © 2016 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Surge

public protocol BaseEstimator {
    func get_params() -> [String:Any]
    func set_params(params: [String:Any])
}

public protocol RegressorMixin {
    associatedtype MatrixT
    associatedtype ScalarT
    func score(X: MatrixT, y: MatrixT) -> ScalarT
}


extension BaseEstimator {
    public func get_params() -> [String:Any] {
        return [:]
    }
    
    public func set_params(params: [String:Any]) {
        
    }
}
