rm(list=ls())

# Úkol 1: Road - Počet zemřelých na silnicích
# Na čem závisí měsíční počet zemřelých na silnicích?

# Volím vícenásobnou lineární regresi, protože chci zjistit, jak různé faktory ovlivňují počet zemřelých na silnicích.

library(MASS)
library(car)
library(lmtest)

data(road)
summary(road)

# Závislá proměnná: deaths (počet zemřelých)
# Nezávislé proměnné: drivers, popden, rural, temp, fuel

# Dílčí grafy: závislost deaths na ostatních proměnných
par(mfrow = c(2, 3))
plot(road$deaths ~ road$drivers, main = "deaths ~ drivers", pch = 19, col = "steelblue")
plot(road$deaths ~ road$popden, main = "deaths ~ popden", pch = 19, col = "tomato")
plot(road$deaths ~ road$rural, main = "deaths ~ rural", pch = 19, col = "darkgreen")
plot(road$deaths ~ road$temp, main = "deaths ~ temp", pch = 19, col = "orange")
plot(road$deaths ~ road$fuel, main = "deaths ~ fuel", pch = 19, col = "purple")
par(mfrow = c(1, 1))

# Poissonova regrese
model.pois <- glm(deaths ~ drivers + popden + rural + temp + fuel, 
                  family = poisson(link = "log"), data = road)

summary(model.pois)

# Vypočítáme míru overdispersion
dispersion <- sum(residuals(model.pois, type = "pearson")^2) / model.pois$df.residual
dispersion  # dispersion > 1.5, uvažujeme Quasi-Poisson

# Quasi-Poissonova regrese
model.qpois <- glm(deaths ~ drivers + popden + rural + temp + fuel,
                   family = quasipoisson(link = "log"), data = road)

summary(model.qpois)


# Výsledky quasi-Poissonovy regrese:

# Závislá proměnná: deaths (počet zemřelých na silnicích)
# Použitý model: glm s rodinou quasipoisson (log-link), kvůli silné overdisperzi (dispersion ≈ 142.5)

# Statisticky významné proměnné:
# - drivers: p < 0.001, koeficient = 0.001693
#     => Každých 1000 registrovaných řidičů navíc zvyšuje počet úmrtí přibližně o 1.8 % (exp(0.001693 * 1000) ≈ 1.018)
# - fuel: p ≈ 0.015, koeficient = 0.002431
#     => Každý litr spotřebovaného paliva navíc zvyšuje počet úmrtí o cca 0.24 % (exp(0.002431) ≈ 1.0024)

# Hraničně významná proměnná:
# - temp: p ≈ 0.099
#     => Vyšší teplota může souviset s vyšším počtem úmrtí, ale důkaz není dostatečně silný.
 
# Nevýznamné proměnné:
# - popden (hustota osídlení): p ≈ 0.30
# - rural (podíl venkovské populace): p ≈ 0.18


# --------------------------------------------------------


# Úkol 2: Pima.te – Glukóza a interakce s type

rm(list=ls())


library(MASS)
library(car)
library(lmtest)

data(Pima.te)

set.seed(42)
Pima.sub <- Pima.te[sample(nrow(Pima.te), 300), ]

# Vytvoření modelu se všemi hlavními efekty a interakcemi s 'type'
model <- lm(glu ~ (npreg + bp + skin + bmi + ped + age) * type, data = Pima.sub)

# Automatická kroková regrese
model.st <- step(model)
summary(model.st)

# Ověření předpokladů
par(mfrow = c(2, 2))
plot(model.st)
par(mfrow = c(1, 1))

# Test normality reziduí – Shapiro-Wilk
# H0: Rezidua mají normální rozdělení
# H1: Rezidua nemají normální rozdělení
shapiro.test(residuals(model.st))
  # Výsledek: p = 0.069 → nezamítáme H0, normalita je přijatelná

# Test homoskedasticity – Breusch-Pagan
# H0: Rezidua mají konstantní rozptyl (homoskedasticita)
# H1: Rezidua nemají konstantní rozptyl (heteroskedasticita)
bptest(model.st)
  # Výsledek: p < 0.05 → zamítáme H0, heteroskedasticita přítomna

# Logaritmická transformace pro stabilizaci rozptylu

# Log-transformace závislé proměnné
Pima.sub$log_glu <- log(Pima.sub$glu)

model_log <- lm(log_glu ~ (npreg + bp + skin + bmi + ped + age) * type, data = Pima.sub)
model_log.st <- step(model_log)
summary(model_log.st)

# Test homoskedasticity pro log-transformovaný model
bptest(model_log.st)
# Výsledek: p < 0.05 → i po log-transformaci přetrvává heteroskedasticita

library(sandwich)     # pro robustní odhady rozptylu
library(lmtest)

# Robustní odhad (Whiteova heteroskedastická korekce)
coeftest(model.st, vcov = vcovHC(model.st, type = "HC1"))

# Interpretace koeficientů:
# Interpretace platí při ostatních proměnných v modelu konstantních.
# - npreg: každé těhotenství snižuje glukózu o 1.38 jednotek, statisticky významné (p = 0.0037)
# - skin. každá jednotka tloušťky kožní řasy zvyšuje glukózu o 0.31 jednotky, statisticky významné (p = 0.0028)
# - age: každé zvýšení věku o 1 rok zvyšuje glukózu o 0.5 jednotek, statisticky významné (p = 0.0096)
# - typeYes: ženy s diabetem mají v průměru o 33.6 jednotek vyšší glukózu než ženy bez diabetu (statisticky silně významné: p < 2.2e-16).

# Hodnocení kvality modelu:
# - R² = 0.3415 (adjusted R² = 0.3326):
  #Model vysvětluje cca 34 % variability hladiny glukózy.
# - Test normality reziduí (Shapiro-Wilk): p = 0.069 – normalita přijatelná.
# - Breusch-Pagan test: p < 0.05 – heteroskedasticita přítomna, proto byly použity robustní směrodatné chyby (White HC1).

mean_skin <- mean(Pima.sub$skin, na.rm = TRUE)

newdata <- data.frame(
  npreg = 4,
  skin = 29.2,
  age = 35,
  type = factor("Yes", levels = levels(Pima.sub$type))
)

# Předpověď s 95% intervalem spolehlivosti:
predict(model.st, newdata, interval = "confidence", level = 0.95)

# Podle modelu by tato žena měla mít průměrnou hladinu glukózy 143.6 s 95% intervalem spolehlivosti [138.5, 148.7].

# ---------------------------------------------------------

# Úkol 3: Greene – Odvolání proti zamítnutí azylu
rm(list=ls())

library(carData)
library(dplyr)
library(ggplot2)

data("Greene")
help(Greene)

# Závislá proměnná decision je binární (yes / no), proto použijeme logistickou regresi

# Převod decision na binární kód (1 = yes, 0 = no)
Greene$decision_bin <- as.numeric(Greene$decision == "yes")

# Vytvoření počátečního modelu se všemi kategorickými prediktory
model <- glm(decision_bin ~ judge + nation + rater + language + location, 
                  data = Greene, family = binomial)

# Stepwise výběr nejlepšího modelu dle AIC
model.st <- step(model)

# Shrnutí výsledků
summary(model.st)

# nejvýznamějším prediktorem je proměnná rater, 
# tedy rozhodnutí nezávislého hodnotitele silně ovlivňuje finální rozhodnutí soudce
# při ostatních proměnných v modelu konstantních.

# Počty žadatelů podle země
nation_freq <- table(Greene$nation)
nation_freq

# Země s malým počtem
rare_nations <- names(nation_freq[nation_freq < 10])

# Nová proměnná s přejmenováním
Greene$nation_grp <- as.character(Greene$nation)
Greene$nation_grp[Greene$nation_grp %in% rare_nations] <- "Other"
Greene$nation_grp <- factor(Greene$nation_grp)

model_grouped <- glm(decision_bin ~ judge + nation_grp + rater + location,
                     family = binomial, data = Greene)

model_grouped.st <- step(model_grouped)

# Shrnutí nového modelu
summary(model_grouped.st)

# Srovnání modelů
AIC(model.st, model_grouped.st)
  # model se sjednocenými zeměmi má mírně nižší AIC

anova(model.st, model_grouped.st, test = "Chisq")
  # p > 0.05, tedy sjednocení zemí nezhoršilo model

# Jak je na tom česko
cz_coeff <- coef(model_grouped.st)["nation_grpCzechoslovakia"]
cz_coeff

exp(cz_coeff) # = 33.5
  #  Žadatelé z Československa mají více než 33× vyšší šanci
  # na kladné rozhodnutí ve srovnání s referenční zemí (Bulharsko)
  # při ostatních proměnných v modelu konstantních.

# Interpretace 2 dalších regresních koeficientů:

rater_yes_coeff <- coef(model_grouped.st)["rateryes"]
exp(rater_yes_coeff)  # = 4.5
# rateryes:
# Pokud rozhodnutí učinil nezávislý hodnotitel (rater = yes),
# šance na kladné rozhodnutí odvolacího soudu jsou přibližně 4,5× vyšší
# než u referenční kategorie (rater = no),
# při ostatních proměnných v modelu konstantních.

location_toronto_coeff <- coef(model_grouped.st)["locationToronto"]
exp(location_toronto_coeff)  # = 3.6
# locationToronto:
# Pokud se řízení odehrávalo v Torontu (location = Toronto),
# šance na kladné rozhodnutí jsou přibližně 3,6× vyšší
# než v referenční lokalitě (např. Montreal),
# při ostatních proměnných v modelu konstantních.


