# Možné hodnoty: dveře 0, 1, 2
guest_choice = 0
host_opened = 2

# Apriorní pravděpodobnosti
P_guest = 1/3  # Soutěžící si náhodně vybere dveře
P_prize = [1/3, 1/3, 1/3]  # Cena je rovnoměrně rozmístěná

# Podmíněné pravděpodobnosti P(Host | Guest = 0, Prize)
P_host_given_guest0 = {
    0: 0.5,  # Host otevře 2, když cena je za 0
    1: 1.0,  # Host otevře 2, když cena je za 1
    2: 0.0   # Host nikdy neotevře 2, když cena je za 2 (je tam výhra)
}

# Výpočet čitatelů podle Bayesova pravidla
P_unnormalized = []
for prize_door in [0, 1, 2]:
    p = P_guest * P_prize[prize_door] * P_host_given_guest0[prize_door]
    P_unnormalized.append(p)

# Normalizační konstanta
Z = sum(P_unnormalized)

# Posteriorní pravděpodobnosti
posterior = [p / Z for p in P_unnormalized]

# Výstup
print("Posteriorní pravděpodobnosti P(Prize | Guest = 0, Host = 2):")
for i, p in enumerate(posterior):
    print(f"Dveře {i}: {p:.3f}")

# Doporučení
best_door = posterior.index(max(posterior))
if best_door != guest_choice:
    print(f"\nDoporučení: Změnit volbu na dveře {best_door} – pravděpodobnost výhry: {posterior[best_door]:.2%}")
else:
    print(f"\nDoporučení: Zůstat u původní volby dveří {guest_choice} – pravděpodobnost výhry: {posterior[best_door]:.2%}")
