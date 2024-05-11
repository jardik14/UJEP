rm(list = ls())
students <- read.csv("StudentsPerformance2.csv")


stredni_hodnota <- median(students$math.score)

# spočítejte průměrnou hodnotu z náhodného vzorku sloupce math.score
# výpočet proveďte pro různé velikosti náhodných vzorků (různé počty hodnot ve vzorku)

seznam_rozdilu <- c()

for (i in 0:1000) {
  vzorek <- sample(students$math.score, i)
  prumerna_hodnota <- mean(vzorek)
  seznam_rozdilu <- c(seznam_rozdilu, abs(prumerna_hodnota - stredni_hodnota))
}


# do grafu vyneste absolutní hodnotu rozdílu průměrné hodnoty vzorku od celkové střední hodnoty jako funkci velikosti vzorku

plot(0:1000, seznam_rozdilu, type = "l", col = "red", xlab = "Velikost vzorku", ylab = "Absolutní hodnota rozdílu průměrné hodnoty vzorku od celkové střední hodnoty")

# -----------------------

# Pomocí bodového grafu vykreslete vztah sloupců writing.score a reading.score vůči sloupci math.score.
# Vytvořte lineární regresní model popisující vykreslené závislosti. Výsledný model přidejte do každého z grafů jako novou křivku.
# Pro každou závislost vypočtěte Pearsonův a Spearmanův korelační koeficient.

library(ggplot2)
library(dplyr)

graf1 <- ggplot(students, aes(x = math.score, y = writing.score)) + geom_point() + geom_smooth(method = "lm", se = FALSE)
print(graf1)
pearson1 <- cor(students$math.score, students$writing.score, method = "pearson")
print(pearson1)
spearman1 <- cor(students$math.score, students$writing.score, method = "spearman")
print(spearman1)


graf2 <- ggplot(students, aes(x = math.score, y = reading.score)) + geom_point() + geom_smooth(method = "lm", se = FALSE)
print(graf2)
pearson2 <- cor(students$math.score, students$reading.score, method = "pearson")
print(pearson2)
spearman2 <- cor(students$math.score, students$reading.score, method = "spearman")
print(spearman2)

# -----------------------

# Hypotéza: průměrné skóre studentů (avg_score z minulého cvičení) nezávisí na tom, zda se studenti na test připravovali nebo ne (sloupec test.preparation.course)

students["avg_score"] = (students$math.score + students$reading.score + students$writing.score)/3

hypoteza_boxplot_1 <- boxplot(students$avg_score ~ students$test.preparation.course, xlab = "Příprava na test", ylab = "Průměrné skóre")
print(hypoteza_boxplot_1)

model <- t.test(students$avg_score ~ students$test.preparation.course)
print(model)


# Hypotéza: dosažená úroveň vzdělání rodičů studenta (parental level of education) nezávisí na etnické skupině (race.etnicity))

model <- chisq.test(students$parental.level.of.education, students$race)
print(model)


