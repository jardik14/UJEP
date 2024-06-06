from abc import abstractmethod, ABC
from json import load
from numbers import Real
from pathlib import Path
from typing import Dict, Iterable, Iterator, Tuple, Union, Any, List, Callable
from enum import Enum
from collections.abc import MutableSequence
import statistics


class Type(Enum):
    Float = 0
    String = 1


def to_float(obj) -> float:
    """
    casts object to float with support of None objects (None is cast to None)
    """
    return float(obj) if obj is not None else None


def to_str(obj) -> str:
    """
    casts object to float with support of None objects (None is cast to None)
    """
    return str(obj) if obj is not None else None


def common(iterable): # from ChatGPT
    """
    returns True if all items of iterable are the same.
    :param iterable:
    :return:
    """
    try:
        # Nejprve zkusíme získat první prvek iterátoru
        iterator = iter(iterable)
        first_value = next(iterator)
    except StopIteration:
        # Vyvolá výjimku, pokud je iterátor prázdný
        raise ValueError("Iterable is empty")

    # Kontrola, zda jsou všechny další prvky stejné jako první prvek
    for value in iterator:
        if value != first_value:
            raise ValueError("Not all values are the same")

    # Vrací hodnotu, pokud všechny prvky jsou stejné
    return first_value


class Column(MutableSequence):# implement MutableSequence (some method are mixed from abc)
    """
    Representation of column of dataframe. Column has datatype: float columns contains
    only floats and None values, string columns contains strings and None values.
    """
    def __init__(self, data: Iterable, dtype: Type):
        self.dtype = dtype
        self._cast = to_float if self.dtype == Type.Float else to_str
        # cast function (it casts to floats for Float datatype or
        # to strings for String datattype)
        self._data = [self._cast(value) for value in data]

    def __len__(self) -> int:
        """
        Implementation of abstract base class `MutableSequence`.
        :return: number of rows
        """
        return len(self._data)

    def __getitem__(self, item: Union[int, slice]) -> Union[float,
                                    str, list[str], list[float]]:
        """
        Indexed getter (get value from index or sliced sublist for slice).
        Implementation of abstract base class `MutableSequence`.
        :param item: index or slice
        :return: item or list of items
        """
        return self._data[item]

    def __setitem__(self, key: Union[int, slice], value: Any) -> None:
        """
        Indexed setter (set value to index, or list to sliced column)
        Implementation of abstract base class `MutableSequence`.
        :param key: index or slice
        :param value: simple value or list of values

        """
        self._data[key] = self._cast(value)

    def append(self, item: Any) -> None:
        """
        Item is appended to column (value is cast to float or string if is not number).
        Implementation of abstract base class `MutableSequence`.
        :param item: appended value
        """
        self._data.append(self._cast(item))

    def insert(self, index: int, value: Any) -> None:
        """
        Item is inserted to colum at index `index` (value is cast to float or string if is not number).
        Implementation of abstract base class `MutableSequence`.
        :param index:  index of new item
        :param value:  inserted value
        :return:
        """
        self._data.insert(index, self._cast(value))

    def __delitem__(self, index: Union[int, slice]) -> None:
        """
        Remove item from index `index` or sublist defined by `slice`.
        :param index: index or slice
        """
        del self._data[index]

    def permute(self, indices: List[int]) -> 'Column':
        """
        Return new column which items are defined by list of indices (to original column).
        (eg. `Column(["a", "b", "c"]).permute([0,0,2])`
        returns  `Column(["a", "a", "c"])
        :param indices: list of indexes (ints between 0 and len(self) - 1)
        :return: new column
        """
        new_data = []
        for idx in indices:
            new_data.append(self._data[idx])

        return Column(new_data, self.dtype)

    def copy(self) -> 'Column':
        """
        Return shallow copy of column.
        :return: new column with the same items
        """
        # FIXME: value is cast to the same type (minor optimisation problem)
        return Column(self._data, self.dtype)

    def get_formatted_item(self, index: int, *, width: int):
        """
        Auxiliary method for formating column items to string with `width`
        characters. Numbers (floats) are right aligned and strings left aligned.
        Nones are formatted as aligned "n/a".
        :param index: index of item
        :param width:  width
        :return:
        """
        assert width > 0
        if self._data[index] is None:
            if self.dtype == Type.Float:
                return "n/a".rjust(width)
            else:
                return "n/a".ljust(width)
        return format(self._data[index],
                      f"{width}s" if self.dtype == Type.String else f"-{width}.2g")

class DataFrame:
    """
    Dataframe with typed and named columns
    """
    def __init__(self, columns: Dict[str, Column]):
        """
        :param columns: columns of dataframe (key: name of dataframe),
                        lengths of all columns has to be the same
        """
        assert len(columns) > 0, "Dataframe without columns is not supported"
        self._size = common(len(column) for column in columns.values())
        # deep copy od dict `columns`
        self._columns = {name: column.copy() for name, column in columns.items()}

    def __getitem__(self, index: int) -> Tuple[Union[str,float]]:
        """
        Indexed getter returns row of dataframe as tuple
        :param index: index of row
        :return: tuple of items in row
        """
        return tuple(c[index] for c in self._columns.values())

    def __iter__(self) -> Iterator[Tuple[Union[str, float]]]:
        """
        :return: iterator over rows of dataframe
        """
        for i in range(len(self)):
            yield tuple(c[i] for c in self._columns.values())

    def __len__(self) -> int:
        """
        :return: count of rows
        """
        return self._size

    @property
    def columns(self) -> Iterable[str]:
        """
        :return: names of columns (as iterable object)
        """
        return self._columns.keys()

    def __repr__(self) -> str:
        """
        :return: string representation of dataframe (table with aligned columns)
        """
        lines = []
        lines.append(" ".join(f"{name:12s}" for name in self.columns))
        for i in range(len(self)):
            lines.append(" ".join(self._columns[cname].get_formatted_item(i, width=12)
                                     for cname in self.columns))
        return "\n".join(lines)

    def append_column(self, col_name:str, column: Column) -> None:
        """
        Appends new column to dataframe (its name has to be unique).
        :param col_name:  name of new column
        :param column: data of new column
        """
        if col_name in self._columns:
            raise ValueError("Duplicate column name")
        self._columns[col_name] = column.copy()

    def append_row(self, row: Iterable) -> None:
        """
        Appends new row to dataframe.
        :param row: tuple of values for all columns
        """
        if len(row) == len(self._columns):
            for item, col_name in zip(row, self._columns.keys()):
                self._columns[col_name].append(item)
            self._size += 1
        else:
            print("nuh uh")

    def filter(self, col_name:str,
               predicate: Callable[[Union[float, str]], bool]) -> 'DataFrame':
        """
        Returns new dataframe with rows which values in column `col_name` returns
        True in function `predicate`.

        :param col_name: name of tested column
        :param predicate: testing function
        :return: new dataframe
        """
        column = self._columns[col_name]
        indices = [i for i in range(len(column)) if predicate(column[i])]

        new_df = DataFrame(self._columns)
        new_df._size = len(indices)
        for col_name in self._columns.keys():
            new_df._columns[col_name] = self._columns[col_name].permute(indices)
        return new_df



    # ------------------------------------------------

    def empty(self) -> bool:
        """
        Returns True if dataframe is empty
        :return: bool
        """
        return len(self) == 0

    def ndim(self) -> int:
        """
        Returns number of dimensions of dataframe
        :return: int
        """
        return 2

    def shape(self):
        """
        Returns shape of dataframe
        :return: tuple
        """
        return (len(self), len(self._columns))

    def size(self) -> int:
        """
        Returns number of elements in dataframe
        :return: int
        """
        return len(self) * len(self._columns)

    def head(self, n: int) -> 'DataFrame':
        """
        Returns first n rows of dataframe
        :param n: number of rows
        :return: new dataframe
        """
        new_df = DataFrame(self._columns)
        new_df._size = min(n, len(self))
        for col_name in self._columns.keys():
            new_df._columns[col_name] = self._columns[col_name].permute(range(n))
        return new_df

    def tail(self, n: int) -> 'DataFrame':
        """
        Returns last n rows of dataframe
        :param n: number of rows
        :return: new dataframe
        """
        new_df = DataFrame(self._columns)
        new_df._size = min(n, len(self))
        for col_name in self._columns.keys():
            new_df._columns[col_name] = self._columns[col_name].permute(range(len(self) - n, len(self)))
        return new_df

    def rename(self, columns: Dict[str, str]) -> 'DataFrame':
        """
        Returns new dataframe with renamed columns
        :param columns: dict with old and new names
        :return: new dataframe
        """
        new_columns = {}
        for col_name in self._columns.keys():
            new_columns[columns[col_name]] = self._columns[col_name].copy()
        return DataFrame(new_columns)

    def dtypes(self) -> Dict[str, Type]:
        """
        Returns types of columns
        :return: dict
        """
        return {col_name: col.dtype for col_name, col in self._columns.items()}

    def at(self, row_index: int, col_name: str) -> Union[float, str]:
        """
        Returns value at `row_index` in column `col_name`
        :param row_index: index of row
        :param col_name: name of column
        :return: value
        """
        return self._columns[col_name][row_index+1]

    def iat(self, row_index: int, col_index: int) -> Union[float, str]:
        """
        Returns value at `row_index` in column `col_index`
        :param row_index: index of row
        :param col_index: index of column
        :return: value
        """
        return self._columns[list(self._columns.keys())[col_index]][row_index]

    def isna(self) -> 'DataFrame':
        """
        Returns dataframe with boolean values (True if value is None)
        :return: new dataframe
        """
        new_columns = {}
        for col_name in self._columns.keys():
            new_columns[col_name] = Column([item is None for item in self._columns[col_name]], Type.Float)
        return DataFrame(new_columns)

    def map(self, col_name:str, func: Callable[[Union[float, str]], Union[float, str]]) -> 'DataFrame':
        """
        Returns new dataframe with column `col_name` transformed by function `func`.
        :param col_name: name of column
        :param func: transformation function
        :return: new dataframe
        """
        new_df = DataFrame(self._columns)
        new_df._size = len(self)
        new_df._columns[col_name] = Column([func(item) for item in self._columns[col_name]], self._columns[col_name].dtype)
        return new_df

    def dropna(self) -> 'DataFrame':
        """
        Returns new dataframe without rows with None values
        :return: new dataframe
        """
        indices = [i for i in range(len(self)) if all(item is not None for item in self[i])]
        new_df = DataFrame(self._columns)
        new_df._size = len(indices)
        for col_name in self._columns.keys():
            new_df._columns[col_name] = self._columns[col_name].permute(indices)
        return new_df
    # ------------------------------------------------

    def sort(self, col_name:str, ascending=True) -> 'DataFrame':
        """
        Sort dataframe by column with `col_name` ascending or descending.
        :param col_name: name of key column
        :param ascending: direction of sorting
        :return: new dataframe
        """
        sorting_col = self._columns[col_name]
        sorted_indices = sorted(range(len(sorting_col)), key=lambda i: sorting_col[i])
        if not ascending:
            sorted_indices.reverse()
        new_df = DataFrame(self._columns)
        for col_name in self._columns.keys():
            new_df._columns[col_name] = self._columns[col_name].permute(sorted_indices)
        return new_df

    def describe(self) -> str:
        """
        similar to pandas but only with min, max and avg statistics for floats and count"
        :return: string with formatted decription
        """
        stat_data = Column(["count", "mean", "std", "min", "25%", "50%", "75%", "max"], Type.String)
        describe_df = DataFrame(dict(stat = stat_data))
        for col_name in self._columns.keys():
            column = self._columns[col_name]
            if column.dtype == Type.Float:

                stats = []
                stats.append(len(column))
                stats.append(statistics.mean(column._data))
                stats.append(statistics.stdev(column._data))
                stats.append(min(column._data))
                stats.append(statistics.median_low(column._data))
                stats.append(statistics.median(column._data))
                stats.append(statistics.median_high(column._data))
                stats.append(max(column._data))

                describe_df.append_column(col_name, Column(stats, Type.Float))

        return repr(describe_df)


    def inner_join(self, other: 'DataFrame', self_key_column: str,
                   other_key_column: str) -> 'DataFrame':
        """
            Inner join between self and other dataframe with join predicate
            `self.key_column == other.key_column`.

            Possible collision of column identifiers is resolved by prefixing `_other` to
            columns from `other` data table.
        """
        self_key = self._columns[self_key_column]
        other_key = other._columns[other_key_column]
        assert len(self_key) == len(other_key), "Key columns have to have the same length"

        self_indices = {key: i for i, key in enumerate(self_key)}
        other_indices = {key: i for i, key in enumerate(other_key)}

        new_columns = {}
        for col_name in self.columns:
            new_columns[col_name] = self._columns[col_name].copy()
        for col_name in other.columns:
            new_columns[f"{col_name}_other"] = other._columns[col_name].copy()

        new_df = DataFrame(new_columns)
        new_df._size = 0
        for i in range(len(self)):
            key = self_key[i]
            if key in other_indices:
                new_df.append_row([self[cname][i] for cname in self.columns] +
                                  [other[f"{cname}_other"][other_indices[key]] for cname in other.columns])
        return new_df

    def setvalue(self, col_name: str, row_index: int, value: Any) -> None:
        """
        Set new value in dataframe.
        :param col_name:  name of culumns
        :param row_index: index of row
        :param value:  new value (value is cast to type of column)
        :return:
        """
        col = self._columns[col_name]
        col[row_index] = col._cast(value)

    @staticmethod
    def read_csv(path: Union[str, Path]) -> 'DataFrame':
        """
        Read dataframe by CSV reader
        """
        return CSVReader(path).read()

    @staticmethod
    def read_json(path: Union[str, Path]) -> 'DataFrame':
        """
        Read dataframe by JSON reader
        """
        return JSONReader(path).read()

    # --------------------------------------------------
    # Zápočet

    # Úloha 1
    def dot(self, other: 'DataFrame') -> 'DataFrame':
        if self.shape()[1] != other.shape()[0]:
            raise ValueError

        new_df_columns = {}

        res_rows = [[] for _ in range(len(self))]


        # i : řada A
        # j : sloupec B
        # k : sloupec A / řada B
        for i in range(len(self)):
            for j in range(other.shape()[1]):
                res = 0
                for k in range(self.shape()[1]):
                    print(f"A[{k}][{i}] = {self.iat(i, k)}")
                    print(f"B[{j}][{k}] = {other.iat(k, j)}")

                    res += self.iat(i, k) * other.iat(k, j)
                print(f"Res: {res}")
                res_rows[i].append(res)

        new_df_columns = {f"res_{i}": Column(res_rows[i], Type.Float) for i in range(len(res_rows))}

        return DataFrame(new_df_columns)

    # Úloha 2
    def diff(self, axis: int = 0) -> 'DataFrame':
        if axis == 0:
            new_cols = {}
            for col_name in self.columns:
                col = self._columns[col_name]
                new_cols[col_name] = Column([None] + [col[i] - col[i-1] for i in range(1, len(col))], col.dtype)
            return DataFrame(new_cols)
        if axis == 1:
            cols_lists = []
            cols_lists.append([None for _ in range(len(self))])
            for i in range(1, self.shape()[1]):
                col_list = []
                for j in range(len(self)):
                    res = self.iat(j,i) - self.iat(j,i-1)
                    col_list.append(res)
                cols_lists.append(col_list)
            new_cols = {}
            for idx,col_name in enumerate(self.columns):
                new_cols[col_name] = Column(cols_lists[idx], Type.Float)

            return DataFrame(new_cols)



    # Úloha 3
    def cumprod(self, axis: int) -> 'DataFrame':
        if axis == 0:
            new_cols = {}
            for col_name in self.columns:
                col = self._columns[col_name]
                col_list = []
                res = 1
                for i in range(len(col)):
                    res *= col[i]
                    col_list.append(res)
                new_cols[col_name] = Column(col_list, Type.Float)
            return DataFrame(new_cols)
        if axis == 1:
            rows_lists = []
            for i in range(len(self)): # radek
                row_list = []
                res = 1
                for j in range(self.shape()[1]): # sloupec
                    res *= self.iat(i,j)
                    row_list.append(res)
                row_list.append(row_list)

            cols_lists = [[] for _ in range(len(rows_lists[0]))]
            for idx,col_list in enumerate(cols_lists):
                for item in rows_lists[idx]:
                    col_list.append(item)

            new_cols = {}
            for idx, col_name in enumerate(self.columns):
                new_cols[col_name] = Column(cols_lists[idx], Type.Float)

            return DataFrame(new_cols)


    # -------------------------------------------------------------


class Reader(ABC):
    def __init__(self, path: Union[Path, str]):
        self.path = Path(path)

    @abstractmethod
    def read(self) -> DataFrame:
        raise NotImplemented("Abstract method")


class JSONReader(Reader):

    """
    Factory class for creation of dataframe by JSON file. JSON file must contain
    one object with attributes which array values represents columns.
    The type of columns are inferred from types of their values (columns which
    contains only value is floats columns otherwise string columns),
    """
    def read(self) -> DataFrame:
        with open(self.path, "rt") as f:
            json = load(f)
        columns = {}
        for cname in json.keys(): # cyklus přes sloupce (= atributy JSON objektu)
            dtype = Type.Float if all(value is None or isinstance(value, Real)
                                      for value in json[cname]) else Type.String
            columns[cname] = Column(json[cname], dtype)
        return DataFrame(columns)


class CSVReader(Reader):
    """
    Factory class for creation of dataframe by CSV file. CSV file must contain
    header line with names of columns.
    The type of columns should be inferred from types of their values (columns which
    contains only value has to be floats columns otherwise string columns),
    """
    ...


if __name__ == "__main__":
    df = DataFrame(dict(
        a=Column([1.5, 3.1415], Type.Float),
        b=Column(["a", 2], Type.String),
        c=Column(range(2), Type.Float)
        ))
    df.setvalue("a", 1, 42)
    print(df)

    df.append_column("d", Column([1, 2], Type.Float))

    df.append_row([4,3,2,1])
    print(df)

    a = Column([1,2,3], Type.Float).permute([0,0,2])
    print(a._data)

    print(df.describe())

    df2 = DataFrame(dict(
        a=Column([2,3,1], Type.Float),
        b=Column(["asdasd","skrppap","more"], Type.String),
        c=Column(range(3), Type.Float)
        ))

    print(df2.sort("a", ascending=True))

    df3 = DataFrame(dict(
        id=Column([1,2,3,4,5], Type.Float),
        name=Column([None,"Martin","Dežo","Martin","Martin"], Type.String),
        age=Column([15,22,31,16,19], Type.Float)
        ))

    print(df3.filter("age", lambda x: x > 18))
    print(df3.filter("name", lambda x: x == "Martin"))

    print(df3.map("age", lambda x: x*-1))
    print(df3.dropna())

    df4 = DataFrame(dict(
        a=Column([1,4], Type.Float),
        b=Column([2,5], Type.Float),
        c=Column([3,6], Type.Float)
        ))

    df5 = DataFrame(dict(
        a=Column([1,3,5], Type.Float),
        b=Column([2,4,6], Type.Float)
        ))

    print(df4.dot(df5))


    df6 = DataFrame(dict(
        a=Column([1,2,3,4,5,6], Type.Float),
        b=Column([1,1,2,3,5,8], Type.Float),
        c=Column([1,4,9,16,25,36], Type.Float)
        ))

    print(df6.diff(1))

    df7 = DataFrame(dict(
        a=Column([2,3,1], Type.Float),
        b=Column([1,2,0], Type.Float),
        ))

    print(df7.cumprod(0))
##