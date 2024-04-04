class Stack:
    def __init__(self):
        self._values = list()

    def add(self, value):
        self._values.append(value)
        max_val = self._values.pop(Stack.get_max(self._values))
        self._values.append(max_val)

    def pop(self):
        return self._values.pop()

    def get_max(l: list) -> int:
        max_index = 0
        max_val = l[max_index]
        for i, val in enumerate(l):
            if val > max_val:
                max_index = i
                max_val = val
        return max_index

z = Stack()
z.add(1)           # [1]
z.add(3)           # [3,1]
z.add(2)           # [3,2,1]
print(z.pop())     # 3 [2,1]
print(z.pop())     # 2 [1]
z.add(5)           # [5,1]
z.add(0)           # [5,0,1]
print(z.pop())     # 5 [0,1]
print(z.pop())     # 0 [1]