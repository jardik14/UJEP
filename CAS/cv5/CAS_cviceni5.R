rm(list=ls())
#######################
### knihovny
library(forecast)
library(lmtest)

#######################
### Opakovani
# Autokorelacni a parcialni autokorelacni funkce 
# vyzkousime pro radu nhtemp
plot(nhtemp)
  # prumerna rocni teplota ve stupnich Fahrenheita v New Haven z let 1912 az 1971
  # rada bez zasadniho trendu ci sezonnosti

# autokorelacni funkce
acf(nhtemp)
acf(nhtemp,plot=F)
  # konkretni hodnoty
# parcialni autokorelacni funkce
pacf(nhtemp)
pacf(nhtemp,plot=F)
  # vypis hodnot
# Ktere hodnoty jsou nenulove? Muzeme jednoznacne urcit model?
  # zasadni hodnoty ani u jedne funkce nejsou
  # hodnoty ACF klesaji pomaleji
  # hodnoty PACF jsou od zpozdeni 2 temer nulove

# Pokud predpokladame, ze jen PACF ma bod useknuti a to na zpozdeni k=2
#   mela by rada byt typu AR(2)

# Kontrola pres odhady ruznych AR a MA modelu
(fit1 <- arima(nhtemp, order = c(1,0,0)))
  # rada AR(1) 
(fit2 <- arima(nhtemp, order = c(2,0,0)))
  # rada AR(2)
(fit3 <- arima(nhtemp, order = c(3,0,0)))
  # rada AR(3)
(fit4 <- arima(nhtemp, order = c(0,0,1)))
  # rada MA(1)
(fit5 <- arima(nhtemp, order = c(0,0,2)))
  # rada MA(2)
  # podle AIC kriteria je nejvhodnejsi rada typu AR(2)
  # z vystupu dostavame odhad Y(t) = 51.19 + 0.22Y(t-1) + 0.32Y(t-2)
plot(nhtemp)
lines(fitted(fit2), col = 4)
  # prestoze je model ze zkoumanych moznosti nejlepsi, uplne dobre data nekopiruje
fit.hw <- HoltWinters(nhtemp, gamma = F)
plot(fit.hw)
  # ani dvojite exponencialni vyrovnani nesedi na data zcela optimalne

# A co rada LakeHuron
plot(LakeHuron)
  # rocni hodnoty vysky hladiny Huronskeho jezera ve stopach z let 1875-1972

# autokorelacni a parcialni autokorelacni funkce
acf(LakeHuron)
pacf(LakeHuron)
  # ktere korelace jsou nenulove zde?
  # ktery model bychom odhadovali?
  # a jak takovy model sedi na data?
(fit1 <- arima(LakeHuron, order = c(1,0,0)))
(fit2 <- arima(LakeHuron, order = c(2,0,0)))
(fit3 <- arima(LakeHuron, order = c(3,0,0)))
(fit4 <- arima(LakeHuron, order = c(0,0,1)))
(fit5 <- arima(LakeHuron, order = c(0,0,2)))

plot(LakeHuron)
lines(fitted(fit2), col = 4)

fit.hw <- HoltWinters(LakeHuron, gamma = F)
plot(fit.hw)
lines(fitted(fit2), col = 4)

########################
## Hledani modelu ARMA
# rada presidents
plot(presidents)
  # ctvrtletni hodnoceni americkych prezidentu
  # rada bez zjevneho trendu, budu na ni hledat model ARMA

# autokorelacni a parcialni autokorelacni funkce
par(mfrow = c(2,1))
acf(presidents, na.action = na.pass); pacf(presidents, na.action = na.pass)
par(mfrow = c(1,1))
  # autokorelacni funkce nema bod useknuti, parcialni autokorelacni funkce ho ma, k0 = 1
  # optimalni model by mel byt AR(1)

# odhadnu vice jednoduchych modelu
(fit1 <- arima(presidents, order = c(1,0,0)))
  # AR(1)
(fit2 <- arima(presidents, order = c(2,0,0)))
  # AR(2)
(fit3 <- arima(presidents, order = c(0,0,1)))
  # MA(1)
(fit4 <- arima(presidents, order = c(1,0,1)))
  # ARMA(1,1)

# ke kazdemu modelu vidim Akaikeho informacni kriterium
#   podle nej by mel byt nejlepsi model AR(1) : aic = 839.78

# Bayesovske informacni kriterium - pro vyber optimalniho modelu je lepsi
BIC(fit1)
BIC(fit2)
BIC(fit3)
BIC(fit4)
  # i timto kriteriem vyberu model AR(1)

# v knihovne forecast existuje i funkce, ktera hleda idealni model automaticky
(fit.a <- auto.arima(presidents, seasonal = F))
  # vybira optimalni model se slozitosti az do radu ARMA(5,5)
  # optimalni model vybira podle Akaikeho kriteria
BIC(fit.a)  
  # na zaklade BIC kriteria bych radeji volila jednodussi model AR(1)
  (fit.b <- auto.arima(presidents, seasonal = F, ic = "bic"))
    # mohu BIC nastavit i primo do funkce auto.arima

# vykresleni obou modelu proti sobe
plot(presidents)
lines(fitted(fit1),col=2)
lines(fitted(fit.a),col=3)
  # rozdil neni prilis velky - zelena krivka je hladsi

# Odhadnute modely
#   AR(1): Y(t) = 56.15 + 0.82Y(t-1)
#   ARMA(3,2): Y(t) = 56.07 - 0.5Y(t-1) + 0.36Y(t-2) + 0.62Y(t-3) + 1.35e(t-1) + 0.92e(t-2)

### Dalsi kriteria pro urceni idealniho modelu:
  # hodnoty parametru by mely byt alespon 2x vetsi nez jejich stredni chyba
  #   tj. mely by byt vyznamne
  # autokorelacni funkce residui modelu by mely byt male
# AR(1) model
coeftest(fit1)
  # vyznamnost vypoctenych koeficientu
par(mfrow = c(2,1))
acf(residuals(fit1), na.action = na.pass); pacf(residuals(fit1), na.action = na.pass)
par(mfrow = c(1,1))
  # minimalni zbyla autoregrese
# ARMA(3,2) model
coeftest(fit.a)
  # vyznamnost vypoctenych koeficientu
par(mfrow = c(2,1))
acf(residuals(fit.a), na.action = na.pass); pacf(residuals(fit.a), na.action = na.pass)
par(mfrow = c(1,1))
  # nulova autokorelace

## test na nulovost autokorelacni funkce
#   nulovost autokorelacni funkce residui znamena, ze mame spravny model
Box.test(residuals(fit1), lag=5, type = "Ljung-Box")
Box.test(residuals(fit.a), lag=5, type = "Ljung-Box")
  # u ARMA(3,2) modelu vychazi autokorelacni funkce primo nulova
  #   u modelu AR(1) je mirna odchylka

# Jaky model tedy vybrat? - subjektivni rozhodnuti :)

#############################
### Samostatne

# hledejte optimalni model pro rady 
#	  airquality$Wind, discoveries, treering, lh

plot(airquality$Wind, type = "l")
acf(airquality$Wind)
pacf(airquality$Wind)
(fit1 <- arima(airquality$Wind, order = c(1,0,0)))

(fit.a <- auto.arima(airquality$Wind, seasonal = F))
BIC(fit.a)

(fit.b <- auto.arima(airquality$Wind, seasonal = F, ic = "bic"))
BIC(fit.b)

plot(airquality$Wind, type = "l")
lines(fitted(fit1), col = 4)
lines(fitted(fit.b), col = 3)

# ----------------
plot(discoveries, type = "l")
acf(discoveries)
pacf(discoveries)
(fit3 <- arima(discoveries, order = c(3,0,0)))

(fit.a <- auto.arima(discoveries, seasonal = F))
BIC(fit.a)

(fit.b <- auto.arima(discoveries, seasonal = F, ic = "bic"))
BIC(fit.b)

plot(discoveries, type = "l")
lines(fitted(fit3), col = 4)
lines(fitted(fit.b), col = 3)
