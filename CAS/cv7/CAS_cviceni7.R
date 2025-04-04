############################
library(forecast)
library(TSA)
library(dynlm)
library(lmtest)
  # nacteni knihoven

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
n <- length(nottem)
var(nottem)*(n - 1)/n
  # rozptyl rady

d1 <- diff(nottem, lag = 12)
  # rada prvnich sezonnich diferenci
plot(d1)
  # rada je na prvni pohled bez trendu i sezonnosti
par(mfrow = c(2,1))
acf(d1, na.action = na.pass); pacf(d1, na.action = na.pass)
par(mfrow = c(1,1))
  # autokorelacni i parcialni autokorelacni funkce stale ukazuji vysoke hodnoty na delce sezony,
  #   ale jinde jiz ne, tedy neni treba dalsi diference
  # jevi se jako MA(1) model na sezonnich datech (PACF klesa pomaleji)
n <- length(d1)
var(d1)*(n - 1)/n
  # rozptyl rady diferenci je mensi nez rozptyl puvodni rady

(fit.a <- auto.arima(nottem))
  # optimalni SARIMA model s vyuzitim AIC
  coeftest(fit.a)
    # prilis mnoho nevyznamnych clenu - zbytecne komplikovany model
AIC(fit.a)
BIC(fit.a)

(fit.b <- auto.arima(nottem, ic = 'bic'))
  # vyuzitim BIC ziskavame znacne jednodussi model
  coeftest(fit.b)
    # stale jeden nevyznamny clen
AIC(fit.b)
BIC(fit.b)
acf(residuals(fit.b))
  # autokorelacni funkce pro residua

# rucni hledani modelu
fit1 <- Arima(nottem, order = c(0,0,0), seasonal = list(order = c(1,1,1)))
  # model pouze se sezonni zavislosti
AIC(fit1)
BIC(fit1)
acf(residuals(fit1))
  # vyuziti modelu pouze pro sezonni slozku ukazuje zavislost na minulych hodnotach
pacf(residuals(fit1))
  # zavislost by mela obsahovat clen AR

fit2 <- Arima(nottem, order = c(1,0,0), seasonal = list(order = c(1,1,1)))
coeftest(fit2)
AIC(fit2)
BIC(fit2)
acf(residuals(fit2))
  # jiny vypocet BIC preferuje jeste jednodussi model
  # model pouze s vyznamnymi cleny a nekorelovanymi residui
  # optimalni model: SARIMA(1,0,0)x(1,1,1)[12]
    # oznacme Y(t) radu sezonnich diferenci
    # optimalni model: Y(t) = 0.271*Y(t - 1) - 0.296*Y(t - 12) - 0.728*e(t - 12) + e(t)

plot(nottem)
lines(fitted(fit2), col = 2)
  # model dobre kopiruje data

# pro srovnani model bez sezonnosti
(fit3 <- auto.arima(nottem, seasonal = FALSE))
plot(nottem)
lines(fitted(fit3), col = 2)
  # i takovy model umi dobre kopirovat data

# Rozdil je videt zejmena na predikci
pred.s <- forecast(fit2, 30)
plot(pred.s)
pred.ns <- forecast(fit3, 30)
plot(pred.ns)
  # model bez sezonnosti ma vetsi chybu (sirsi interval spolehlivosti)
  #   a klesajici sezonni vykyvy
#############################
## Samostatne

# najdete optimalni model pro radu flow z knihovny TSA
data(flow)
plot(flow)

par(mfrow = c(2,1))
acf(flow, na.action = na.pass); pacf(flow, na.action = na.pass)
par(mfrow = c(1,1))

d1 <- diff(flow, lag = 12)
plot(d1)

par(mfrow = c(2,1))
acf(d1, na.action = na.pass); pacf(d1, na.action = na.pass)
par(mfrow = c(1,1))

(fit.a <- auto.arima(flow))
coeftest(fit.a)
BIC(fit.a)
(fit.b <- auto.arima(flow, ic = 'bic'))
coeftest(fit.b)
BIC(fit.b)

fit1 <- Arima(flow, order = c(0,0,0), seasonal = list(order = c(1,1,1)))
coeftest(fit1)
BIC(fit1)

fit2 <- Arima(flow, order = c(1,0,0), seasonal = list(order = c(1,1,1)))
coeftest(fit2)
BIC(fit2)

plot(flow)
lines(fitted(fit2), col = 2)

pred <- forecast(fit2, 50)
plot(pred)

# najdete optimalni model pro radu co2
plot(co2)

par(mfrow = c(2,1))
acf(co2, na.action = na.pass); pacf(co2, na.action = na.pass)
par(mfrow = c(1,1))

d1 <- diff(co2, lag = 12)
plot(d1)

par(mfrow = c(2,1))
acf(d1, na.action = na.pass); pacf(d1, na.action = na.pass)
par(mfrow = c(1,1))

(fit.a <- auto.arima(co2))
coeftest(fit.a)
BIC(fit.a)

(fit.b <- auto.arima(co2, ic = 'bic'))
coeftest(fit.b)
BIC(fit.b)

fit1 <- Arima(co2, order = c(1,0,0), seasonal = list(order = c(1,0,0)))
coeftest(fit1)
BIC(fit1)

fit2 <- Arima(co2, order = c(0,1,1), seasonal = list(order = c(2,1,0)))
coeftest(fit2)
BIC(fit2)

plot(co2)
lines(fitted(fit2), col = 2)

pred <- forecast(fit2, 50)
plot(pred)

pred.b <- forecast(fit.b, 50)
plot(pred.b)


############################
### pouziti dynamickeho modelovani k odhaleni trendu a sezonnosti
# funkce dynlm z knihovny dynlm
# model pro radu nottem
plot(nottem)

# dynamicky linearni model
dlm.not <- dynlm(nottem ~ trend(nottem) + season(nottem))
summary(dlm.not)
  # na vystupu vidim vyznamny absoutni clen (nenulova uroven rady)
  # mirny rostouci linearni trend
  # vyznamnou sezonnost (vysoke hodnoty od cervna do zari, nizke hodnoty listopad az brezen)

not <- ts.intersect(nottem, dlm.not$fitted.values)
plot.ts(not, plot.type = "single", col=c("black","red"), 
        lty=c(1,1), lwd=c(1,1),
        main = "Dynamic Linear Model - Original (black) and Fitted series (red)")
  # odhad modelu odpovida datum

# predpovedi nutne rucne
data <- data.frame(dlm.not$model)
  # puvodni data, na nez sedi koeficienty
data.new <- data.frame("cas" = data[1:30,2] + 20, "sezona" = as.factor(data[1:30,3]))
  # nova data, pro nez chci predikovat
dl.cof <- dlm.not$coefficients
  # koeficienty modelu

# predikce: trend + sezonnost
data.new$trend <- dl.cof[1] + dl.cof[2]*data.new[,1]
data.new$season <- rep(c(0,dl.cof[3:13]),3)[1:30]
data.new$pred <- data.new$trend + data.new$season

# zakresleni predikci do grafu
cas.x <- c(time(nottem), data.new$cas + 1920)
nottem.y <- c(nottem, data.new$pred)
co.col <- c(rep("black", length(nottem)), rep("blue", length(data.new$pred)))
plot(nottem.y ~ cas.x, xlab = "Time", ylab = "nottem", type = "n")
lines(nottem)
lines(data.new$cas + 1920, data.new$pred, col = "blue", lwd = 2)

# kontrola residui
acf(dlm.not$residuals)
  # ackoliv semodel chova dobre, residua nejsou zcela nekorelovana
auto.arima(dlm.not$residuals)
  # residua ukazuji na vyznamnou zavislost na minule hodnote a na minule sezone

# pridani zavislosti na minulych pozorovanich do modelu
dlm.not2 <- dynlm(nottem ~ trend(nottem) + season(nottem) + L(nottem, -1))
summary(dlm.not2)
  # model se zavislosti na minule hodnote (AR(1) clen)
acf(dlm.not2$residuals)
  # stale je videt vyznamna sezonni zavislost

dlm.not3 <- dynlm(nottem ~ trend(nottem) + season(nottem) + L(nottem, -1) + L(nottem, -12))
summary(dlm.not3)
  # model se zavislosti na minule hodnote (AR(1) clen)
acf(dlm.not3$residuals)
  # a mam nezavisla residua - finalni model
# predikce by se musely pocitat rucne

#################################
## Samostatne 

# hledejte optimalni dynamicky model pro radu flow

#################################
### kroskorelacni funkce 
# prozkoumejme vzajemne vztahy mezi radami souboru airquality
ccf(ts(airquality$Wind),ts(airquality$Solar.R),na.action = na.pass)
  # nejsou zavisle
ccf(ts(airquality$Wind),ts(airquality$Ozone),na.action = na.pass)
  # jsou zavisle, nejvyssi korelace je s nulovym zpozdenim

###########################
### dynamicke linearni modely
# jak modelovat zavislost mezi casovymi radami

## priklad pro umela data 
# generovani dat
set.seed(999)
x_series <- arima.sim(n = 200, list(order = c(1,0,0), ar = 0.7, sd=1))
  # nasimulovany AR(1) proces
z <- ts.intersect(lag(x_series, 0), lag(x_series, 1)) 
  # hodnoty rady x_series v case t a t-1
y_series <- 15 + 0.8*z[,1] + 1.5*z[,2] + rnorm(199,0,1)
  # kombinace aktualni a zpozdene hodnoty + nahodne chyby
xy_series <- ts.intersect(y_series, z)
  # datovy soubor s jednou zavislou a dvema znezavislymi promennymi

# model pomoci bezne linearni regrese
lm1 <- lm(xy_series[,1] ~ xy_series[,2] + xy_series[,3])
summary(lm1)
  # popis modelu

checkresiduals(lm1)
  # popis residui modelu
  # abychom mohli pouzit klasicky linearni model, musi byt residua normalni, 
  #   s konstantnim rozptylem a NEKORELOVANA
  # nekorelovanosti residui se tyka i vypsany test (Breusch-Godfrey)
  #   je-li p-hodnota > alfa 0.05, pak residua jsou nekorelovana az do radu 10

# model pomoci dynamickeho modelovani
dlm1 <- dynlm(y_series ~ L(x_series, 0) + L(x_series, -1))
summary(dlm1)
  # stejny vysledek

### Jak pracovat s korelovanymi residui 
# generovani dat
set.seed(999)
x2_series <- arima.sim(n = 200, list(order = c(1,0,0), ar = 0.7, sd=1))
z2 <- ts.intersect(x2_series, lag(x2_series, 3), lag(x2_series, 4)) 
y2_series <- 15 + 0.8*z2[,2] + 1.5*z2[,3] 
y2_errors <- arima.sim(n = 196, list(order = c(1,0,1), ar = 0.6, ma = 0.6), sd=1)
y2_series <- y2_series + y2_errors
plot(y2_series)
  # zavisle promenna - casova rada

# chceme modelovat zavislost y2 na x2
# nejprve hledame, zda je zavislost v case t nebo se zpozdenim
ccf(x2_series, y2_series)
(mc <- which.max(ccf(x2_series, y2_series, plot = F)$acf))
  # maximalni korelace na 24 pozici
ccf(x2_series, y2_series, plot=F)$lag[mc]
  # se zpozdenim 4 kroku

# dynamicky model
dlm1 <- dynlm(y2_series ~ L(x2_series, -4))
summary(dlm1)
  # zavislost je prukazna
# je to cela zavislost nebo jeste neco v datech zbylo?
ccf(x2_series, dlm1$residuals)
dlm2 <- dynlm(y2_series ~ L(x2_series, -3) + L(x2_series, -4))
summary(dlm2)
  # prukazna zavislost o 3 i 4 kroky zpet
ccf(x2_series, dlm2$residuals)
  # nyni uz v datech zadna zavislost neni

# vyznamnost koeficientu
lm2d <- ts.intersect(y2_series, dlm2$fitted.values)
plot.ts(lm2d, plot.type = "single", col=c("black","red"), 
        lty=c(1,1), lwd=c(1,1),
        main = "'Classic' Linear Model - Original (black) and Fitted series (red)") 
  # jak model sedi na data
# kontrola residui
checkresiduals(dlm2)
  # autokorelovana residua

# do modelu pridame autokorelovana residua
x2Lagged <- cbind(
  xLag0 = x2_series,
  xLag3 = lag(x2_series, 3),
  xLag4 = lag(x2_series, 4))
xy2_series <- ts.union(y2_series, x2Lagged)
  # matice se zavisle promennou a posunutymi nezavisle promennymi

# do prikazu auto.arima muzeme pridat i matici regresoru
arima1 <- auto.arima(xy2_series[,1], xreg = xy2_series[,3:4])
arima1
  # jak vypadaji residua tohoto modelu
checkresiduals(arima1)
  # ok

# zakresleni modelu do dat
arima1d <- ts.intersect(na.omit(xy2_series[,1]), arima1$fitted)
plot.ts(arima1d, plot.type = "single", col=c("black","red"), 
        lty=c(1,1), lwd=c(1,1),
        main = "ARIMA errors model - Original (black) and Fitted series (red)") 

# vyznamnost koeficientu ARIMA modelu
coeftest(arima1)

########################
### Samostatne

# najdete optimalni model pro radu AirPassengers
plot(AirPassengers)

# hledejte optimalni model pro radu ozonu v datech airquality v zavislosti na ostatnich promennych
