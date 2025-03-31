library(TSA)
library(forecast)
library(lmtest)

############################
## Najdete optimalni ARMA model pro radu bluebird - price
data(bluebird)
plot(bluebird[,2])
  # tydenni data o cenach "Bluebird standard potato chip"

# pomoci autokorelacni a parcialni autokorelacni funkce odhadnete rad modelu
par(mfrow = c(2,1))
acf(bluebird[,2], na.action = na.pass); pacf(bluebird[,2], na.action = na.pass)
par(mfrow = c(1,1))
# odhadnete konkretni model, jimz se rada ridi
(fit1 <- Arima(bluebird[,2], order = c(1,0,0)))
(fit2 <- Arima(bluebird[,2], order = c(2,0,0)))

# porovnejte modely pomoci AIC a BIC kriteria
BIC(fit1)
BIC(fit2)

(fit.a <- auto.arima(bluebird[,2], ic = "bic"))
  # automaticky vybrany model

plot(bluebird[,2])
lines(fitted(fit.a), col = 2)
  # zakresleni do grafu puvodnich dat a predikci modelu

# jsou vysledna residua nekorelovana?
par(mfrow = c(2,1))
acf(residuals(fit.a), na.action = na.pass); pacf(residuals(fit.a), na.action = na.pass)
par(mfrow = c(1,1))
  # minimální autokorelace

Box.test(residuals(fit.a), lag = 10, type = "Ljung-Box")
  # test na nulovost autokorelacni funkce
  # nulova hypoteza je, ze data jsou nekorelovana
  # p-hodnota je větší než 0.05, nulovou hypotezu nezamítáme

###########################
### Hledani modelu arima

# pro radu Nile, lynx
plot(Nile)
  # Flow of the River Nile
  # rada, ktera alespon v uvodu stacionarni neni
par(mfrow = c(2,1))
acf(Nile, na.action = na.pass); pacf(Nile, na.action = na.pass)
par(mfrow = c(1,1))
  # autokorelacni funkce klesa moc pomalu
acf(Nile, na.action = na.pass, type = "covariance", plot = F)
  # prvni z uvedenych hodnot je rozptyl rady
  n <- length(Nile)
  var(Nile)*(n - 1)/n

d1 <- diff(Nile)
  # rada prvnich diferenci
plot(d1)
par(mfrow = c(2,1))
acf(d1, na.action = na.pass); pacf(d1, na.action = na.pass)
par(mfrow = c(1,1))
  # rada se jevi jako stacionarni
  # pro radu diferenci se jevi jako optimalni model MA(1)
acf(d1, na.action = na.pass, type = "covariance", plot = F)
  # rozptyl se zmensil

d2 <- diff(Nile, differences = 2)
  # rada druhych diferenci
plot(d2)
par(mfrow = c(2,1))
acf(d2, na.action = na.pass); pacf(d2, na.action = na.pass)
par(mfrow = c(1,1))
acf(d2, na.action = na.pass, type = "covariance", plot = F)
  # rozptyl se zvetsil - druha diference uz je spatna

(fit1 <- Arima(Nile, order = c(1,1,0)))
  # ARIMA(1,1,0)
(fit2 <- Arima(Nile, order = c(0,1,1)))
  # ARIMA(0,1,1)
(fit3 <- Arima(Nile, order = c(0,1,2)))
  # ARIMA(0,1,2)
(fit4 <- Arima(Nile, order = c(0,1,3)))
  # ARIMA(0,1,3)
(fit5 <- Arima(Nile, order = c(1,1,1)))
  # ARIMA(1,1,1)
(fit6 <- Arima(Nile, order = c(1,1,2)))
  # ARIMA(1,1,2)
# podle AIC kriteria je optimalni rada ARIMA(1,1,1)
BIC(fit2)
BIC(fit3)
BIC(fit4)
BIC(fit5)
BIC(fit6)
  # podle BIC kriteria rada ARIMA(0,1,1)

(fit.a <- auto.arima(Nile))
  # automaticky se voli na zaklade AIC kriteria

# predpoved
(for.fit5 <- forecast(fit5))
  # predpoved s intervalem spolehlivosti
predict(fit5, 10)
  # predpoved bez intervalu spolehlivosti pouze se stredni chybou
plot(for.fit5)
  # zakresneni predpovedi do grafu

# simulace budoucich hodnot
s <- matrix(0, 10, 10)
(s[1,] <- simulate(fit5, nsim = 10, future = T))
  # simulovane pokracovani rady
plot(Nile, xlim=c(1871,1980), ylim=c(100,1700))
lines(1971:1980, s[1,], col=3)
  # zakresleni simulovane rady do grafu
for(i in 2:10){
  s[i,] <- simulate(fit5, nsim = 10, future = T)
  lines(1971:1980, s[i,], col = 3)
}
  # pripocitani a prikresleni dalsich moznych deviti pruchodu

############################
### Hledani modelu SARIMA

# Zkusime najit optimalni model pro rady nottem, UKDriverDeaths

plot(nottem)
  # Average Monthly Temperatures at Nottingham, 1920–1939
  # evidentne sezonni rada
par(mfrow = c(2,1))
acf(nottem, na.action = na.pass); pacf(nottem, na.action = na.pass)
par(mfrow = c(1,1))
  # sezonnost je videt v autokorelacni funkci

d1 <- diff(nottem, lag = 12)
# rada prvnich sezonnich diferenci
plot(d1)
par(mfrow = c(2,1))
acf(d1, na.action = na.pass); pacf(d1, na.action = na.pass)
par(mfrow = c(1,1))
  # autokorelacni i parcialni autokorelacni funkce stale ukazuji vysoke hodnoty na delce sezony,
  #   ale jinde jiz ne
  # jevi se jako MA(1) model na sezonnich datech
acf(d1, na.action = na.pass, type = "covariance", plot = F)
  # rozptyl se zmensil

fit1 <- Arima(nottem, order = c(1,0,0), seasonal = list(order = c(0,1,0)))
fit2 <- Arima(nottem, order = c(0,0,1), seasonal = list(order = c(0,1,0)))
fit3 <- Arima(nottem, order = c(1,0,1), seasonal = list(order = c(0,1,0)))
fit4 <- Arima(nottem, order = c(0,0,0), seasonal = list(order = c(1,1,0)))
fit5 <- Arima(nottem, order = c(0,0,0), seasonal = list(order = c(0,1,1)))
fit6 <- Arima(nottem, order = c(0,0,0), seasonal = list(order = c(1,1,1)))
fit7 <- Arima(nottem, order = c(1,0,0), seasonal = list(order = c(1,1,1)))
BIC(fit1)
BIC(fit2)
BIC(fit3)
BIC(fit4)
BIC(fit5)
BIC(fit6)
BIC(fit7)
  # jako optimalni se jevi posledni model
  # SARIMA(1,0,0)x(1,1,1)[12]

(fit.a <- auto.arima(nottem))
BIC(fit.a)
  # automaticky model rozhodne optimalni neni - je prilis komplikovany
coeftest(fit.a)
  # model ma spoustu nevyznamnych clenu
(fit.b <- auto.arima(nottem, ic = "bic"))
coeftest(fit.b)
  # pomoci Bayesovskeho kriteria vybran jednodussi model

# autokorelacni a parcialni autokorelacni funkce optimalniho modelu
par(mfrow = c(2,1))
acf(residuals(fit.b), na.action = na.pass); pacf(residuals(fit.b), na.action = na.pass)
par(mfrow = c(1,1))
  # zavislosti jiz v datech nejsou

#############################
### najdete optimalni model a spocitejte 15 predpovedi pro radu lynx
### najdete optimalni model pro radu BJsales, UKDriverDeaths, CREF, electricity, flow
# bjsales
data(BJsales)
plot(BJsales)

par(mfrow = c(2,1))
acf(BJsales, na.action = na.pass); pacf(BJsales, na.action = na.pass)
par(mfrow = c(1,1))

(fit.a <- auto.arima(BJsales))
  # automaticky vybrany model

plot(BJsales)
lines(fitted(fit.a), col = 2)
  # zakresleni do grafu puvodnich dat a predikci modelu

(for.fit.a <- forecast(fit.a, h = 10))
  # predpoved s intervalem spolehlivosti
plot(for.fit.a)
  # zakresleni predpovedi do grafu

# simulace budoucich hodnot
s <- matrix(0, 10, 10)
(s[1,] <- simulate(fit.a, nsim = 10, future = T))
  # simulovane pokracovani rady

plot(BJsales, xlim=c(0,160), ylim=c(200,300))
lines(150:159, s[1,], col=3)
  # zakresleni simulovane rady do grafu

# vícenásobná simulace (1000x10 prvků) a spočítání intervalu spolehlivosti
s <- matrix(0, 1000, 10)
for(i in 1:1000){
  s[i,] <- simulate(fit.a, nsim = 10, future = T)
}
quantile(s[,1], c(0.05,0.95))
  # meze 90%-niho intervalu spolehlivosti



### predikce pro kombinovanou radu

# pracujte s daty airquality (nejsou zadany jako casove rady, je treba je transformovat)
# vytvorte novou promennou, ktera bude pocitana jako Temp-0.2*Wind
# predpovidejte nove hodnoty (10 hodnot) temp.ad z dat temp a wind vcetne intervalu spolehlivosti

# predpovedi je mozne pocitat, jako predpovedi pro kazdou radu zvlast 
#   a vysledek zkombinovat dle daneho vzorce
# kombinovany interval spolehlivosti nebude fungovat
# pro interval spolehlivosti je nutne nasimulovat velke mnozstvi budoucich pruchodu obou rad
#   zkombinovat je dle daneho vzorce 
#   a interval spolehlivosti vzit jako pozadovane kvantily ze simulovanych dat

# kvantily z matice s, kde bude 10000 radku se simulovanymi pruchody rady
quantile(s[,1], c(0.05,0.95))
  # meze 90%-ni interval spolehlivosti v prvnim kroku

# pro kazdou radu tedy najdete optimalni model, simulujte budouci pruchody,
#   zkombinujte je a najdete kvantily intervalu spolehlivosti