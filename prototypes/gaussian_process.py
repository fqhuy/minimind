import numpy as np
from scipy.optimize import minimize
from scipy.spatial.distance import euclidean


def kernel_rbf(x1, x2, params):
    return params[0] * np.exp(-0.5 / params[1] * euclidean(x1, x2))
    
    
def kernel_rbf_d(x1, x2, params):
    jacobian_mat = np.zeros(len(params), float)
    d = euclidean(x1, x2)
    
    jacobian_mat[0] = np.exp(-0.5 * params[1] * d)
    if d < 1e-5:
        jacobian_mat[1] = 1e-5
    else:
        jacobian_mat[1] = params[0] * np.exp(-0.5 / (params[1]) * d) * (-0.5 * d)

    return jacobian_mat


def covariance_matrix(X, kernel, params, beta):
    N, D = X.shape
    # Computing the covariance matrix
    C = np.zeros((N, N), dtype=float)
    for row in range(N):
        for col in range(N):
            if col == row:
                C[row, col] = kernel(X[row], X[col], params) + 1. / beta
            else:
                C[row, col] = kernel(X[row], X[col], params)
    return C
    
    
def objective_func(params, X, y, kernel, kernel_d, beta):
    if len(params) < 2:
        pass
    N, D = X.shape
    log_beta = np.log(beta)
    C = covariance_matrix(X, kernel, params, beta)
    llh =  -0.5 * np.log(np.linalg.det(C)) - 0.5 * \
    np.dot( np.dot( y.T, np.linalg.inv(C)), y) - N / 2. * np.log(2 * np.pi) + \
    0.5 * (log_beta * log_beta)
    
    print( 'objective: ', llh )
    return -llh
    
    
def objective_func_derivatives(params, X, y, kernel, kernel_d, beta):
    N, D = X.shape
    n_params = len(params)
    d_llh = np.zeros(n_params)
    dC = np.zeros((N, N, n_params))
    C = covariance_matrix(X, kernel, params, beta)
    iC = np.linalg.inv(C)
    
    for row in range(N):
        for col in range(N):
            dC[row, col] = kernel_d(X[row], X[col], params)
    
    for i in range(n_params):
        d_llh[i] = -0.5 * np.trace(np.dot(iC, dC[:, :, i])) + 0.5 * \
        np.dot(np.dot(np.dot(np.dot( y.T, iC ), dC[:, :, i]), iC), y)
        
    return -d_llh
    

class GaussianProcess(object):
    def __init__(self, kernel, beta, normalize=True):
        self._C = None
        self._X = None
        self._y = None
        self._normalize = normalize
        
        if kernel == 'rbf':
            self._kernel = kernel_rbf
            self._kernel_d = kernel_rbf_d
            self._n_params = 2
            
        self._beta = beta
        self._params = None
        
    def fit(self, X, y, init_params=None):
        if init_params is None:        
            init_params = np.zeros(self._n_params) + 0.5

        if self._normalize:
            X_mean = np.mean(X, axis=0)
            X_std = np.std(X, axis=0)
            y_mean = np.mean(y, axis=0)
            y_std = np.std(y, axis=0)
            X_std[X_std == 0.] = 1.
            y_std[y_std == 0.] = 1.
            # center and scale X if necessary
            X = (X - X_mean) / X_std
            y = (y - y_mean) / y_std
                    
        # y = y[:, 0]
        
        # estimating the parameters
        result = minimize(objective_func, init_params, \
            args=(X, y, self._kernel, self._kernel_d, self._beta), \
            method='BFGS', jac=objective_func_derivatives, \
            options={'disp': True, 'gtol': 1})
        
        self._params = result.x
        
        # Calculating covariance matrix with the learned parameters
        C = covariance_matrix(X, self._kernel, self._params, self._beta)
        self._C = C
        self._X = X
        self._y = y
    
    def predict(self, X):
        N, D = X.shape
        ks = np.zeros((N, self._X.shape[0]))
        
        for row in range(N):
            for col in range(self._X.shape[0]):
                ks[row, col] = self._kernel(X[row], self._X[col], self._params)
            
        t_means = np.zeros(N)
        t_covs = np.zeros(N)
        iC = np.linalg.inv(self._C)
        for i in range(N):
            t_means[i] = np.dot( np.dot( ks[i].T, iC), self._y)
            t_covs[i] = self._kernel(X[i], X[i], self._params) + self._beta - \
                np.dot( np.dot( ks[i].T, iC), ks[i])
        
        return t_means, t_covs
        
    def score(self, X, y):
        t_means, t_covs = self.predict(X)
        return np.abs(t_means - y).sum()


if __name__ == '__main__':
    import sklearn
    from sklearn import datasets
    from sklearn.cross_validation import train_test_split
    from sklearn.preprocessing import MinMaxScaler
    
    data = datasets.load_boston()
    
    X = data['data']
    # mms = MinMaxScaler()
    # X = mms.fit_transform(X)
    y = data['target'][:, np.newaxis]
    # y = y / y.max()
    
    Xtrain, Xtest, ytrain, ytest = \
        train_test_split(X, y, test_size=0.4, random_state=None)
    
    gp = GaussianProcess(kernel='rbf', beta=1.0, normalize=False)
    gp.fit(Xtrain, ytrain, init_params=np.array([1, 15]))
    # print(gp.score(Xtest, ytest))