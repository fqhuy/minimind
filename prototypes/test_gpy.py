"""Run a standard Gaussian process regression on the Rogers and Girolami olympics data."""
import GPy
data = GPy.util.datasets.olympic_100m_men()
optimize = True
plot = True

# create simple GP Model
m = GPy.models.GPRegression(data['X'], data['Y'])

# set the lengthscale to be something sensible (defaults to 1)
m['rbf.lengthscale'] = 10
if optimize:
    m.optimize('bfgs', max_iters=200)

if plot:
    m.plot(plot_limits=(1850, 2050))
