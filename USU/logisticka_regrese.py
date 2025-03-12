from sklearn.datasets import make_blobs
import matplotlib.pyplot as plt
import numpy.linalg as la # pro vypocet normy
import numpy as np
import scipy.optimize as optimize # pro vypocet minima kriterialni funkce
from sklearn import linear_model # pro linearni regresi

# generování blobů
X, y = make_blobs(n_samples=100, centers=[(2.5,2.5),(-2.5,-2.5)], n_features=2, random_state=0)

# plt.scatter(X[:,0],X[:,1], c = y)
# plt.grid()
# plt.title("Body různých tříd v prostoru příznaků")
# plt.show()

class naivni_logisticka_regrese_binarni:
  def __init__(self):
    self._w = None
    self._X = None
    self._y = None

  def sigmoida(self, w, X):
    """
    Pomocna metoda pro vypocet sigmoidy
    """
    return 1.0/(1.0+np.exp(-X @ w))

  def kriterialni_funkce(self, w):
      """
      Minimalizovaná funkce – Binary Cross-Entropy.
      """
      y_pred = self.sigmoida(w, self._X)
      epsilon = 1e-15
      return -(self._y.T @ np.log(y_pred + epsilon) + (1 - self._y).T @ np.log(1 - y_pred + epsilon))

  def fit(self, X,y):
    """
    Nauceni modelu. Pro uceni je vyuzita knihovna scipy a nastroje pro
    optimalizaci v ni obsazene.
    """
    dimenze = X.shape[1]+1
    radky = X.shape[0]
    # priprav si data - pridani sloupce se jednickami, pro bias
    self._X = np.hstack((np.ones((radky,1)), X)) # pridej jednicky
    self._y = y
    # je pouzita iteracni metoda optimalizace, nahodne je zvolena nulta iterace
    w0 = np.random.randn(dimenze) # nahodny bod
    self._w=w0
    # print(f"Pocatecni hodnota krit. fce {self.kriterialni_funkce(w0)}")
    # print(f"Pocatecni hodnota vah w={w0}")
    res = optimize.minimize(self.kriterialni_funkce, w0, method='BFGS', tol=1e-5)
    self._w = res.x
    # print(f"Konecna hodnota krit. fce {self.kriterialni_funkce(self._w)}")
    # print(f"Konecna hodnota vah w={self._w}")
    return self._w

  def predict_proba(self, X):
    """
    Vypocet pravdepodobnosti prislusnosti ke tride
    """
    return self.sigmoida(self._w, np.hstack((np.ones((X.shape[0],1)), X)))

  def predict(self, X, hranice=0.5):
    """
    Predikce konkretni tridy na zaklade pravdepodobnosti.
    """
    pravdepodobnost = self.predict_proba( X)
    return  1* (pravdepodobnost > hranice)


model_lr = linear_model.LinearRegression()
model_lr.fit(X,y)# automaticky je pridan konstantni clen - nemusím modifikovat matici X na X'
w = model_lr.coef_ #koeficienty modelu - bez konstantniho clenu
b = model_lr.intercept_ # konstantni clen

# urceni hranic pro vykresleni ve 3D
min1,max1 = X[:,0].min(),X[:,0].max()
min2,max2 = X[:,1].min(),X[:,1].max()
xx,yy = np.meshgrid(np.arange(min1-1, max1+1), np.arange(min2-1, max2+1))

y_hat = xx*w[0]+yy*w[1]+b # vypocet delici roviny

w_1 = -0.1 #@param {type:"slider", min:-1, max:1, step:0.1}
w_2 = -0.3 #@param {type:"slider", min:-1, max:1, step:0.1}
bias = 0.4 #@param {type:"slider", min:-1, max:1, step:0.1}

x_1= np.arange(min1-1, max1+1) # osa x pro primky
x_2 = -w[0]/w[1]*x_1+(b-1/2)/w[1] # pevne spoctena primka na zaklade reseni MNC
x_2_mov = -w_1/w_2*x_1+(bias-1/2)/w_2  #primka dana slidery

zz = 1/(1+np.exp(-w[0]*xx-w[1]*yy))


#pouziti navrzene tridy
model = naivni_logisticka_regrese_binarni()
model.fit(X,y) # nauceni modelu

# Pouziti pro predikci
bod = np.array([4,2])
y_1_hat = model.predict(bod.reshape(1,2))
# print(f"Predikovana trida pro {bod} je {y_1_hat}")
y_hat = model.predict(X)
# print("Porovnani s realitou:")
# for trida_predpoved, realita in zip(y_hat, y):
#   print(f"{trida_predpoved}-->{realita}|", end="")

# Vykresleni hladin pravděpodobnosti
zzp = zz
for i in range(xx.shape[1]):
  for j in range(xx.shape[0]):
    zzp[j,i] = model.predict_proba(np.array([xx[j,i],yy[j,i]]).reshape(1,2))


# fig, ax =plt.subplots()
# cf=plt.contourf(xx, yy, zzp,levels=10, cmap='RdGy')
# plt.scatter(X[:,0],X[:,1], c = y) # kresli body z X
# plt.scatter(bod[0], bod[1],color='green') # kresli jeden zadany bod
# fig.colorbar(cf, ax=ax)
# ax.grid()
# plt.title("Hladiny pravděpodobnosti příslušnosti ke třídám")
# ax.legend()
# plt.show()