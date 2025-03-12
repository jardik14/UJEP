#######################
## Testy nahodnosti pro radu typu bily sum
library(randtests)
plot(discoveries)

# Je tato rada nahodna?
difference.sign.test(discoveries)
  # test zalozeny na znamenkach diferenci
diff(discoveries,1)
  # takto vypadaji diference
sign(diff(discoveries,1))
  # takto vypadaji znamenka diferenci
table(sign(diff(discoveries,1)))
  # a tady vidime pocty kladnych a zapornych diferenci
  # podle tohoto testu je rada nahodna

# pro testy zalozene na korelacnich koeficientech potrebuji poradove cislo hodnot
index <- 1:length(discoveries)
cor.test(discoveries, index, method = "kendall")
  # test zalozeny na Kandallove korelacnim koeficientu
  # korelacni koeficient pro usporadane promenne
cor.test(discoveries, index, method = "spearman")
  # test zalozeny na Spearmanove korelacnim koeficientu
  # test pro spojite promenne zalozeny na poradich
  # oba tyto testy ukazuji mirnou zapornou korelaci (rada klesa),
  #   ktera je na hladine vyznamnosti 5% vyznamna

# dalsi testy
runs.test(discoveries)
  # Wald-Wolfowitz Runs Test
discoveries - median(discoveries)
  # rada odchylek od medianu
sign(discoveries - median(discoveries))
  # znamenka odchylek
(zn <- sign(discoveries - median(discoveries))[sign(discoveries - median(discoveries)) != 0])
  # znamenka s vynechanymi nulami
abs(diff(zn))
  # body, kde se mi meni znamenko
sum(abs(diff(zn)))/2 + 1
  # pocet useku se stejnymi znamenky
  # rada se tvari nahodne

# pro zajemce
cox.stuart.test(discoveries)
  # znamenkovy test porovnavajici dve poloviny casove rady proti sobe
bartels.rank.test(discoveries)
  # poradova verze Neumannova podiloveho testu

###############################
### Samostatne

# je rada LakeHuron nahodna?
#   hladina Huronskeho jezera
plot(LakeHuron)

difference.sign.test(LakeHuron)
  # ukezuje na nahodnost

index <- 1:length(LakeHuron)

cor.test(LakeHuron, index, method = "kendall")
  # ukazuje na slabou zápornou korelaci

cor.test(LakeHuron, index, method = "spearman")
  # ukazuje na střední zápornou korelaci

runs.test(LakeHuron)
  # ukazuje na nenahodnost

# je rada lh nahodna?
#   Luteinizing Hormone in Blood Samples
plot(lh)

difference.sign.test(lh)

index <- 1:length(lh)

cor.test(lh, index, method = "kendall")

cor.test(lh, index, method = "spearman")

runs.test(lh)
# je rada nhtemp nahodna?
#   Average Yearly Temperatures in New Haven
plot(nhtemp)

difference.sign.test(nhtemp)

index <- 1:length(nhtemp)

cor.test(nhtemp, index, method = "kendall")

cor.test(nhtemp, index, method = "spearman")

runs.test(nhtemp)
###############################

# Autokorelacni a parcialni autokorelacni funkce 
data(lh)
  # Luteinizing Hormone in Blood Samples
plot(lh)
  # v rade neni evidentni zadny trend ani sezonnost

# autokovariancni funkce
acf(lh,type="covariance")
acf(lh,type="covariance",plot=F)
  # vypis hodnot, prvni z nich je rozptyl rady
# autokorelacni funkce
acf(lh)
acf(lh,plot=F)
  # opet si muzeme nechat hodnoty vypsat
# parcialni autokorelacni funkce
pacf(lh)
  # parcialni autokorelacni funkce
pacf(lh,plot=F)
  # vypis hodnot, prvni z nich je stejna jako u autokorelacni funkce

# Ktere korelace jsou nenulove? Ktere modely pripadaji pro radu v uvahu?
par(mfrow=c(2,1))
acf(lh);pacf(lh)
par(mfrow=c(1,1))
  # nakresleni obou funkci pod sebe

# test na nulovost autokorelacni funkce
Box.test(lh, lag=2, type="Ljung-Box")
  # rucne najdete hodnotu, kterou by nemela prekrocit druha autokorelace

# nulovost autokorelacni funkce residui znamena, ze mame spravny model


# pomoci funkce arima.sim(n = ,list(ar = ,ma = )) nasimulujte rady typu
#   MA(1) s parametrem theta1 = 0.75
rada <- arima.sim(n = 100,list(ar = 0.75))
plot(rada)
par(mfrow=c(2,1))
acf(rada);pacf(rada)
par(mfrow=c(1,1))

#   MA(1) s parametrem theta1 = -0.75
rada <- arima.sim(n = 100,list(ar = -0.75))
plot(rada)
par(mfrow=c(2,1))
acf(rada);pacf(rada)
par(mfrow=c(1,1))

#   MA(1) s parametrem theta1 = 1.5
rada <- arima.sim(n = 100,list(ar = 1.5))
plot(rada)
par(mfrow=c(2,1))
acf(rada);pacf(rada)
par(mfrow=c(1,1))

#   AR(1) s parametrem phi1 = 0.75
rada <- arima.sim(n = 100,list(ma = 0.75))
plot(rada)
par(mfrow=c(2,1))
acf(rada);pacf(rada)
par(mfrow=c(1,1))

#   AR(1) s parametrem phi1 = - 0.75
rada <- arima.sim(n = 100,list(ma = -0.75))
plot(rada)
par(mfrow=c(2,1))
acf(rada);pacf(rada)
par(mfrow=c(1,1))

#   AR(1) s parametrem phi1 = 1.5
rada <- arima.sim(n = 100,list(ma = 1.5))
plot(rada)
par(mfrow=c(2,1))
acf(rada);pacf(rada)
par(mfrow=c(1,1))

# podivejte se, jak rady vypadaji a jak vypadaji jejich autokorelacni a parcialni autokorelacni funkce

# podivejte se na radu ldeaths
#   vypoctete jeji autokorelacni a parcialni autokorelacni funkci
#   ocistete ji od trendu a sezonnosti a podivejte se na autokorelacni funkci 
#     a parcialni autokorelacni funkci jejich residui
data(ldeaths)
  # Monthly Deaths from Lung Diseases in the UK
plot(ldeaths)

acf(ldeaths)

pacf(ldeaths)

par(mfrow=c(2,1))
acf(ldeaths);pacf(ldeaths)
par(mfrow=c(1,1))
