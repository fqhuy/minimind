import sys
sys.path.append('/Users/phanquochuy/Projects/minimind/prototypes/george/build/lib.macosx-10.10-x86_64-2.7')
import numpy as np
import george
from george.kernels import ExpSquaredKernel

# Generate some fake noisy data.
x = 10 * np.sort(np.random.rand(10))
yerr = 0.2 * np.ones_like(x)
y = np.sin(x) + yerr * np.random.randn(len(x))

# Set up the Gaussian process.
kernel = ExpSquaredKernel(1.0)
gp = george.GP(kernel)

# Pre-compute the factorization of the matrix.
gp.compute(x, yerr)
gp.optimize(x, y, verbose=True)

# Compute the log likelihood.
print(gp.lnlikelihood(y))

t = np.linspace(0, 10, 500)
mu, cov = gp.predict(y, t)
std = np.sqrt(np.diag(cov))