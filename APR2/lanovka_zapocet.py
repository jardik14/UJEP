from random import randint

def zamichej(seznam: list):
    novy = list()
    while seznam:
        index = randint(0, len(seznam)-1)
        novy.append(seznam.pop(index))
    return novy

def bubble_sort(seznam: list):
    not_sorted = True
    while not_sorted:
        not_sorted = False
        for i in range(len(seznam)-1):
            if seznam[i].vek > seznam[i+1].vek:
                seznam[i], seznam[i+1] = seznam[i+1], seznam[i]
                not_sorted = True




class Fronta:
    def __init__(self):
        self.values = list()

    def enqueue(self, value):
        self.values.append(value)

    def dequeue(self):
        return self.values.pop(0)

    def __bool__(self):
        return bool(self.values)

    def __repr__(self):
        return repr(self.values)

class Zasobnik:
    def __init__(self):
        self.values = list()

    def add(self, value):
        self.values.append(value)

    def pop(self):
        return self.values.pop()

    def remove_all(self):
        self.values.clear()

    def __len__(self):
        return len(self.values)

    def __repr__(self):
        return repr(self.values)

class Lanovka:
    def __init__(self, kapacita, pocet_jizd, pocet_bezporuchovych_jizd):
        self.kapacita = kapacita
        self.pocet_jizd = pocet_jizd
        self.pocet_bezporuchovych_jizd = pocet_bezporuchovych_jizd
        self.pasazeri = Zasobnik()

    def nastup1(self, prodejce):
        while len(self.pasazeri) < self.kapacita and prodejce.fronta:
            pasazer = prodejce.prodej()
            if pasazer:
                print(f"Nastoupil {pasazer.jmeno}")
                self.pasazeri.add(pasazer)
        if randint(0,10) == 10:
            if self.pasazeri:
                self.pasazeri.pop()
            self.pasazeri.add(Pasazer("Ivan", 0, 21))


    def nastup2(self, seznam):
        for pasazer in seznam:
            self.pasazeri.add(pasazer)

    def jizda(self):
        self.pocet_jizd += 1
        if self.pocet_jizd > self.pocet_bezporuchovych_jizd:
            print(f"Lanovka se porouchala a při explozi všichni cestující zemřeli.")
            self.pasazeri.remove_all()
            self.pocet_jizd = 0

    def vystup1(self):
        vystoupili = list()
        while self.pasazeri:
            vystoupili.append(self.pasazeri.pop())
        return zamichej(vystoupili)

    def vystup2(self):
        while self.pasazeri:
            self.pasazeri.pop()

    def kontrola(self, podezreli, policie):
        bubble_sort(podezreli)
        for clovek in podezreli:
            if clovek.vek == policie.vek_hledane_osoby and clovek.jmeno == policie.jmeno_hledane_osoby:
                print("Uprchlý vězeň nalezen!")
                policie.nalezen = True
        return podezreli






class Prodejce:
    def __init__(self, nalada, cena_za_jizdu):
        self.nalada = nalada
        self.cena_za_jizdu = cena_za_jizdu
        self.fronta = Fronta()

    def prodej(self):
        zakaznik = self.fronta.dequeue()
        if zakaznik.finance >= self.cena_za_jizdu:
            return zakaznik
        elif self.nalada > 6 and randint(0, 10) > 8:
            return zakaznik
        else:
            return None

    def zarad_do_fronty(self, zakaznik):
        self.fronta.enqueue(zakaznik)

class Pasazer:
    def __init__(self, jmeno, finance, vek):
        self.jmeno = jmeno
        self.finance = finance
        self.vek = vek

    def __repr__(self):
        return f"{self.jmeno}, {self.vek}"

class Policie:
    def __init__(self, jmeno_hledane_osoby, vek_hledane_osoby):
        self.jmeno_hledane_osoby = jmeno_hledane_osoby
        self.vek_hledane_osoby = vek_hledane_osoby
        self.nalezen = False

def main():
    lanovka = Lanovka(2, 0, 10)
    prodejce = Prodejce(5, 10)
    prodejce.zarad_do_fronty(Pasazer("Jirka", 55, 21))
    prodejce.zarad_do_fronty(Pasazer("Martin", 20, 56))
    prodejce.zarad_do_fronty(Pasazer("Jana", 5, 10))
    prodejce.zarad_do_fronty(Pasazer("Adam", 100, 30))
    prodejce.zarad_do_fronty(Pasazer("Tomáš", 7, 22))
    prodejce.zarad_do_fronty(Pasazer("Iveta", 55, 21))
    prodejce.zarad_do_fronty(Pasazer("Jan", 55, 21))
    #prodejce.zarad_do_fronty(Pasazer("Ivan", 55, 21))
    policie = Policie("Ivan", 21)
    while not policie.nalezen:
        lanovka.nastup1(prodejce)
        lanovka.jizda()
        lanovka.nastup2(lanovka.kontrola(lanovka.vystup1(), policie))
        lanovka.jizda()
        lanovka.vystup2()

main()