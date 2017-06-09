//
//  ViewController.swift
//  miniminds
//
//  Created by Phan Quoc Huy on 6/4/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import UIKit
import Surge
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

    override func viewDidLoad() {
        super.viewDidLoad()

        let N = 8
        
        let Nf = 20
        let X = Matrix<Float>([[-1.50983293], [-1.11726642], [-0.89303372], [ 0.07971517], [ 0.29116607], [ 0.7494249 ], [ 0.93321463], [ 1.46661229]])
        
        let Y = Matrix<Float>([[ 0.04964821,  0.0866106,  0.16055375,  0.58936555,  0.71558366,  1.00004714,  1.08412273,  1.42418915]]).t
        
        let kern = RBF(variance: 300.0, lengthscale: 1000.0)
        
        
        let gp = GaussianProcessRegressor<Float, RBF>(kernel: kern, alpha: 1.0)
        gp.fit(X, Y, maxiters: 500)
        
        print(gp.kernel.get_params())
        
        let Xstar = Matrix<Float>(-1, 1, arange(-1.5, 1.5, 0.1))
        let (Mu, Sigma) = gp.predict(Xstar)
//        let gauss = MultivariateNormal(Mu, Sigma)
//        let S: Matrix<Float> = gauss.rvs(Nf)
//        
//        let xx = Xstar.grid.cgFloat
//        for i in 0..<Nf {
//            let yy = S[i].cgFloat
//            _ = graph.plot(x: xx, y: yy, c: UIColor.blue, s: 2.0)
//
//        }
        _ = graph.plot(x: Xstar.grid.cgFloat, y: (Mu + diag(Sigma)).grid.cgFloat , c: UIColor.blue, s: 1.0)
        _ = graph.plot(x: Xstar.grid.cgFloat, y: (Mu - diag(Sigma)).grid.cgFloat, c: UIColor.blue, s: 1.0)
        
        _ = graph.plot(x: Xstar.grid.cgFloat, y: Mu.grid.cgFloat, c: UIColor.red, s: 3.0)
        _ = graph.scatter(x: X.grid.cgFloat, y: Y.grid.cgFloat, c: UIColor.green, s: 10.0)
        
        graph.autoscale()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

