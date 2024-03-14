
def get_as_int(s:list, i: int, default=None) -> int:
    return int(s[i]) if i < len(s) else default

class Datum:
    def __init__(self, rok:int, mesic:int=None, tyden:int=None, den:int=None):
        self.rok = rok
        self.mesic = mesic
        self.tyden = tyden
        self.den = den

    @staticmethod
    def from_repr(rstr:str) -> 'Datum':
        items = rstr.split('.')
        rok, mesic, tyden, den = [get_as_int(items, i) for i in range(4)]
        return Datum(rok, mesic, tyden, den)

    def __repr__(self):
        if self.mesic is None:
            return f"{self.rok}"
        elif self.tyden is None:
            return f"{self.rok}.{self.mesic}"
        elif self.den is None:
            return f"{self.rok}.{self.mesic}.{self.tyden}"
        else:
            return f"{self.rok}.{self.mesic}.{self.tyden}.{self.den}"

    def __str__(self):
        d = [str(x) for x in [self.rok, self.mesic, self.tyden, self.den] if x is not None]
        return '.'.join(d)

    @staticmethod
    def je_prunik(interval1:tuple['Datum','Datum'], interval2:tuple['Datum','Datum']) -> bool:
        a1 = interval1[0].ordinal()
        a2 = interval1[1].ordinal()
        b1 = interval2[0].ordinal()
        b2 = interval2[1].ordinal()
        return a1 <= b2 and b1 <= a2

    def ordinal(self) -> int:
        return self.rok * (12*35) + self.mesic * 35 + self.tyden * 7 + self.den





class Udalost:
    def __init__(self, datum_od:Datum, datum_do:Datum, popis:str, *, lokace:str=None):
        pass

    @staticmethod
    def from_dict(json_dict:dict) -> 'Udalost':
        pass

    def to_dict(self) -> dict:
        pass

class Postava:
    def __init__(self, jmeno:str, narozeni:Datum, *, prezdivka:str=None, umrti:Datum=None):
        pass

    @staticmethod
    def from_dict(json_dict:dict) -> 'Postava':
        pass

    def to_dict(self) -> dict:
        pass

    def pridej_udalost(self, udalost:Udalost):
        pass

    def __repr__(self):
        pass

    def vrat_udalosti(self, datum_od:Datum, datum_do:Datum) -> list[Udalost]:
        pass

if __name__ == "__main__":
    d = Datum(2020, 5)
    print(repr(d))
    print(str(d))

    d2 = Datum.from_repr(repr(d))
    print(d2)