from sklearn.datasets import make_blobs
import matplotlib.pyplot as plt
import numpy as np

# generování blobů
n_clusters = 4
X, y = make_blobs(n_samples=100, centers=n_clusters, n_features=2, random_state=0)

# vykreslení
plt.scatter(X[:, 0], X[:, 1], c=y)
plt.grid()
plt.title("Generated blobs")
plt.show()

# shlukování pomoci k-means (vlatsni implementace)
n_centroids = n_clusters # pocet skupin

# inicializace centroidů
np.random.seed(0)
centroids = X[np.random.choice(range(X.shape[0]), n_centroids, replace=False)]

# vykreslení s inicializovanými centroidy
plt.scatter(X[:, 0], X[:, 1], c='gray')
plt.scatter(centroids[:, 0], centroids[:, 1], c='red', s=100)
plt.grid()
plt.title("Initial centroids")
plt.show()

# přiřazení bodů k centroidům
distances = np.linalg.norm(X[:, np.newaxis] - centroids, axis=2)  # vzdálenost bodů od centroidů
clusters = np.argmin(distances, axis=1) # přiřazení bodů k centroidům (nejbližší centroid)

# spočítání nových centroidů
for i in range(n_centroids):
    centroids[i] = np.mean(X[clusters == i], axis=0)

# opakování (zastavit po určitém počtu iterací)
for _ in range(50):
    distances = np.linalg.norm(X[:, np.newaxis] - centroids, axis=2)
    clusters = np.argmin(distances, axis=1)
    for i in range(n_centroids):
        centroids[i] = np.mean(X[clusters == i], axis=0)

# vykreslení
plt.scatter(X[:, 0], X[:, 1], c=clusters)
plt.scatter(centroids[:, 0], centroids[:, 1], c='red', s=100)
plt.grid()
plt.title("Final centroids with clusters")
plt.show()






