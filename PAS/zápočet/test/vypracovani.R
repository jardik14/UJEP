rm(list=ls())

setwd("D:/Programko/UJEP/PAS/zápočet/test")
load("Math.RData")

View(Math)

psatm <- Math$PSATM
hist(psatm)
Skew(psatm)

satm <- Math$SATM
hist(satm)
Skew(satm)

actm <- Math$ACTM
hist(actm)
Skew(actm)

gpaadj <- Math$GPAadj
hist(gpaadj)
Skew(gpaadj)

plcmt <- Math$PlcmtScore
hist(plcmt)
Skew(plcmt)

oldpar <- par(mfrow = c(2,3))
hist(psatm)
hist(satm)
hist(actm)
hist(gpaadj)
hist(plcmt)
par(oldpar)

# Nejvíc asymetrický je gpaadj. Podle histogrmů proměnných a jejicj šikmosti
Kurt(gpaadj)
# Leptokurtické rozdělení

plot(gpaadj ~ plcmt, pch=19, main ="Rozptylový graf závislosti proměnných GPAadj a PlcmtScore")
abline(lm(gpaadj ~ plcmt), col=2, lwd=2)

cov(gpaadj,plcmt,use = "complete.obs")
cor(gpaadj,plcmt,use = "complete.obs")
cor.test(gpaadj,plcmt)
# slabá příma souvislost, na základě rozptylového grafu, korelačního koeficientu a testu lineární závislosti

grade <- Math$Grade
table(grade)
grade_factor <- factor(grade, ordered = TRUE)
quantile(grade_factor,0.8, type = 1)
# 80% studentů má známku B nebo lepší

oldpar <- par(mfrow = c(1,2))
hist(satm)
hist(plcmt)
par(oldpar)

mean(satm)
mean(plcmt)

Skew(satm)
Skew(plcmt)

Kurt(satm)
Kurt(plcmt)

size <- Math$Size
jadro <- density(size)
hist(size, breaks = 10, freq = F)
lines(jadro)
jadro$x[which.max(jadro$y)]


# Najděte indexy lokálních maxim
moduses_indices <- which(diff(sign(diff(jadro$y))) == -2)

# Extrahujte hodnoty modusu (x a odpovídající y)
moduses_x <- jadro$x[moduses_indices]
moduses_y <- jadro$y[moduses_indices]

# Zobrazení výsledků
data.frame(Modus_X = moduses_x, Modus_Y = moduses_y)


rec <- Math$RecTaken
high <- Math$TooHigh
low <- Math$TooLow


MeanCI(size, conf.level = 0.95)


t.test(psatm ~ high)


boxplot(gpaadj)
boxplot(gpaadj, range = 3)


p <- 5/8
k <- 4
n <- 7

1 - dbinom(k,n,p)

mu <- 100
sd <- sqrt(225)
x <- 85
pnorm(x,mu,sd)

1 - pnorm(130, mu, sd)

pnorm(125,mu,sd) - pnorm(110,mu,sd)

pnorm(100,mu,sd)**2
