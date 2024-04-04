class Mnozina:
    def __init__(self):
        self._values = list()

    def add(self, value):
        if value not in self._values:
            self._values.append(value)

    def union(self, other: 'Mnozina') -> 'Mnozina':
        res = Mnozina()
        for value in self._values:
            res.add(value)
        for value in other._values:
            if value not in res._values:
                res.add(value)
        return res

    def intersection(self, other: 'Mnozina') -> 'Mnozina':
        res = Mnozina()
        for value in self._values:
            if value in other._values:
                res.add(value)
        return res

    def __str__(self):
        return repr(self._values)

a = Mnozina()
b = Mnozina()

a.add(1)
a.add(2)
b.add(2)
b.add(3)

print("skrrt")
print(a.union(b))
print(a.intersection(b))
