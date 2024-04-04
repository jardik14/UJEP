from random import randint


def generate_list(size):
    list = [randint(1, 100) for _ in range(size-1)]
    list.insert(randint(0, size), 0)
    return list


def bubble_sort(seznam_na_serazeni: list):
    seznam = seznam_na_serazeni.copy()
    not_sorted = True
    while not_sorted:
        not_sorted = False
        for i in range(len(seznam)-1):
            if seznam[i+1] < seznam[i]:
                not_sorted = True
                seznam[i], seznam[i+1] = seznam[i+1], seznam[i]
    return seznam


def selection_sort(seznam_na_serazeni: list):
    seznam = seznam_na_serazeni.copy()
    for i in range(len(seznam)):
        min_index = i
        for j in range(i+1, len(seznam)):
            if seznam[min_index] > seznam[j]:
                min_index = j
        if min_index != i:
            seznam[i], seznam[min_index] = seznam[min_index], seznam[i]
    return seznam


def insertion_sort(seznam_na_serazeni: list):
    seznam = seznam_na_serazeni.copy()
    for i in range(len(seznam)):
        key_val = seznam[i]

        j = i-1
        while j >= 0 and key_val < seznam[j]:
            seznam[j+1] = seznam[j]
            j -= 1
        seznam[j+1] = key_val
    return seznam


def quicksort(seznam_na_serazeni: list):
    seznam = seznam_na_serazeni.copy()
    if len(seznam) <= 1:
        return seznam
    pivot = seznam[0]
    mensi = [x for x in seznam[1:] if x < pivot]
    vetsi = [x for x in seznam[1:] if x > pivot]
    return quicksort(mensi) + [pivot] + quicksort(vetsi)


def merge_sort(seznam_na_serazeni: list):
    seznam = seznam_na_serazeni.copy()

    if len(seznam) <= 1:
        return

    mid_index = int(len(seznam) // 2)
    leva_strana = seznam[:mid_index]
    prava_strana = seznam[mid_index:]

    merge_sort(leva_strana)
    merge_sort(prava_strana)

    i = j = k = 0

    print(seznam)

    while i < len(leva_strana) and j < len(prava_strana):
        if leva_strana[i] < prava_strana[j]:
            seznam[k] = leva_strana[i]
            print("i")
            i += 1
        else:
            seznam[k] = prava_strana[j]
            print("j")
            j += 1
        k += 1

    while i < len(leva_strana):
        seznam[k] = leva_strana[i]
        i += 1
        k += 1

    while j < len(prava_strana):
        seznam[k] = prava_strana[j]
        j += 1
        k += 1

    return seznam



a = generate_list(4)
print(a)
print(bubble_sort(a))
print(selection_sort(a))
print(insertion_sort(a))
print(quicksort(a))
print(merge_sort(a))

