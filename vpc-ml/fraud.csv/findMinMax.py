import pandas as pd
import numpy as np

data = pd.read_csv('creditcard.csv')
desc = data.describe()

#print desc

#print

print desc.loc[['min','max', 'mean', 'std']].to_json()
