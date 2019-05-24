import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
from sklearn import preprocessing
from sklearn.preprocessing import StandardScaler
from mpl_toolkits.mplot3d import Axes3D

dataset = pd.read_csv('dataset_eeg.csv')
df = dataset[['signal_mean','signal_std','hurst','entropy']]

sc = StandardScaler()
ds = sc.fit_transform(df)

#KMeans clustering

sum_of_squared_distances = []
K = range(1,5)
for k in K:
    kmeans = KMeans(n_clusters=k)
    kmeans = kmeans.fit(ds)
    sum_of_squared_distances.append(kmeans.inertia_)

fig = plt.figure(figsize=(10,10))
plt.plot(K, sum_of_squared_distances, 'rx-')
plt.xlabel('Number of Clusters')
plt.ylabel('Sum of Squared Distances')
plt.title('Optimal Number of Clusters')
plt.show()


kmeans = KMeans(n_clusters=4)
kmeans.fit(ds)
predictedKMeans = kmeans.predict(ds)


dataset['results'] = predictedKMeans

#%% SPLIT DATASET IN FILES
first = dataset.loc[:13199,:]
second = dataset.loc[13200:26399,:]
third = dataset.loc[26400:]
#%% 3D PLOT
fig = plt.figure(figsize = (10,10))
ax = fig.add_subplot(111, projection = '3d')
ax.view_init(30, 30)
ax.scatter(dataset['signal_mean'], dataset['signal_std'], dataset['hurst'], c = dataset['results'],cmap='brg')
ax.set_xlabel('Signal Mean')
ax.set_ylabel('Signal Standard Deviation')
ax.set_zlabel('Signal Sample Entropy')

#%%PIE CHARTS
groups_first = first.groupby('results').count()['entropy']
labels = ['State 1','State 2','State 3','State 4']
fig = plt.figure()
plt.pie(groups_first, labels=labels, autopct='%1.1f%%',\
         wedgeprops={'edgecolor':'k', 'linewidth': 1, 'linestyle': 'solid', 'antialiased': True})

groups_second = second.groupby('results').count()['entropy']
fig = plt.figure()
plt.pie(groups_second, labels=labels, autopct='%1.1f%%',\
         wedgeprops={'edgecolor':'k', 'linewidth': 1, 'linestyle': 'solid', 'antialiased': True})

groups_third = third.groupby('results').count()['entropy']
fig = plt.figure()
plt.pie(groups_third, labels=labels, autopct='%1.1f%%',\
         wedgeprops={'edgecolor':'k', 'linewidth': 1, 'linestyle': 'solid', 'antialiased': True})
