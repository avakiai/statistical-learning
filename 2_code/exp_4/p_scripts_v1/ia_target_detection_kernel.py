#%matplotlib inline

import pandas as pd
from numpy import array, linspace
from sklearn.neighbors.kde import KernelDensity
from matplotlib.pyplot import plot
exp_3_rt = pd.read_csv("exp3array.csv")['rt']
rt_array = array(exp_3_rt).reshape(-1,1)
kde = KernelDensity(kernel='gaussian', bandwidth=3).fit(rt_array)
s = linspace(0,round(max(exp_3_rt))+1)
e = kde.score_samples(s.reshape(-1,1))
plot(s,e)