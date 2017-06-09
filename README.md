# ![minimind](https://github.com/fqhuy/minimind/blob/master/doc/images/minimind6464.png) minimind: A Minimalist Machine Learning Library written in Swift

The only dependency now is [Surge](https://github.com/mattt/Surge) but it might be removed in the future. The main focus now is nonparametric models (Gaussian Processes) but more will be added soon. I aim to keep the interface as close to numpy/scikit-learn as possible. See playground files for examples.

## Sample code, predictive distribution
![Predictive](https://github.com/fqhuy/minimind/blob/master/doc/images/predictive.png)

```swift
        let Nf = 20
        let X = Matrix<Float>([[-1.50983293], [-1.11726642], [-0.89303372], [ 0.07971517], [ 0.29116607], [ 0.7494249 ], [ 0.93321463], [ 1.46661229]])
        
        let Y = Matrix<Float>([[ 0.04964821,  0.0866106,  0.16055375,  0.58936555,  0.71558366,  1.00004714,  1.08412273,  1.42418915]]).t
        
        let kern = RBF(variance: 1.0, lengthscale: 100.0)
        let gp = GaussianProcessRegressor<Float, RBF>(kernel: kern, alpha: 1.0)
        gp.fit(X, Y, maxiters: 200) // lengthscale = 3.68, fixed variance
        
        print(gp.kernel.get_params())
        
        let Xstar = Matrix<Float>(-1, 1, arange(-1.5, 1.5, 0.1))
        let (Mu, Sigma) = gp.predict(Xstar)
        let gauss = MultivariateNormal(Mu, Sigma)
        let S: Matrix<Float> = gauss.rvs(Nf)
        
        // Plotting, x and y are scaled for visibility
        let xx = Xstar.grid.cgFloat 
        for i in 0..<Nf {
            let yy = S[i].cgFloat
            _ = graph.plot(x: xx * 100.0 + 160.0, y: yy * 5.0, c: UIColor.blue)

        }
        _ = graph.scatter(x: (X.grid * 100.0 + Float(160.0)).cgFloat, y: (Y.grid * 5.0).cgFloat, c: UIColor.green, s: 3.0)
```
## Sample code, side-by-side with numpy
```swift
import Foundation
import Surge
import minimind

// random matrix
let m: Matrix<Float> = randMatrix(3, 3)
let a = Matrix<Float>([[1.2, 0.2, 0.3],
                       [0.5, 1.5, 0.2],
                       [0.1, 0.2, 2.0]])

let subM = m[0∷2, 0∷2] // matrix slicing
let cmean = m.mean(0) // mean across columns
let b = (m * a + a) ∘ m.t // linear math
let (u, s, v) = svd(a) // Singular values & vectors
let l = cholesky(a, "L") // Cholesky & LDLT
let (evals, evecs) = eigh(a, "L") // Eigen decom.
```
```python
import numpy as np

# random matrix
m = np.random.rand(3, 3)
a = np.array([[1.2, 0.2, 0.3],
              [0.5, 1.5, 0.2],
              [0.1, 0.2, 2.0]])
              
subM = m[0::2, 0::2]
cmean = m.mean(0)

b = (m.dot(a) + a) * m.T

u, s, v = np.linalg.svd(a)
l = np.linalg.cholesky(a)
evals, evecs = np.linalg.eigh(a)
```

## Sampling from a GP prior

![Sampling](https://github.com/fqhuy/minimind/blob/master/doc/images/sampling.png)