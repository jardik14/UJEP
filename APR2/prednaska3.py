from typing import Any
from time import sleep
from collections import deque
from random import randrange
from deprecated import deprecated
# Fronta a zasobnik

# Zasobnik - LIFO


class Stack:
    def __init__(self):
        self.data = []

    def push(self, item: Any) -> None:
        self.data.append(item)

    def pop(self) -> Any:
        if not self:
            raise ValueError("Stack is empty")
        return self.data.pop()

    def is_empty(self) -> bool:
        return not bool(self.data)

    def __bool__(self):
        return bool(self.data)

    def __repr__(self):
        return repr(self.data)

    def __len__(self):
        return len(self.data)

    def peek(self) -> Any:
        if not self:
            raise ValueError("Stack is empty")
        return self.data[-1]




# Fronta - FIFO

class Queue:
    def __init__(self):
        self.data = deque()

    def enqueue(self, item: Any) -> None:
        self.data.append(item)

    def dequeue(self) -> Any:
        if not self:
            raise ValueError("Queue is empty")
        return self.data.popleft()

    def is_empty(self) -> bool:
        return not bool(self.data)

    def __bool__(self):
        return bool(self.data)

    def __repr__(self):
        return repr(self.data)

    def __len__(self):
        return len(self.data)

    def peek(self) -> Any:
        if not self:
            raise ValueError("Queue is empty")
        return self.data[0]


class ScleroticSet:
    """
      Sklerotické množiny mají sémantiku množin ale jen omezenou kapacitu.
      Pokud je kapacita překročena, náhodně zapomínají uložené údaje.

      Záruky:
      - poslední vložený prvek není nikdy zapomenut
      - dříve vložené prvky mají větší praovděpodobnost být zapomenuty
    """
    def __init__(self, capacity: int):
        self.capacity = capacity
        self.data = []

    def add(self, item: Any) -> None:
        if item not in self:
            if len(self.data) < self.capacity:
                self.data.append(item)
            else:
                assert len(self.data) == self.capacity
                index = randrange(self.capacity) # nahodný index obětovaného prvku
                self.data[index] = item # nahrazení obětovaného prvku novým

    @deprecated(reason="Pomalé")
    def get_items(self) -> list:
        """
        :deprecated: Pomalé
        :return: seznam prvků
        """
        return list(self.data) # bezpečné, ale pomalé

    def random_item(self) -> Any:
        index = randrange(len(self.data))
        return self.data[index]

    def __len__(self) -> int:
        return len(self.data)

    def __contains__(self, item: Any):
        return item in self.data

    def __repr__(self):
        return repr(self.data)

    def __iter__(self):
        return iter(self.data)

    def __bool__(self): # neni nutné a možná ani zvlášť efektivní
        return bool(self.data)

# stack = Stack()
# print(stack.is_empty())
# for i in range(10):
#     stack.push(i)
#
# print(stack)
# print(len(stack))
#
# while stack:
#     print(stack.pop())
#
# sleep(0.1)
# print(stack.peek())

# cisla = ScleroticSet(10)
#
# for i in range(100):
#     cisla.add(i)
#
# print(cisla)
#
# for item in cisla:
#     print(item)
#
# print("random:", cisla.random_item())

small = ScleroticSet(2)

small.add("Frodo")
small.add("Bilbo")
small.add("Drogo")

iterator = iter(small)
print(next(iterator))
print(next(iterator))
