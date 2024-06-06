from itertools import repeat, accumulate, count, islice, permutations, combinations, combinations_with_replacement

class CRepeat:
    def __init__(self, item):
        self.item = item

    def __iter__(self):
        return self

    def __next__(self):
        return self.item


def grepeat(item):
    while True:
        yield item

# for i in repeat(1):
#     print(i)

# for i in CRepeat(1):
#     print(i)

# for i in grepeat(1):
#     print(i)

# for fact in islice(accumulate(count(1), lambda x, y: x * y),10):
#     print(fact)

# seznam[10:20_000] # pamětově náročné
# seznam.islice(10, 20_000) # použitelné bez kopie
# seznam.islice(1_000_000, 1_000_010)

# print([(a, b) for a in range(5) for b in "abc"])

print(["".join(output) for output in permutations("abcd", 3)])

print(["".join(output) for output in combinations("abcd", 3)])

print(["".join(output) for output in combinations_with_replacement("abcd", 3)])
