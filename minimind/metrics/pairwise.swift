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
    
    var YY: Matrix<Float> = zeros(1, Y.rows)
    switch YNormSquared {
    case nil: YY = (Y ∘ Y).sum(axis: 1).t
        default: YY = YNormSquared!
    }
    
    var XX: Matrix<Float> = zeros(X.rows, 1)
    switch XNormSquared {
        case nil:
            XX = (X ∘ X).sum(axis: 1)
        default:
            XX = XNormSquared!
    }
    
    var dists = -2.0 * (X * Y′)
    dists = dists |+ XX
    dists = dists .+ YY
    
    dists = clip(dists, 0, MAXFLOAT)
    if squared {
        return dists
    } else {
        return sqrt(dists)
    }
}
