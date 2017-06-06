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

        let N = 80
        let Nf = 5
        let w = Float(40)
        
        let x: [Float] = arange(0.0, w, w / Float(N))

        var s1 = sin(x) // * cos(x)
        var s2 = -cos(x)
        
        s1 -= s1.mean(); s1 /= s1.std()
        s2 -= s2.mean(); s2 /= s2.std()
        
//        let kern = RBF(alpha: 0.20, gamma: 10.0)
//        let A = kern.K(Matrix<Float>(N, 1, s2), Matrix<Float>(N, 1, s2))
        
        let (m1, m2) = (Matrix<Float>(N, 1, s1), Matrix<Float>(N, 1, s1))
        let A =  m1 * m2.t + eye(N) // * 50.0

        let v: Matrix<Float> = zeros(1, N)
        
        let gauss = MultivariateNormal(v, A)
        let X: Matrix<Float> = gauss.rvs(Nf) // * 20.0
        
        
        let xx = x.cgFloat
        let colors = [UIColor.black, UIColor.blue, UIColor.brown, UIColor.gray, UIColor.red]
        for i in 0..<Nf {
            let yy = X[i].cgFloat
            _ = graph.plot(x: xx * 8.0, y: yy * 5.0, c: colors[i])

        }
        
        graph.scatter(x: xx * 8.0, y: (s1 * s2 * 5.0).cgFloat, c: UIColor.green, s: 2.0)
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

