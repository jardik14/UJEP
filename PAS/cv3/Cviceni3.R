rm(list=ls())
# vycisti pracovni prostor

# Nacteni databaze Policie.RData
#   vysledky testu na rychlost reakce spolu s fyziologickymi udaji
setwd("D:/Programko/UJEP/PAS/cv3")
load("Policie.RData")

# aktivace knihovny s popisnymi statistikami
library(DescTools)

##########################
### Opakovai z minula

## Popisne statistiky polohy
# Vyzkousejte na promenne vaha (weight)

vaha <- Policie$weight
summary(vaha)
boxplot(vaha,main="Krabicovy graf vahy policistu", ylab="Vaha v kg", col="wheat",border="tan4")
hist(vaha, main="Histogram vahy policistu", xlab="Vaha v kg", ylab="Pocty",col="palegreen", border="darkgreen")
  # co mohu o promenne rici?

##########################
## Popisne statistiky variability

# Jaka je variabilita promenne vaha?
var(vaha)
sd(vaha)
  # Zakladni charakteristiky variability odvozene od prumeru 
  # Vyberovy rozptyl a smerodatna odchylka
  # Jake maji jednotky, jak je interpretovat?
  prop.table(table(vaha>(mean(vaha)-sd(vaha)) & vaha<(mean(vaha)+sd(vaha))))
    # hodnoty v intervalu prumer plus/minus smerodatna odchylka
IQR(vaha)
MAD(vaha)
  # Robustni charakteristiky variability mene citlive na odlehla pozorovani
  # Mezikvartilove rozpeti a medianova absolutni odchylka okolo medianu
  # Jake maji jednotky, jak je interpretovat?
CoefVar(vaha)
  # Variacni koeficient
  # Jake ma jednotky a jak ho interpretovat?

## Porovnejte variabilitu pulsu a diastolickeho tlaku
puls <- Policie$pulse
tlak <- Policie$diast
var(puls);var(tlak)
sd(puls);sd(tlak)
IQR(puls);IQR(tlak)
MAD(puls);MAD(tlak)
CoefVar(puls);CoefVar(tlak)


##########################
## Popisne statistiky tvaru rozdeleni

# stale pro promennou vaha
# charakteristiky tvaru rozdeleni se pocitaji z standardizovanych velicin
z.vaha<-scale(vaha)
  # z-skory
  # Jak jsou velke? Co popisuji? K cemu se pouzivaji?
  mean(z.vaha);sd(z.vaha)

# Charakteristiky tvaru rozdeleni
Skew(vaha)
  # sikmost - prumer ze tretich mocnin z-skoru
vyska <- Policie$height
Kurt(vyska)
  # spicatost - prumer ze ctvrtych mocnin z-skoru minus 3
  # Kolik vysly a co rikaji o tvaru rozdeleni?
  # Porovnat s histogramem?

## Spoctete charakteristiky tvaru rozdeleni promenne react (reakcni doba).
#   Co byste rekli o jejim tvaru rozdeleni (histogramu)?
reakce <- Policie$react
Skew(reakce)
Kurt(reakce)
hist(reakce, main="Histogram reakce policistu", xlab="reakce v sekundách", ylab="Pocty",col="blue", border="black")
## Nakreslete histogram promenne fat. Odhadnete z nej popisne statistiky. 
tuk <- Policie$fat
hist(tuk)
## Spoctete vsechny popisne statistiky vysky policistu a komentujte je
#   Co z nich plyne pro grafy?
summary(vyska)
sd(vyska)
IQR(vyska)
Skew(vyska)
Kurt(vyska)

boxplot(vyska,main="Krabicovy graf vysky policistu", ylab="Vyska v cm", col="pink",border="red", outline = F)
hist(vyska, main="Histogram vysky policistu", xlab="vyska v cm", ylab="Pocty",col="red", border="black")
##########################
## Jak popisne statistiky polohy, variability a tvaru rozdeleni reaguji 
#   na posunuti a zmenu meritka?
vaha.p<-vaha+10
vaha.m<-vaha*10
  # nove promenne
vyst<-matrix(NA,3,4)
vyst[1,1]<-mean(vaha);vyst[1,2]<-sd(vaha);vyst[1,3]<-Skew(vaha);vyst[1,4]<-Kurt(vaha)
vyst[2,1]<-mean(vaha.p);vyst[2,2]<-sd(vaha.p);vyst[2,3]<-Skew(vaha.p);vyst[2,4]<-Kurt(vaha.p)
vyst[3,1]<-mean(vaha.m);vyst[3,2]<-sd(vaha.m);vyst[3,3]<-Skew(vaha.m);vyst[3,4]<-Kurt(vaha.m)
rownames(vyst)<-c("vaha","vaha+10","vaha*10")
colnames(vyst)<-c("Prumer","Sm.odchylka","Sikmost","Spicatost")
vyst

oldpar <- par(mfrow = c(1,3))
hist(vaha,col="lightgreen")
hist(vaha.p,col="lightgreen")
hist(vaha.m,col="lightgreen")
par(oldpar)
  # tri histogramy
  
#######################
## Vypocet modusu pro ciselna data
# Nejprve mmusime urcit, kolik vrcholu (modu) promenna ma - z histogramu

# Zkuste pro vysku policistu
vyska <- Policie$height
hist(vyska,col="skyblue",border="darkblue",main="Histogram",
     xlab="Vyska policistu",ylab="Absolutni cetnosti")
  # Promenna ma jeden vrchol (modus) a lezi mezi hodnotami 60 a 70

# Pro promennou ciselnou spojitou se modus hleda z jadroveho odhadu hustoty
jadro <- density(vyska)
  # vytvoreni jadroveho odhadu
# zakreslenido grafu
hist(vyska,col="skyblue",border="darkblue",main="Histogram",
     xlab="Vyska policistu",ylab="Absolutni cetnosti",freq=F)
  # nakresleni histogramu s "hustotou" y-ove ose
lines(jadro)
  # prikresleni jadroveho odhadu do grafu
# kde ma jadrovy odhad vrchol?
jadro$x[which.max(jadro$y)]
  # hledam takovou souradnici na x-ove ose, aby na te y-ove bylo maximum

## Najdete modus(y) pro reakcni dobu
## Najdete modus(y) pro vahu
  # pres zmenu parametru bandwith (bw) muzete menit miru vyhlazeni hustoty
jadro <- density(reakce)
hist(reakce,col="skyblue",border="darkblue",main="Histogram",
     xlab="Reakce policistu",ylab="Absolutni cetnosti",freq=F)
lines(jadro)
jadro$x[which.max(jadro$y)]

jadro <- density(vaha)
hist(vaha,col="skyblue",border="darkblue",main="Histogram",
     xlab="Vaha policistu",ylab="Absolutni cetnosti",freq=F, breaks = 5)
lines(jadro)
jadro$x[which.max(jadro$y)]

## Pro ciselnou diskretni se modus hleda z nejvyssiho sloupce
# Vypocet pro puls
  # podle vzorce Modus = A + h * d0/(d0+d1)
puls <- Policie$pulse
hist(puls,col="skyblue",border="darkblue",main="Histogram",
     xlab="Puls policistu",ylab="Absolutni cetnosti")
# Modus je v intervalu 60-70, tedy
A <- 60
h <- 10
hist(puls,plot=F)
cetnosti<-hist(puls,plot=F)$counts
d0<-cetnosti[3]-cetnosti[2]
d1<-cetnosti[3]-cetnosti[4]
(modus <- A + h*d0/(d0+d1))

# Vypoctete modus pro diastolicky tlak

###########################
## Odlehla pozorovani
# Jak je to s odlehlym pozorovanim u procenta tuku?
tuk <- Policie$fat
boxplot(tuk,col="yellow",border="orange3",main="Krabicovy graf",
        ylab="Procento tuku policistu")
  # Krabicovy graf znazornil jedno odlehle pozorovani.
  # Je to ale skutecne odlehle pozorovani?
  # klasicka definice odlehleho pozorovani funguje jen pro symetricka data
Skew(tuk)
hist(tuk,col="skyblue",border="darkblue",main="Histogram",
     xlab="Procento tuku policistu",ylab="Absolutni cetnosti")
  # sesikmeni je zrejme, ale neni kriticke
  # pozorovani muzeme, nebo nemusime povazovat za odlehle
# Zvysime-li hranici pro odlehle pozorovani na 3 IQR
boxplot(tuk,col="yellow",border="orange3",main="Krabicovy graf",
        ylab="Procento tuku policistu",range=3)
  # uz se jako odlehle nezobrazi

# Jak je to s odlehlym pozorovanim u diastolickeho tlaku?
#   kde jsou hranice odlehlosti?
