rm(list=ls())
######################
## Interval spolehlivosti

library(DescTools)
# aktivace knihovny

# Nactete data Kojeni.RData
setwd("D:/Programko/UJEP/PAS/cv10")
load("Kojeni.RData")
## Spoctete 95% interval spolehlivosti pro prumer vysky muzu (otcu) kdyz vite, 
#  ze rozptyl vysky dospelych muzu je 49.
vyska <- Kojeni$vyskaO

# vypocet pomoci funkce v knihovne DescTools
MeanCI(vyska, sd = sqrt(49))
  # se spolehlivosti 95% skutecna stredni hodnota vysky otcu lezi v intervalu od 177.9 do 180.6 cm

## A jaky je 99% interval spolehlivosti pro vysku matky? 
vyska <- Kojeni$vyskaM
MeanCI(vyska, conf.level = 0.99)
  # Na hladine vyznamnosti 1% rozhodnete, zda muze byt stredni hodnota vysky matek 165 cm?
  # Plati toto rozhodnuti i na hladine vyznamnosti 5%?
  MeanCI(vyska, conf.level = 0.99, method ="boot")
    # muzete pouzit i bootstrapovy interval spolehlivosti

## Na 5% hladine vyznamnosti rozhodnete, zda stredni hodnota porodni hmotnosti deti muze byt 3.5kg.
porHmot <- Kojeni$porHmotnost
MeanCI(porHmot)
t.test(porHmot, mu=3500)

## V jakem rozmezi by se s 90% spolehlivosti mela nachazet stredni hodnota porodni delky deti?
porDelka <- Kojeni$porDelka
MeanCI(porDelka, conf.level = 0.90)

## Je 95%-ni interval spolehlivosti pro porodni hmotnost stejny u divek a u hochu?
pohlavi <- Kojeni$Hoch
porHmot <- Kojeni$porHmotnost
tapply(porHmot, pohlavi, MeanCI)

## A je mezi divkami a hochy vyznamny rozdil (na petiprocentni hladine vyznamnosti)?
MeanDiffCI(porHmot ~ pohlavi)
  # pokud interval neobsahuje nulu, je vyznamny rozdil ve strednich hodnotach

# A co rozdil na jednoprocentni hladine vyznamnosti?
MeanDiffCI(porHmot ~ pohlavi, conf.level=0.99)

##  Lisi se prumerna hmotnost pulrocnich deti, ktere byly jeste
#  jeste v pul roce kojeny a tech, co uz kojeny nebyly (promenna Koj24)?
hmotnost <- Kojeni$hmotnost
koj <- Kojeni$Koj24
MeanDiffCI(hmotnost ~ koj)

###################################
### Interval spolehlivosti pro pravdepodobnost (podil)

## Spoctete a interpretujte 95%-ni interval spolehlivosti pro 
#  podil otcu pritomnych u porodu

otec <- Kojeni$Otec
table(otec)
  # u porodu bylo pritomno 36 otcu
round(prop.table(table(otec)), 4) * 100
  # coz je 36.36%

# rucni vypocet
p <- prop.table(table(otec))[2]
n <- length(otec)
alpha <- 0.05
q.n <- qnorm(1-alpha/2)

# dolni mez
p - q.n*sqrt(p*(1-p)/n)
# horni mez
p + q.n*sqrt(p*(1-p)/n)
  # se spolehlivosti 95% skutecny podil otcu pritomnych u porodu se nachazi mezi 26.9% a 45.8%

BinomCI(table(otec)[2], sum(table(otec)), method = "wald")
  # 95%-ni interval spolehlivosti pro podil/pravdepodobnost

## Spoctete 90%-ni interval spolehlivosti pro podil deti, 
#  ktere byly jeste v pul roce kojeny (promenna Koj24)
koj <- Kojeni$Koj24
table(koj)
BinomCI(table(koj)[1], sum(table(koj)), method = "wald", conf.level = 0.9)

#################################
### Interval spolehlivosti pro rozdil podilu

## A je rozdil v podilu otcu pritomnych u porodu mezi Prahou a Kladnem?
mesto <- Kojeni$Porodnice
(tab <- table(otec, mesto))

# vypocet 
BinomDiffCI(x1 = tab[2,1], n1 = tab[1,1] + tab[2,1], x2 = tab[2,2], n2 = tab[1,2] + tab[2,2], method ="wald")

## Spoctete 99% interval spolehlivosti pro rozdil podilu v pul roce kojenych deti v Praze a v Kladne.
(tab <- table(koj, mesto))
BinomDiffCI(x1 = tab[1,1], n1 = tab[1,1] + tab[2,1], x2 = tab[1,2], n2 = tab[1,2] + tab[2,2], method ="wald", conf.level = 0.99)

################################
### Linearni regrese

## Zavisi porodni hmotnost na porodni delce deti?
zavisla <- Kojeni$porHmotnost
nezavisla <- Kojeni$porDelka

# nejprve graf
plot(zavisla ~ nezavisla, pch=19,main="Graf zavislosti dvou ciselnych promennych",
     xlab="Porodni delka",ylab="Porodni hmotnost")
# zavislost je zrejma

# korelacni koeficient
cor(zavisla, nezavisla)
  # silna kladna/rostouci/prima zavislost

# Je tato zavislost statisticky vyznamna?
#   H0: promenne spolu nesouvisi vs. H1: promenne spolu souvisi
cor.test(zavisla, nezavisla)
  # p-hodnota < 2.2e-16 < alfa 0.05 => zamitam H0
  #   Zavislost mezi porodni hmotnosti a delkou je statisticky vyznamna.

# linearni regrese
abline(lm(zavisla ~ nezavisla),col=2,lwd=2)
  # grafem prolozim primku
(Model1 <- lm(zavisla ~ nezavisla))
  # odhad regresnich koeficientu - popis primky
  # porodni hmotnost = -7905.8 + 224.8*porodni delka
  #   je dulezite, ktera promenna je na x-ove a ktera na y-ove ose
  # s narustem porodni delky o 1cm naroste porodni hmotnost v promeru o 224.8 g
summary(Model1)
  # souhrn vystupu
  # v casti Coefficients najdeme odhady regresnich koeficientu (Estimate)
  #   a dale test o jejich nulovosti (kdyz je posledni hodnota v radku
  #   Pr(>|t|) mensi nez 0.05, pak se koeficient vyznamne lisi od nuly,
  #   a za posledni hodnotou se objevi alespon jedna hvezdicka)
  # v souhrnu Multiple R-squared je procento variability zavisle promenne 
  #   vysvetlene modelem: z variability porodni hmotnosti se vysvetlilo 62.5%
confint(Model1)
  # 95% intervaly spolehlivosti pro regresni koeficienty
  # ani jeden z nich neobsahuje nulu

## Jak zavisi hmotnost v pul roce na porodni hmotnosti?
zavisla <- Kojeni$hmotnost
nezavisla <- Kojeni$porHmotnost

plot(zavisla ~ nezavisla, pch=19,main="Graf zavislosti dvou ciselnych promennych",
     xlab="Porodni hmotnost",ylab="Hmotnost v pul roce")

cor(zavisla, nezavisla)
cor.test(zavisla, nezavisla)
abline(lm(zavisla ~ nezavisla),col=2,lwd=2)


(Model2 <- lm(zavisla ~ nezavisla))
  # hmotnost = 4839.3 + 0.8215*porodni hmotnost
  #   na jeden gram porodni hmotnosti pripada v prumeru 0.8215 gramu hmotnosti v pul roce
summary(Model2)
  # modelem se vysvetlilo 18.4% variability hmotnosti v pul roce
confint(Model2)
  # linerarni koeficient se vyznamne lisi od nuly

## A co kdyz do modelu pridame jeste delku?
#  Zavisi hmotnost deti v pul roce na jejich delce a na porodni hmotnosti?
nezavisla2 <- Kojeni$delka

(Model3 <- lm(zavisla ~ nezavisla + nezavisla2))
  # hmotnost = -413 + 0.5837*porodni hmotnost + 88.66*delka
  #   na jeden gram porodni hmotnosti pripada v prumeru 0.5837 gramu hmotnosti v pul roce
  #      pri stejne delce v pul roce
  #   na jeden centimetr delky v pul roce pripada v prumeru 88.66 gramu hmotnosti
  #      pri stejne porodni hmotnosti
summary(Model3)
  # modelem se vysvetlilo 28.7% variability hmotnosti v pul roce
  # pridani dalsi promenne vyrazne pomohlo
confint(Model3)
  # zadny z intervalu spolehlivosti pro linearni cleny neobsahuje nulu
  #   obe promenne jsou v modelu vyznamne

## A kdyz pridame do modelu jeste porodni delku?
nezavisla3 <- Kojeni$porDelka

(Model4 <- lm(zavisla ~ nezavisla + nezavisla2 + nezavisla3))
summary(Model4)
confint(Model4)
  # koeficienty se po pridani kazde dalsi promenne meni
  # pridanim porodni delky do modelu jsme si uskodili
  #  a vysvetlili jsme jen 29.3% variability hmotnosti

## Zavisi BMI pulrocnich deti na jejich porodni hmotnosti, delce v pul roce a veku matky?

# Testy predpokladu
oldpar <- par(mfrow = c(2,2))
plot(Model3) 
par(oldpar)
  # testuje se 
  # linearni vztah: na prvnim grafu nema byt videt trend 
  # normalita residui: na druhem grafu maji body lezet na primce 
  # stabilita rozptylu: krivka na tretim grafu nema mit trend
  # vlivna pozorovani: na ctvrtem grafu nemaji body lezet vne mezi 

library(car)
vif(Model3) 
  # testuje se multikolinearita - nemelo by byt vetsi nez 5 
avPlots(Model3) 
  # testuje se efekt pridani dalsi promenne