import numpy as np
import scipy as sp 
from scipy.stats import multivariate_normal
from matplotlib import pyplot as plt

def k(x, a = -0.75):
    if abs(x) <= 1:
        return (a + 2.) * abs(x)**3 - (a + 3.) * abs(x) ** 2. + 1
    elif 1 < abs(x) <= 2:
        return a * abs(x) ** 3. - 5. * a * abs(x) **2. + 8. * a * abs(x) - 4. * a 
    else:
        return 0.0
        
# x, y = np.mgrid[-1:1:.01, -1:1:.01]
# pos = np.empty(x.shape + (2,))
# pos[:, :, 0] = x; pos[:, :, 1] = y

# rv = multivariate_normal([0.0, 0.0], [[2.0, 0.3], [0.3, 2.0]])
# plt.contourf(x, y, rv.pdf(pos))

A = np.random.rand(5, 5)
B = A.copy()

# A = np.kron(A, np.ones((2, 2), dtype=float))
alpha = 5
C = np.zeros((A.shape[0] * alpha, A.shape[1] * alpha), dtype=float)
for i in range(A.shape[0]): 
    for j in range(A.shape[1]):
        C[i * alpha, j * alpha] = A[i, j]

# K = np.array([k(xx) for xx in [-2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2]])
K = np.array([k(xx) for xx in np.linspace(-2, 2, 11)])
for r in range(C.shape[0]):
    C[r, :] = np.convolve(C[r], K, 'same')

for c in range(A.shape[1]):
    C[:, c] = np.convolve(C[:, c].flatten(), K, 'same')

plt.subplot(121)
plt.imshow(C, interpolation='bicubic')

plt.subplot(122)
plt.imshow(C, interpolation='nearest')
plt.show()