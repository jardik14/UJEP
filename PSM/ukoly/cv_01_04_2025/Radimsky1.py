import numpy as np

# Názvy hypotéz
hypotheses = ['H1: Zcela se nelíbí', 'H2: Nelíbí se', 'H3: Neutrální pocity', 'H4: Líbí se', 'H5: Zamilovanost']

# Apriorní pravděpodobnosti
P_H = np.array([0.1, 0.15, 0.5, 0.2, 0.05])

# Pravděpodobnosti pozorování P(E|Hi)
evidence_likelihoods = {
    "kontakt pohledem": np.array([0.1, 0.2, 0.4, 0.2, 0.1]),
    "úsměv": np.array([0.1, 0.1, 0.2, 0.4, 0.2]),
    "požádala o pití": np.array([0.52, 0.45, 0.029, 0.0009, 0.0001]),
    "dívá se na jiné muže": np.array([0.3, 0.4, 0.2, 0.08, 0.02]),
    "krátké fráze": np.array([0.1, 0.4, 0.3, 0.1, 0.1]),
    "toaleta + make-up": np.array([0.05, 0.05, 0.1, 0.2, 0.6]),
}


def bayesian_update(prior, evidence_vector):
    """Provádí Bayesovskou aktualizaci"""
    unnormalized_posterior = prior * evidence_vector
    normalization_constant = np.sum(unnormalized_posterior)
    posterior = unnormalized_posterior / normalization_constant
    return posterior


def analyze_observations(observations):
    """Analyzuje sekvenci pozorování a vypočítá konečné posteriorní pravděpodobnosti"""
    posterior = P_H.copy()
    print("Apriorní pravděpodobnosti:")
    for h, p in zip(hypotheses, posterior):
        print(f"{h}: {p:.3f}")

    for obs in observations:
        if obs not in evidence_likelihoods:
            print(f"Pozorování '{obs}' není známo. Přeskakuji.")
            continue
        print(f"\nPozorování: {obs}")
        likelihood = evidence_likelihoods[obs]
        posterior = bayesian_update(posterior, likelihood)
        for h, p in zip(hypotheses, posterior):
            print(f"{h}: {p:.3f}")

    print("\nNejpravděpodobnější stav:", hypotheses[np.argmax(posterior)], f"({posterior.max():.2%})")
    return posterior


# Příklad použití – postupná pozorování
observations = [
    "kontakt pohledem",
    "úsměv",
    "toaleta + make-up"
]

final_posterior = analyze_observations(observations)
