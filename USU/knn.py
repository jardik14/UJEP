import numpy as np

def knn_klasifikuj(X,y,x, k=3):
  """
  :param X: vstupni matice prvku, kazdy radek je jeden zaznam - trenovaci data
  :param y: labely trenovacich dat
  :param x: prvek ktery chceme klasifikovat
  :param k: počet sousedů
  :return: cislo tridy
  """
  def vzdalenost(x,y):
    return np.sum((x-y)**2)

   # urceni tabulky vzdalenosti - ulozime vzdalenost od x a label pro kazdy prvek z X
  tabulka = np.array([(vzdalenost(x,radek), label) for radek, label in zip(X[:],y)])
  # nalezeni k-nejblizsich prvku. Podobny algoritmus jako pro selection sort.
  for krok in range(k):
    index = np.argmin(tabulka[krok:,0], axis=0)+krok
    tabulka[[krok, index]]  =  tabulka[[index, krok]]
  # urceni cetnosti labelu pro k nejblizsich sousedu - prvnich k v tabulce
  cetnosti = {}
  for label in tabulka[:k,1]:  # jed jen pres sloupecek labelu
    if label in cetnosti:
      cetnosti[label] += 1
    else:
      cetnosti[label] = 1
  # vrat klic prislusejici nejcetnejsi hodnote
  return int(sorted(cetnosti.items(), key = lambda kv: kv[1])[-1][0])