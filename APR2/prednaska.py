class Sheet:
    def __init__(self, height: int, width: int, weight: int):
        """
        creates a new representation of sheet of paper
        :param height: in mm (height >= width)
        :param width: in mm
        :param weight: weight of 1m^2
        """

        assert height >= width, "Height must be greater than width"
        assert height > 0, "Height must be greater than 0"
        assert width > 0, "Width must be greater than 0"
        assert weight > 0, "Weight must be greater than 0"


        self._height = height
        self._width = width
        self._weight = weight

    def half_sheet(self) -> "Sheet":
        """
        cutting paper in half according to height
        :return: new sheet
        """
        return Sheet(self._width, self._height // 2, self._weight)

    def sheet_weight(self) -> float:
        """
        :return: weight of the sheet
        """
        return self._height * self._width * self._weight / 1e6

    def __repr__(self) -> str:
        return f"Sheet({self._height}, {self._width}, {self._weight})"


    @staticmethod
    def from_iso(format: str, weight: int) -> 'Sheet': # factory static method
        return sheet_from_iso(format, weight)

    @staticmethod
    def square_sheet(side: int, weight: int) -> 'Sheet': # factory static method
        return Sheet(side, side, weight)

def sheet_from_iso(format: str, weight: int) -> Sheet: # factory funkce
    iso_formats = {
        "A0": (841, 1189),
        "A1": (594, 841),
        "A2": (420, 594),
        "A3": (297, 420),
        "A4": (210, 297),
        "A5": (148, 210),
        "A6": (105, 148),
        "A7": (74, 105),
        "A8": (52, 74),
        "A9": (37, 52),
        "A10": (26, 37)
    }
    if format not in iso_formats:
        raise Exception("Unsupported ISO format")
    return Sheet(iso_formats[format][1], iso_formats[format][0], weight)


a = Sheet.from_iso("A4", 80)
print(a)
print(a.half_sheet().sheet_weight())

x = sheet_from_iso("A4", 80)
print(x)
print(x.half_sheet().sheet_weight())

s = Sheet(297, 210, 80)
print(s)
print(s.half_sheet().sheet_weight())
