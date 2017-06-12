//
//  pairwise.swift
//  minimind
//
//  Created by Phan Quoc Huy on 5/28/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

public func euclideanDistances(X: Matrix<Float>, Y: Matrix<Float>, YNormSquared: Matrix<Float>? = nil, squared: Bool=false,
                        XNormSquared: Matrix<Float>? = nil) -> Matrix<Float> {
    
    var YY: Matrix<Float> = zeros(Y.rows, 1)
    switch YNormSquared {
    case nil: YY = sqrt((Y ∘ Y).sum(1))
    default: YY = YNormSquared!
    }
    
//    var YY = YNormSquared!
//    if YNormSquared == nil {
//        YY = sqrt((Y ∘ Y).sum(1))
//    }
    
    var XX: Matrix<Float> = zeros(X.rows, 1)
    switch XNormSquared {
    case nil:
        XX = sqrt((X ∘ X).sum(1))
    default:
        XX = XNormSquared!
    }
    
//    if XNormSquared == nil {
//        XX = sqrt((Y ∘ Y).sum(1))
//    }
    
    var dists = -2.0 * (X * Y′)
    dists += XX
    dists += YY
    
    dists = clip(dists, 0, MAXFLOAT)
    return dists
}
