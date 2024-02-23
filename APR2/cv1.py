from random import choice

class Pes:
    def __init__(self, jmeno, vek, majitele):
        self._jmeno = jmeno
        self._vek = vek
        self._majitele = majitele

    @property
    def jmeno(self):
        return self._jmeno

    @jmeno.setter
    def jmeno(self, value):
        self._jmeno = value if len(value) > 3 else self._jmeno

    @property
    def vek(self):
        return self._vek

    @vek.setter
    def vek(self, value):
        self._vek = value if value > 0 else self._vek

    @property
    def majitele(self):
        return self._majitele

    @majitele.setter
    def majitele(self, value):
        self._majitele = value if len(value) > 0 else self._majitele

    def stekej(self):
        print(f"{self._jmeno}: Haf")

    def curej(self, na_koho):
        print(f"{self._jmeno} čůrá na {na_koho}.")

    #pretezovani operatoru
    def __ge__(self, other):
        return self._vek >= other._vek

    def __add__(self, other):
        if isinstance(other, Pes):
            jmeno_stenete = self._jmeno + "-" + other._jmeno
            vek_stenete = 0
            majitele_stenete = choice([self._majitele, other._majitele])
            return Pes(jmeno_stenete, vek_stenete, majitele_stenete)
        else:
            raise ValueError("Nelze scitat pes s necim jinym.")

p1 = Pes(jmeno="Azor", vek=3, majitele=["Karel", "Jana"])
print(p1._jmeno)
p1.jmeno = "Alex"
print(p1._jmeno)
p1.stekej()
p1.curej("Karel")
p2 = Pes(jmeno="Baryk", vek=2, majitele=["Jana"])
print(p1 >= p2)
stene = p1 + p2
print(stene.jmeno)