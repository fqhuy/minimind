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
        
        let kern = RBF(variance: 300.0, lengthscale: 1000.0, X: X)
        let gp = GaussianProcessRegressor<RBF>(kernel: kern, alpha: 1.0)
        gp.fit(X, Y, maxiters: 1000)
        
        print(gp.kernel.getParams())
        
        let Xstar = Matrix<Float>(-1, 1, arange(-1.5, 1.5, 0.1))
        let (Mu, Sigma) = gp.predict(Xstar)

        _ = graph.plot(x: Xstar.grid.cgFloat, y: (Mu + diag(Sigma)).grid.cgFloat , c: UIColor.blue, s: 1.0)
        _ = graph.plot(x: Xstar.grid.cgFloat, y: (Mu - diag(Sigma)).grid.cgFloat, c: UIColor.blue, s: 1.0)
        
        _ = graph.plot(x: Xstar.grid.cgFloat, y: Mu.grid.cgFloat, c: UIColor.red, s: 3.0)
        _ = graph.scatter(x: X.grid.cgFloat, y: Y.grid.cgFloat, c: UIColor.green, s: 10.0)
        
        graph.autoScale()
    }
    
    func visualiseMixtureOfGaussians() {
        let cov = Matrix<Float>([[1.0, 0.1],[0.1, 1.0]])
        let mean1 = Matrix<Float>([[-5.0, 0.0]])
        let mean2 = Matrix<Float>([[5.0, 0.0]])
        let mean3 = Matrix<Float>([[0.0, 5.0]])
        
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
        
        graph.autoScale(true)
        graph.autoScaleAll(true)
    }
    
    func testImage2D() {
        var A: Matrix<Float> = randMatrix(20, 20)
        A = A ⊗ ones(3, 3)
        
        _ = graph.imshow(A, "bicubic", "jet")
        graph.autoScale()
        graph.autoScaleAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testImage2D()
//        visualiseMixtureOfGaussians()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

