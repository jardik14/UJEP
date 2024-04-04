class SerazenaMnozina:
    def __init__(self):
        self._values = list()

    @property
    def values(self):
        return self._values

    def add(self, value):
        if value not in self._values:
            self._values.append(value)
        self._values = SerazenaMnozina.quicksort(self._values)

    def quicksort(list_to_sort: list):
        if len(list_to_sort) <=1:
            return list_to_sort
        pivot = list_to_sort[0]
        smaller = [x for x in list_to_sort[1:] if x <= pivot]
        bigger = [x for x in list_to_sort[1:] if x > pivot]
        return SerazenaMnozina.quicksort(bigger) + [pivot] + SerazenaMnozina.quicksort(smaller)

a = SerazenaMnozina()

a.add(2)
print(a.values)

a.add(1)
print(a.values)

a.add(3)
print(a.values)