rm(list=ls())

############################
## Dekompozice casovych rad - hledani trendu a sezonni slozky
# nacteni knihoven, ktere pracuji s casovymi radami
library(TTR)
library(zoo)
library(forecast)
library(randtests)
# dalsi uzitecne funkce obsazene primo v knihovne stats

#############################
### Vyhlazeni pomoci exponencialniho vyrovnani

## Jednoduche exponencialni vyhlazovani - vhodne pro lokalne konstantni trend
rain <- scan("http://robjhyndman.com/tsdldata/hurst/precip1.dat",skip=1)
# rocni srazky v Londyne merene v palcich z let 1813 az 1912
rain.ts <- ts(rain, start = c(1813))
plot(rain.ts)
  # aditivni rada s konstantnim trendem

rain.exp <- HoltWinters(rain.ts, beta = FALSE, gamma = FALSE)
  # jednoduche exponencialni vyrovnani
plot(rain.exp)
  # vykresli data i s odhadnutym trendem
rain.exp
  # odhadnuta hodnota parametru alpha
rain.exp$fitted
  # predpovedi, neboli hodnoty trendu
rain.exp$SSE
  # sum of squared errors - soucet druhych mocnin chyb odhadu

# pomoci hodnoty alpha muzeme nastavit miru vyhlazeni
rain.exp2 <- HoltWinters(rain.ts, alpha = 0.01, beta = FALSE, gamma = FALSE)
plot(rain.exp2)
  # cim mensi alpha, tim vetsi vyhlazeni
rain.exp2 <- HoltWinters(rain.ts, alpha = 0.05, beta = FALSE, gamma = FALSE)
plot(rain.exp2)
  # cim vetsi alpha, tim mensi vyhlazeni

## Predpovedi z exponencialniho vyhlazovani
(rain.exp.for <- forecast(rain.exp, h = 10))
  # vypocte 10 predpovedi na budouci uhrny srazek
  # jelikoz se odhaduje konstntni trend, jsou vsechny tyto odhadnute hodnoty stejne
plot(rain.exp.for)
lines(1814:1912, rain.exp$fitted[,1], col = 3)
  # zakresleni predpovedi do grafu
  # modra cara je bodova predpoved, tmave seda plocha 80% interval spolehlivosti
  #   a svetle seda plocha 95% interval spolehlivosti

########################
## Dvojite exponencialni vyhlazovani - vhodne pro lokalne linearni trend

births <- scan("http://robjhyndman.com/tsdldata/data/nybirths.dat")
  # mesicni pocty narozenych v New Yorku od ledna 1946 do prosince 1959
births.ts <- ts(births, frequency=12, start=c(1946,1))
  # prevedeni na casovou radu
plot(births.ts)
  # vykresleni rady

# chceme-li data vyhladit
births.exp <- HoltWinters(births.ts, gamma=FALSE)
  # zobecnene dvojite exponencialni vyrovnani
plot(births.exp)
  # vykresleni odhadnuteho trendu
births.exp
  # odhadnute hodnoty parametru alfa a beta nam rikaji, ze odhady jsou zalozene 
  #   predevsim na nedavnych hodnotach (zavislost nejde daleko do minulosti - 
  #   - relativne vysoke alfa)
# chceme-li hladsi prubeh (vetsi vyhlazeni) volime male alfa
births.exp2 <- HoltWinters(births.ts, alpha=0.1, gamma=FALSE)
plot(births.exp2)
  # prubeh je hladsi, ale nesedi mi na data (je posunuty)
  # pro mala alpha jsem na zacatku rady "mimo"
  births.exp3 <- HoltWinters(births.ts, alpha=0.8, gamma=FALSE)
  plot(births.exp3)
    # kdyz naopak alpha zvetsim, dostanu relativne presny, i kdyz mirne posunuty
    #   odhad, ale nemam vzhlazeno

########################
  
# nechci-li vyhlazovat, ale odhadovat (presneji se trefit),
#   je dobre pouzit pro sezonni data Holt-Wintersovu metodu
births.hw <- HoltWinters(births.ts)
  # podobna myslenka jako u dvojiteho exponencialniho vyhlazeni, 
  #   ale pridam sezonnost
plot(births.hw)
  # vykresleni odhadnuteho trendu
  # na data sedi mnohem lepe 
births.hw
  # vidim i vykyvy pro jenotlive mesice

# hladsi odhady nedostanu ani pro jine volby parametru
births.hw2 <- HoltWinters(births.ts, alpha=0.1)
plot(births.hw2)
  # vzhlayuji trendovou slozku
births.hw3 <- HoltWinters(births.ts, gamma=0.1)
plot(births.hw3)
  # pri odhadu sezonnosti pripoustim vetsi vliv starsich hodnot

# porovnani, jak modely sedi na data
births.exp$SSE
births.exp3$SSE
births.hw$SSE
births.hw2$SSE
births.hw3$SSE
  # Soucet druhych mocnin chyb odhadu - chci co nejmensi

plot(forecast(births.hw, h=24))
  # predpovedi pro 24 mesicu dopredu
  # sezonnost je zachovana

############################
### Multiplikativni model
souvenir <- scan("http://robjhyndman.com/tsdldata/data/fancy.dat")
  # mesicni data o prodeji suvenyru v Queendslandu v Australii od ledna 1987 do prosince 1993
souvenir.ts <- ts(souvenir, frequency=12, start=c(1987,1))	
  # prevedeni na casovou radu
plot(souvenir.ts)
  # vykresleni rady
  # vykyvy se zvetsuji -> multplikativni sezonni rada

# Vyzkousim bezny HoltWintersuv model
souvenir.hw <- HoltWinters(souvenir.ts)
plot(souvenir.hw)
  # vykresleni odhadnuteho trendu
souvenir.hw$SSE
  # nic moc

# Ale existuje i Holt-Wintersova metoda pro multiplikativni rady
souvenir.hwm <- HoltWinters(souvenir.ts, seasonal = "multiplicative")
plot(souvenir.hwm)
  # vykresleni odhadnuteho trendu
souvenir.hwm$SSE
  # vyrazne lepsi (o rad)

# druha moznost je logaritmovat
ln.souvenir.ts <- log(souvenir.ts)
  # logaritmem casto prevedu multiplikativni model na aditivni
  # oduvodneni: logaritmus soucinu rovna se soucet logaritmus
plot(ln.souvenir.ts)

ln.souvenir.exp <- HoltWinters(ln.souvenir.ts)
ln.souvenir.exp
  # nizka hodnota koeficientu alpha ukazuje, ze uroven se meni v zavislosti na 
  #   nedavnych i davnych datech
  # beta = 0 rika, ze sklon trendu se v case nemeni
  # vysoka hodnota gamma rika, ze sezonnost je zalozena na nedavnych/poslednich datech
plot(ln.souvenir.exp)
  # odhad je velmi dobry

########################
## Obecna dekompozice rady se sezonni slozkou 
births.dec <- decompose(births.ts)
plot(births.dec)
  # rada byla rozlozena na trend, sezonni slozku a nahodnou chybu
births.dec$seasonal
  # sezonni slozka
births.dec$trend
  # je mozne odhadnout krivkou logistickeho trendu
(ns <- births.dec$random)
  # nahodna slozka

## test o nevyznamnosti korelaci v nahodne slozce
Box.test(ns, lag=20, type="Ljung-Box")
  # jsou vsechny autokorelace az do casu 20 nevyznamne?
acf(ns,na.action=na.omit)
  # vykresleni autokorelacni funkce s mezemi -> viz priste

#######################
## Testy nahodnosti pro radu typu bily sum
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
cor.test(discoveries, index, method="kendall")
  # test zalozeny na Kandallove korelacnim koeficientu
  # korelacni koeficient pro usporadane promenne
cor.test(discoveries, index, method="spearman")
  # test zalozeny na Spearmanove korelacnim koeficientu
  # test pro spojite promenne zalozeny na poradich
  # oba tyto testy ukazuji mirnou zapornou korelaci (rada klesa),
  #   ktera je na hladine vyznamnosti 5% vyznamna

# dalsi testy
runs.test(discoveries)
  # Wald-Wolfowitz Runs Test (mediánový test)
discoveries - median(discoveries)
  # rada odchylek od medianu
sign(discoveries - median(discoveries))
  # znamenka odchylek
(zn <- sign(discoveries - median(discoveries))[sign(discoveries - median(discoveries))!=0])
  # znamenka s vynechanymi nulami
abs(diff(zn))
  # body, kde se mi meni znamenko
sum(abs(diff(zn)))/2
  # pocet useku se stejnymi znamenky
  # rada se tvari nahodne

# pro zajemce
cox.stuart.test(discoveries)
  # znamenkovy test porovnavajici dve poloviny casove rady proti sobe
bartels.rank.test(discoveries)
  # poradova verze Neumannova podiloveho testu

###############################
### Samostatne

# popiste + odhadnete radu airmiles
  # Passenger Miles on Commercial US Airlines, 1937–1960
plot(airmiles)

airmiles.exp <- HoltWinters(airmiles, beta = FALSE, gamma = FALSE)
plot(airmiles.exp)

airmiles.hw <- HoltWinters(airmiles, gamma = FALSE)
plot(airmiles.hw)

airmiles.exp
airmiles.exp$fitted

(airmiles.exp.for <- forecast(airmiles.exp, h = 10))
  # predpovedi pro 10 let dopredu)
plot(airmiles.exp.for, main = "Forecast of Airmiles", ylab = "Miles", xlab = "Year")
lines(1938:1960, airmiles.exp$fitted[,1], col = 3)  # Plot the fitted values

plot(forecast(airmiles.hw, h = 10))

# popiste + odhadnete radu BJsales
  # Sales Data with Leading Indicator
plot(BJsales)

BJsales.exp <- HoltWinters(BJsales, beta = FALSE, gamma = FALSE)
plot(BJsales.exp)
  # odhadnuty trend
BJsales.exp
BJsales.exp$fitted

(BJsales.exp.for <- forecast(BJsales.exp, h = 10))
plot(BJsales.exp.for, main = "Forecast of BJsales", ylab = "Sales", xlab = "Year")
lines(2:150, BJsales.exp$fitted[,1], col = 3)  # Plot the fitted values

BJsales.hw <- HoltWinters(BJsales, gamma = FALSE)
plot(BJsales.hw)

plot(forecast(BJsales.hw, h = 20))



# popiste + odhadnete radu AirPassengers
  # Monthly Airline Passenger Numbers 1949-1960
plot(AirPassengers)

AirPassengers.hw <- HoltWinters(AirPassengers)
plot(AirPassengers.hw)
  # odhadnuty trend
AirPassengers.hw
AirPassengers.hw$fitted

plot(forecast(AirPassengers.hw, h = 24))
  # predpovedi pro 24 mesicu dopredu)


# popiste + odhadnete radu fdeaths
  # Monthly Deaths from Lung Diseases in the UK
plot(fdeaths)

fdeaths.hw <- HoltWinters(fdeaths, gamma = FALSE)
plot(fdeaths.hw)

fdeaths.hw2 <- HoltWinters(fdeaths)
plot(fdeaths.hw2)

fdeaths.hw
fdeaths.hw$fitted

plot(forecast(fdeaths.hw, h = 24))
plot(forecast(fdeaths.hw2, h = 24))


# je rada LakeHuron nahodna?
  # hladina Huronskeho jezera
plot(LakeHuron)
# je rada lh nahodna?
  # Luteinizing Hormone in Blood Samples
plot(lh)
# je rada nhtemp nahodna?
  # Average Yearly Temperatures in New Haven
plot(nhtemp)
