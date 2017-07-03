//
//  kmeans.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/10/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

//typealias NumericType = Float

class KMeans: BaseEstimator {
    typealias ScalarT = Float
    typealias MatrixT = Matrix<ScalarT>
    
    public var clusterCenters: MatrixT
    public var labels: Matrix<IndexType>
    public var nClusters: Int
    var tol: ScalarT
    
    public init(_ nClusters: Int, _ tol: ScalarT = 1e-5) {
        self.nClusters = nClusters
        self.clusterCenters = MatrixT()
        self.labels = Matrix<IndexType>()
        self.tol = tol
    }
    
    public func fit(_ X: MatrixT, _ maxIters: Int, _ verbose: Bool) {
        let (N, D) = X.shape
        
        var iter = 0
        let XSq = (X ∘ X).sum(axis: 1)
        var centers: Matrix<ScalarT> = KMeans.kMeansPlusPlus(X, XSq, nClusters, nil)
        
        var score = ScalarT(1e10)
        var bestScore = ScalarT(1e9)
        var bestCenters: MatrixT = zeros(nClusters, D)
        var bestLabels: Matrix<IndexType> = -1 * ones(1, N)
        
        while (iter < maxIters) {
            
            // compute new score & new labels from current centers
            let dists = euclideanDistances(X: X, Y: centers, YNormSquared: nil, squared: true, XNormSquared: XSq)
            let lbls = argmin(dists, 1)
            score = min(dists, axis: 1).grid.sum()
            
            // compute new means from labels
            for c in 0..<nClusters {
                centers[c] = X[nonzero(lbls.grid == c)].mean(axis: 0)
            }
            
            if norm(centers - bestCenters, "F") < tol {
                break
            }
            
            if score < bestScore {
                bestScore = score
                bestCenters = centers
                bestLabels = lbls
            }
            
            iter += 1
            if verbose {
                print(String(format: "score: %4.2f", score))
            }
        }
        
        clusterCenters = bestCenters
        self.labels = bestLabels
    }
    
    public func predict(_ Xstar: MatrixT) -> Matrix<IndexType> {
        let CSq = (clusterCenters ∘ clusterCenters).sum(axis: 1)
        let dists = euclideanDistances(X: Xstar, Y: clusterCenters, YNormSquared: CSq, squared: true, XNormSquared: nil)
        let lbls = argmin(dists, 1)
        return lbls
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
            let candidateIds = searchsorted(closestDistSq.grid.cumsum(), randVals.grid)
            
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
