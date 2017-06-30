//
//  gplvm.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/28/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

//MARK: This class is dedicated to inferring new latent X given new (possible with missing dimensions) Y, mostly borrowed from GPy (InferenceX)
public class GPLVMLikelihood<K: Kernel>: ObjectiveFunction where K.ScalarT == Float  {

    public typealias ScalarT = Float
    public typealias MatrixT = Matrix<ScalarT>
    public typealias KernelT = K

    public var dims: Int
    public var XNew: MatrixT
    public var YNew: MatrixT
    public var likelihood: GPLikelihood<K>
    public var Z: MatrixT
    public var missingData: Bool
    public var validDims: [IndexType] = []
    public var kernel: KernelT
    
    var dPsi0: MatrixT = MatrixT()
    var dPsi1: MatrixT = MatrixT()
    var dPsi2: MatrixT = MatrixT()
    
    public init(_ model: GaussianProcessRegressor<K>, _ Y: MatrixT) {
        self.dims = Y.columns
        XNew = zeros(1, dims)
        YNew = Y
        self.likelihood = model.likelihood
        kernel = model.kernel
        
        self.Z = model.Xtrain
        missingData = isnan(Y).any()
        validDims = nonzero(Y.grid.map{ !$0.isNaN })
        
        XNew = initX(model, Y)
        precompute()
    }
    
    func precompute() {
        // make sure finite precision
        // TODO: assuming scalar noise here. beta can be a NxN matrix, depending on the noise model
        let beta = 1.0 / likelihood.noise[0, 0]
        let D = ScalarT(YNew.columns)
        // update stored values in the likelihood
        likelihood.update()
        
        var wv = likelihood.woodburyVector
        if missingData {
            wv = wv[forall, validDims]
            dPsi0 = -0.5 * (beta * ones(1, YNew.rows))
            dPsi1 = beta * (YNew[forall, validDims] * wv.t)
            dPsi2 = 0.5 * beta * (D * likelihood.woodburyInv - wv * wv.t)
            
        } else {
            dPsi0 = -0.5 * D * (beta * ones(1, YNew.rows))
            dPsi1 = beta * (YNew * wv.t)
            dPsi2 = beta * (D * likelihood.woodburyInv - (wv * wv.t))
        }
    }
    
    public func initX(_ model: GaussianProcessRegressor<K>, _ Y: MatrixT) -> MatrixT {
        // init Xnew
        var YTrain = model.ytrain
        var dist = MatrixT()        
        if missingData {
            YTrain = YTrain[forall, validDims]
            let YNew_ = Y[forall, validDims]
            //WARNING: This is dangerous, consider the order of *
            dist = (-2.0 * YNew_) * YTrain.t + pow(YNew_, 2).sum(1)[0,0] + pow(YTrain, 2).sum(1)[0,0]
        } else {
            dist = (-2.0 * YNew) * YTrain.t + pow(YNew, 2).sum(1)[0,0] + pow(Y, 2).sum(1)[0,0]
        }
        
        let idx = argmin(dist, 1)[0, 0]
        return model.Xtrain[idx]
    }
    
    public func compute(_ x: Matrix<Float>) -> Float {
        XNew = x
        let psi1 = kernel.K(x, Z)
        let psi0 = diag(kernel.K(x, x))
        let psi2 = psi1.t * psi1
        let v2 = (dPsi2 ∘ psi2).sum()[0, 0]
        let v1 = (dPsi1 ∘ psi1).sum()[0, 0]
        let v0 = (dPsi0 ∘ psi0).sum()[0, 0]
        return v0 + v1 + v2
    }
    
    public func gradient(_ x: Matrix<Float>) -> Matrix<Float> {
        let psi1 = kernel.K(x, Z)
        let dPsi1 = self.dPsi1 + 2.0 * (psi1 * dPsi2)
        var XGrad = kernel.gradientX(x, Z, dPsi1)
        // TODO: ONLY WORKS FOR STATIONARY!
        // XGrad += kernel.gradientXDiag(x, dPsi0)
        return XGrad
    }
    
    public func hessian(_ x: Matrix<Float>) -> Matrix<Float> {
        return MatrixT()
    }
}

public class GPLVM<K: Kernel>: GaussianProcessRegressor<K> where K.ScalarT == Float {
    var predictXModel: GPLVMLikelihood<K>? = nil
    public override init(kernel: KernelT, alpha: ScalarT) {
        super.init(kernel: kernel, alpha: alpha)
        
    }
    
    /// predict latent point X from observation YStar
    public func predictX(_ YStar: MatrixT, _ verbose: Bool=false) -> MatrixT {
        predictXModel = GPLVMLikelihood(self, YStar)
        let opt = SCG(objective: predictXModel!, learningRate: 0.01, initX: predictXModel!.XNew, maxIters: 50)
        let (x, _, _) = opt.optimize(verbose: verbose)
        return x
    }
}


