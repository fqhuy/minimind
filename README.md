# minimind: A Minimalist Machine Learning Library written in Swift

The only dependency now is [Surge](https://github.com/mattt/Surge) but it might be removed in the future. The main focus now is nonparametric models (Gaussian Processes) but more will be added soon. I aim to keep the interface as close to numpy/scikit-learn as possible. See playground files for examples.

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

let subM = m[0..2, 0..2] // matrix slicing
let cmean = m.mean(0) // mean across columns
let b = (m * a + a) • m.t // linear math
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

## Sampling from an RBF kernel

![Sampling](https://github.com/fqhuy/minimind/blob/master/doc/images/sampling.png)