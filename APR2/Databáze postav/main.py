from typing import Iterable

def nones_at_end(lst:Iterable):
    """
    Kontroluje, zda jsou všechny hodnoty None soustředěny v souvislém bloku
    na úplném konci iterovatelného objektu.

    :param lst: iterovatelný objekt k testování.
    :return: True, pokud jsou všechny None na konci, jinak False.
    """
    # Stavová proměnná označující, zda jsme už narazili na None
    found_none = False
    for item in lst:
        if item is None:
            found_none = True
        elif found_none:
            # Narazili jsme na hodnotu, která není None po prvním None
            return False
    return True


def get_as_int(s:list, i: int, default=None):
    return int(s[i]) if i < len(s) else default


class VDate:
    """
    Representace data ve venetském kalendáři (viz https://www.jf.cz/…89).
    """
    def __init__(self, year:int, month:int=None, week:int=None, day:int=None):
        self.year = year
        self.month = month
        self.week = week
        self.day = day
        assert year is not None and nones_at_end(self.long_date)
        assert self.day is None or 1 <= self.day <= 7
        assert self.week is None or 1 <= self.week <= (5 if self.month % 3 == 1 else 4)
        assert self.month is None or 1 <= self.month <= 12

    @property
    def long_date(self):
        return self.year, self.month, self.week, self.day
    @staticmethod
    def from_repr(rstr: str) -> 'VDate':
        items = rstr.split(".")
        return VDate(*[get_as_int(items, i) for i in range(4)])

    def __str__(self):
        months = ["traven", "travenec", "lipenec",
                  "červen", "červenec", "srpenec",
                  "říjen", "říjenec", "studenec",
                  "sečen", "sečenec", "březenec"]
        weeks = ["černé", "bílý", "rudý", "zelený", "modrý"]
        days = ["pondělí", "úterý", "středa", "čtvrtek", "pátek", "sobota", "neděle"]
        if self.month is None:
            return f"{self.year}"
        elif self.week is None:
            return f"{self.year}.{months[self.month-1]}"
        elif self.day is None:
            return f"{self.year}.{months[self.month-1]}.{weeks[self.week-1]}"
        else:
            return f"{self.year}.{months[self.month-1]}.{weeks[self.week-1]}.{days[self.day-1]}"

    def __repr__(self):
        d = [str(n) for n in self.long_date if n is not None]
        return ".".join(d)

    @staticmethod
    def is_intersection(interval1: tuple['VDate', 'VDate'], interval2: tuple['VDate', 'VDate']) -> bool:
        #FIXME: zatím funguje jen pro přesná data
        a1 = interval1[0].ordinalNumber();
        a2 = interval1[1].ordinalNumber()
        b1 = interval2[0].ordinalNumber()
        b2 = interval2[1].ordinalNumber()

        return a2 >= b1 and b2 >= a1

    def ordinalNumber(self) -> int:
        return self.year * (12*35) + self.month * 35 + self.week * 7 + self.day

    def precise_from_date(self) -> 'VDate':
        return VDate(self.year, self.month or 1, self.week or 1, self.day or 1)

    def precise_to_date(self) -> 'VDate':
        return VDate(self.year, self.month or 12, self.week or (5 if self.month % 3 == 1 else 4), self.day or 7)

    def is_precise(self) -> bool:
        return self.day is not None

    def __le__(self, other):
        return self.precise_from_date().ordinalNumber() <= other.precise_to_date().ordinalNumber()

class VDate_Interval:
    def __init__(self, date_from: VDate, date_to: VDate):
        assert date_from <= date_to
        self.date_from = date_from
        self.date_to = date_to


class Circumstance:
    def __init__(self, date_from: VDate, date_to: VDate, description: str, *, location:str = None):
        pass
    @staticmethod
    def from_dict(json_dict: dict) -> 'Circumstance':
        pass

    def to_dict(self) -> dict:
        pass


class Character:
    def __init__(self, name:str, birthdate:VDate, *, nickname:str=None, deathdate:VDate=None):
        pass

    @staticmethod
    def from_dict(json_dict: dict) -> 'Character':
        pass

    def to_dict(self) -> dict:
        pass

    def add_circumstance(self, udalost: Circumstance):
        pass

    def __repr__(self):
        pass

    def get_concurrent_circumstances(self, datum_od: VDate, datum_do: VDate) -> list[Circumstance]:
        pass


if __name__ == "__main__":
    d = VDate(1572, 10, 5, 1)
    s = repr(d)
    d2 = VDate.from_repr(s)
    print(repr(d2))
    print(d2)