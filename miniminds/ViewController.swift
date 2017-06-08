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
        let Nf = 10
        let w = Float(300.0)
        let y: [Float] = arange(0.0, w, w / Float(N))
        
        let X = Matrix<Float>([[-0.91261869,  1.85426673],
                               [ 1.34207648, -1.08250752],
                               [ 1.13998253,  0.69448722],
                               [ 0.40357421, -0.4739292 ],
                               [ 0.81214299, -1.23548637],
                               [-0.7030745,  -0.78750967],
                               [-0.50155067,  0.464332  ],
                               [-1.58053235,  0.56634682]])
        
        let Y = Matrix<Float>([[0.21198747,  0.0883193,   0.4570866,   0.17492527,  0.03589,     0.06420726,
                                0.19189653,  0.03121346]]).t
        
        let kern = RBF(variance: 0.5, lengthscale: 100.0)
        let v: Matrix<Float> = zeros(1, N)
        
        let gp = GaussianProcessRegressor<Float, RBF>(kernel: kern, alpha: 1.0)
        gp.fit(X, Y, maxiters: 500)
        
        let gauss = MultivariateNormal(v, kern.K(X, X))
        let S: Matrix<Float> = gauss.rvs(Nf) // * 20.0
        
        
        let xx = y.cgFloat
        let colors = [UIColor.black, UIColor.blue, UIColor.brown, UIColor.gray, UIColor.red, UIColor.black, UIColor.blue, UIColor.brown, UIColor.gray, UIColor.red]
        for i in 0..<Nf {
            let yy = S[i].cgFloat
            _ = graph.plot(x: xx * 8.0, y: yy * 20.0, c: colors[i])

        }
        
//        graph.scatter(x: xx * 8.0, y: (s1 * s2 * 5.0).cgFloat, c: UIColor.green, s: 2.0)
//
//        let Cov = Matrix<Float>([[1.0, 0.2],[0.1, 1.4]])
//        let Mean: Matrix<Float> = Matrix([[0.0, 0.0]])
//        
//        let gauss = MultivariateNormal(Mean, Cov)
//        var X: Matrix<Float> = gauss.rvs(200)
//        print(X[column: 0].mean())
//        print(X[column: 1].mean())
//        
//        X = X * 20.0
//        _ = graph.scatter(x:  (X[column: 0] ).cgFloat,
//                          y: (X[column: 1]).cgFloat, c: UIColor.blue, s: 5.0)
//        
////        _ = graph.scatter(x: [0.0], y: [0.0], c: UIColor.red, s: 10.0)
//        print(X[column: 0].mean())
//        print(X[column: 1].mean())

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

