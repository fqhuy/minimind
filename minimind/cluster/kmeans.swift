//
//  kmeans.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/10/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

//typealias NumericType = Float

class KMeans {
    typealias ScalarT = Float
    typealias MatrixT = Matrix<ScalarT>
    
    public var clusterCenters: MatrixT
    public var nClusters: Int
    var tol: ScalarT
    
    public init(_ nClusters: Int, _ tol: ScalarT = 1e-5) {
        self.nClusters = nClusters
        self.clusterCenters = MatrixT()
        self.tol = tol
    }
    
    public func fit(_ X: MatrixT) {
        let (N, D) = X.shape
        var Z: Matrix<Int> = zeros(N, nClusters)
        Z[0∶, 0] = ones(N, 1)
        
        var J = ScalarT(1e10)
        var oldJ = ScalarT(0.0)
        while J - oldJ > tol {
            
        }
    }
    
    static func kMeansPlusPlus(_ X: MatrixT, _ XSquaredNorm: MatrixT, _ nClusters: Int, _ nTrials: Int?) -> MatrixT {
        let (N, D) = X.shape
        var centers: MatrixT = zeros(nClusters, D)
        var nT = 5
        if nTrials == nil {
            nT =  2 + Int(log(Float(nClusters)))
        } else {
            nT = nTrials!
        }
        
        let centerId = Randoms.randomInt(0, N)
        centers[0] = X[centerId]
        var closestDistSq = euclideanDistances(X: centers[0].reshape([1, D]), Y: X, YNormSquared: XSquaredNorm, squared: true, XNormSquared: nil)
        
        var currentPot = closestDistSq.sum()[0, 0]
        
        for c in 1..<nClusters {
            let randVals = randMatrix(1, nT) * currentPot
            let candidateIds = searchsorted(closestDistSq.cumsum().grid, randVals.grid)
            
            let distanceToCandidates = euclideanDistances(X: X[candidateIds], Y: X, YNormSquared: XSquaredNorm, squared: true, XNormSquared: nil)
            
            var bestCandidate: Int = -1
            var bestPot: Float = 0.0
            var bestDistSq: [Float] = []
            for trial in 0..<nT {
                let newDistSq = minimum(closestDistSq.grid, distanceToCandidates[trial].grid)
                let newPot = newDistSq.sum()
                
                if (bestCandidate == -1) || (newPot < bestPot) {
                    bestCandidate = candidateIds[trial]
                    bestPot = newPot
                    bestDistSq = newDistSq
                }
            }
            
            centers[c] = X[bestCandidate]
            currentPot = bestPot
            closestDistSq.grid = bestDistSq
        }
        
        return centers
    }
}
