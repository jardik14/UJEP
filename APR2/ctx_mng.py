from time import perf_counter
from contextlib import contextmanager

class benchmark:
    def __init__(self):
        self.start_time = None
    def __enter__(self):
        self.start_time = perf_counter()
    def __exit__(self, *args):
        print(f"Elapsed time: {perf_counter() - self.start_time}")


@contextmanager
def gbenchmark():
    start_time = perf_counter()
    yield start_time
    print(f"Elapsed time: {perf_counter() - start_time}")

with benchmark():
    print("Hello, world!")

with gbenchmark() as start_time:
    print(f"Hello, world at {start_time}!")

