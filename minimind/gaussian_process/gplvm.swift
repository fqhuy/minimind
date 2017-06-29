//
//  gplvm.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/28/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

public class GPLVMLikelihood<K: Kernel>: GPLikelihood<K> where K.ScalarT == Float  {
    public var flagPredictXnew: Bool = false
    public var xNew: MatrixT = MatrixT()
    
    public override init(_ kernel: KernelT, _ noise: MatrixT, _ initX: MatrixT, _ Y: MatrixT) {
        super.init(kernel, noise, initX, Y)
    }
    
//    public override func compute(_ x: Matrix<Float>) -> Float {
//        return super.compute(x)
//    }
//    
//    public override func gradient(_ x: Matrix<Float>) -> Matrix<Float> {
//        var grad = super.gradient(x)
//        for param in kernel.trainables  {
//            if param != "X" {
//                grad[kernel.parametersIds]
//            }
//        }
//    }
}

//public class GPLVM<K: Kernel>: GaussianProcessRegressor<K> {
//    
//}
