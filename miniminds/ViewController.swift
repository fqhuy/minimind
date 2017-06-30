//
//  ViewController.swift
//  miniminds
//
//  Created by Phan Quoc Huy on 6/4/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import UIKit
import minimind

extension Array where Element == Float {
    public var cgFloat: [CGFloat] {
        get {
            return self.map{ CGFloat($0) }
        }
    }
}


class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Delegate

    
    //MARK: Actions
    
    
    //MARK: Properties
//    @IBOutlet weak var graph: GraphView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var graph: GraphView!

    
    func visualise1DRegression() {
        let N = 8
        
        let Nf = 20
        let X = Matrix<Float>([[-1.50983293], [-1.11726642], [-0.89303372], [ 0.07971517], [ 0.29116607], [ 0.7494249 ], [ 0.93321463], [ 1.46661229]])
        
        let Y = Matrix<Float>([[ 0.04964821,  0.0866106,  0.16055375,  0.58936555,  0.71558366,  1.00004714,  1.08412273,  1.42418915]]).t
        
        let kern = RBF(variance: 100.0, lengthscale: 100.0, X: X, trainables: ["logVariance", "logLengthscale"])
        let gp = GaussianProcessRegressor<RBF>(kernel: kern, alpha: 0.5)
        gp.fit(X, Y, maxiters: 100)
        
        print(gp.kernel.variance, gp.kernel.lengthscale)
        
        let Xstar = Matrix<Float>(-1, 1, arange(-1.5, 1.5, 0.1))
        let (Mu, Sigma) = gp.predict(Xstar)

        _ = graph.plot(x: Xstar.grid.cgFloat, y: (Mu + diag(Sigma)).grid.cgFloat , c: UIColor.blue, s: 1.0)
        _ = graph.plot(x: Xstar.grid.cgFloat, y: (Mu - diag(Sigma)).grid.cgFloat, c: UIColor.blue, s: 1.0)
        
        _ = graph.plot(x: Xstar.grid.cgFloat, y: Mu.grid.cgFloat, c: UIColor.red, s: 3.0)
        _ = graph.scatter(x: X.grid.cgFloat, y: Y.grid.cgFloat, c: UIColor.green, s: 10.0)
        
        graph.autoScaleAll()
    }
    
    func visualisePCA() {
        let cov = Matrix<Float>([[1.0, 0.1],[0.1, 1.0]])
        let mean1 = Matrix<Float>([[-5.0, 0.0]])
        let mean2 = Matrix<Float>([[5.0, 0.0]])
        let mean3 = Matrix<Float>([[0.0, 10.0]])
        
        let X1 = MultivariateNormal(mean: mean1, cov: cov).rvs(50)
        let X2 = MultivariateNormal(mean: mean2, cov: cov).rvs(50)
        let X3 = MultivariateNormal(mean: mean3, cov: cov).rvs(50)
        
        let X = vstack([X1, X2, X3])
        
        let A: Matrix<Float> = randMatrix(2, 15)
        let Y = X * A + 0.01 * randMatrix(150, 15)
        
        let pca = PCA(2)
        pca.fit(Y)
        let Xpred = pca.predict(Y)
        
        _ = graph.scatter(x: Xpred[∶50, 0].grid.cgFloat, y: Xpred[∶50, 1].grid.cgFloat, c: UIColor.green, s: 10.0)
        _ = graph.scatter(x: Xpred[50∶100, 0].grid.cgFloat, y: Xpred[50∶100, 1].grid.cgFloat, c: UIColor.red, s: 10.0)
        _ = graph.scatter(x: Xpred[100∶, 0].grid.cgFloat, y: Xpred[100∶, 1].grid.cgFloat, c: UIColor.blue, s: 10.0)
        
        graph.autoScaleAll(true)
    }
    
    func visualiseGPLVM() {
        let N = 20
        let D = 10
        let Q = 2
        
        var Y: Matrix<Float> = zeros(N, D)
        var X: Matrix<Float> = zeros(N, Q)
        
        let cov = Matrix<Float>([[1.0, 0.1],[0.1, 1.0]])
        let mean1 = Matrix<Float>([[-3, 0]])
        let mean2 = Matrix<Float>([[3, 0]])
        
        let X1 = MultivariateNormal(mean: mean1, cov: cov).rvs(N / 2)
        let X2 = MultivariateNormal(mean: mean2, cov: cov).rvs(N / 2)
        
        let xx = vstack([X1, X2])
        X = xx .- xx.mean(0)
        X = X ./ X.std(0)
        
        let A: Matrix<Float> = randMatrix(2, D)
        Y = X * A + 0.01 * randMatrix(N, D)
        
        let pca = PCA(Q)
        pca.fit(Y)
        let initX = pca.predict(Y)
        
        let kern = RBF(variance: 10, lengthscale: 10, X: initX, trainables: ["logVariance", "logLengthscale", "X"])
        let gp = GaussianProcessRegressor<RBF>(kernel: kern, alpha: 0.8)
        gp.fit(X, Y, maxiters: 1000)
        
        print(gp.kernel.variance, gp.kernel.lengthscale)
        
        let Xpred = gp.kernel.X
        
        let (maxX, maxY) = tuple(max(Xpred, axis: 0).grid)
        let (minX, minY) = tuple(min(Xpred, axis: 0).grid)
        
        let Xs: [Float] = linspace(minX, maxX, 20)
        let Ys: [Float] = linspace(minY, maxY, 20)
        let (Xss, Yss) = meshgrid(Xs,Ys)
        let XX: Matrix<Float> = hstack([Xss.reshape([-1, 1]), Yss.reshape([-1, 1])])
        
        let (Mu, Sigma) = gp.predict(XX)
//        _ = graph.imshow(Sigma.reshape([20, 20]), "bicubic", "luce")
        
        _ = graph.scatter(x: Xpred[∶10, 0].grid.cgFloat, y: Xpred[∶10, 1].grid.cgFloat, c: UIColor.green, s: 10.0)
        _ = graph.scatter(x: Xpred[10∶20, 0].grid.cgFloat, y: Xpred[10∶20, 1].grid.cgFloat, c: UIColor.red, s: 10.0)
        
        graph.autoScaleAll()
    }
    
    func visualiseGaussian() {
        let sigma = Matrix<Float>([[1.0, -0.1],[2.2, 5.0]])
        let mu = Matrix<Float>([[0.0, 0.0]])
        
        let n = 10
        let (X, Y) = meshgrid(linspace(Float(-3.0), Float(3.0), n), linspace(Float(-3.0), Float(3.0), n))
        let XX: Matrix<Float> = hstack([X.reshape([-1, 1]), Y.reshape([-1, 1])])
        let Z = MultivariateNormal(mean: mu, cov: sigma).pdf(XX).reshape([n, n])
        
        _ = graph.imshow(Z, "bicubic", "luce")
        
        graph.autoScaleAll()

    }
    
    class  Rosenbrock: ObjectiveFunction {
        public typealias ScalarT = Float
        public typealias MatrixT = Matrix<ScalarT>
        
        public var dims: Int = 2
        
        func compute(_ x: Matrix<Float>) -> Float {
            return 100.0 * powf(x[0, 1] - powf(x[0, 0], 2), 2) + powf(1.0 - x[0, 1], 2)
        }
        
        func gradient(_ x: Matrix<Float>) -> Matrix<Float> {
            let gX1 = -400.0 * x[0, 0] * (x[0, 1] - powf(x[0, 0], 2)) - 2.0 * (1.0 - x[0, 0])
            let gX2 = 200.0 * (x[0, 1] - powf(x[0, 0], 2))
            return Matrix<Float>([[gX1,  gX2]])
        }
        
        func hessian(_ x: Matrix<Float>) -> Matrix<Float> {
            let h11 = 1200.0 * powf(x[0, 0], 2) - 400.0 * x[0, 1] + 2.0
            let h12 = -400.0 * x[0, 0]
            return Matrix<Float>([[ h11, h12], [-400.0 * x[0, 0], 200.0 ] ])
        }
    }
    
    func testRosenbrock() {
        let rb = Rosenbrock()
        let n = 20
        
        let (X, Y) = meshgrid(linspace(Float(0.0), Float(2.0), n), linspace(Float(0.0), Float(2.0), n))
        let XX: Matrix<Float> = hstack([X.reshape([-1, 1]), Y.reshape([-1, 1])])
        var ZZ: Matrix<Float> = zeros(XX.rows, 1)
        for i in 0..<XX.rows {
            let z = rb.compute(XX[i])
            ZZ[i, 0] = z
        }
//        _ = graph.imshow(ZZ.reshape([n, n]).t, "bicubic", "luce")
//        graph.xOrigin = 0.0
//        graph.yOrigin = 0.0
//        graph.autoScaleAll()

        let x0 = Matrix<Float>([[2.2, 1.2]])
        let initH: Matrix<Float> =   inv(rb.hessian(x0)) // Matrix([[1.0, 0.0],[0.0, 1.0]]) //
        let optimizer = QuasiNewtonOptimizer(objective: rb, stepLength: 1.0, initX: x0, initH: nil, gTol: 1e-5, maxIters: 200, fTol: 1e-8, alphaMax: 2.0)
//                let optimizer = NewtonOptimizer(objective: rb, stepLength: 1.0, initX: Matrix<Float>([[-1.2, 1.0]]), maxIters: 200)
//        let optimizer = SteepestDescentOptimizer(objective: rb, stepLength: 2.0, initX: Matrix<Float>([[-1.2, 1.0]]), maxIters: 500)
        let (x, fvals, iters) = optimizer.optimize(verbose: true)
        
        var xx: [Float] = []
        var yy: [Float] = []
        for i in 0..<optimizer.Xs.count {
            xx.append(optimizer.Xs[i][0, 0])
            yy.append(optimizer.Xs[i][0, 1])
        }
        
        xx = xx - mean(xx)
        yy = yy - mean(yy)
        graph.plot(x: xx.cgFloat, y: yy.cgFloat, c: UIColor.green, s: 3.0)
        
        print (optimizer.Xs)
        graph.autoScaleAll()

    }
    
    func testImage2D() {
        var A: Matrix<Float> = randMatrix(20, 20)
        _ = graph.imshow(A, "bicubic", "luce")
        graph.autoScaleAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        testRosenbrock()
//        testImage2D()
//        visualiseMixtureOfGaussians()
//        visualiseGaussian()
//        visualise1DRegression()
//        visualisePCA()
        visualiseGPLVM()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

