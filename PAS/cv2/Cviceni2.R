rm(list=ls())
# vycisti pracovni prostor

# Nacteni databaze Cars93
library(MASS)
data(Cars93)
?Cars93
  # databaze 93 vozu prodavanych v USA v roce 1993, ktera se nachazi v knihovne MASS
  # popis promennych najdete v popisu databaze

##########################
### Opakovani z minula

## popisne statistiky pro nominalni (kategorickou neusporadanou) promennou
# jake typy/ tridy vozu byly v nabidce?
typ <- Cars93$Type
unique(typ)
  # jedna se o promennou ordinalni nebo nominalni?
ac<-table(typ)
rc<-prop.table(table(typ))
data.frame(cbind("Absolutni"=ac,"Procenta"=round(rc*100,2)))
  # tabulka cetnosti - co z ni vidite?

barplot(ac,col=2:7,main="Cetnosti trid automobilu",ylab="Absolutni cetnosti",ylim=c(0,max(ac)+2))
x <- barplot(ac,plot=F)[,1]
text(x,ac,labels=ac,pos=3)
popis<-paste(sort(unique(typ)),"(",round(rc*100,2),"%)")
pie(rc,lab=popis,col=2:7,main="Relativni cetnosti studijnich oboru")
  # A co je videt z grafu?

## popisne statistiky pro ordinalni promennou
# popiste, jake mely vozy Airbagy
ab <- Cars93$AirBags
(ac <- table(ab))
(kac<-cumsum(ac))
(rc<-round(prop.table(table(ab)),2))
(krc<-cumsum(rc))
data.frame(cbind("n(i)"=ac,"N(i)"=kac,"f(i)"=rc,"F(i)"=krc))
  # frekvencni rozdeleni - co z nej vidite?

barplot(ac,col=2:4,main="Airbagy v prodavanych vozech",ylab="Absolutni cetnosti",ylim=c(0,max(ac)+3))
x <- barplot(ac,plot=F)[,1]
text(x,ac,labels=ac,pos=3)
popis<-paste(sort(unique(ab)),"(",round(rc*100,2),"%)")
pie(rc,lab=popis,col=2:4,main="Airbagy v prodavanych vozech")
  # A co je videt z grafu?

## popisne statistiky pro ciselnou diskretni promennou
# popiste, kolik mely vozy valcu (Cylinders)
valce <- Cars93$Cylinders
(ac <- table(valce))
  valce2 <- droplevels(valce[valce != "rotary"])
    # zajimaji me jen pocty valcu, ne kategorie "rotary"
(ac<-table(valce2))
(kac<-cumsum(ac))
(rc<-round(prop.table(table(valce2)),2))
(krc<-cumsum(rc))
data.frame(cbind("n(i)"=ac,"N(i)"=kac,"f(i)"=rc,"F(i)"=krc))

# Frekvencni polygon  
x.val<-as.numeric(as.character(names(ac)))
ac.n<-as.numeric(ac)
  # zmena typu promenne kvuli popiskum na y-ove ose v grafu
plot(x.val,ac.n,type="h",lwd=3,col="darkgreen",main="Frekvencni polygon",
     xlab="Pocet valcu",ylab="Absolutni cetnosti")
x.val2<-min(x.val):max(x.val)
ac2<-rep(0,length(x.val2))
for(i in 1:length(x.val2)){
  for(j in 1:length(x.val)){if(x.val2[i]==x.val[j]){ac2[i]<-ac[j]}}
}
lines(x.val2,ac2,col="red")
  # Co graf rika? 

# Nabyva-li ciselna diskretni promenna mnoha hodnot, je mozne ji zobrazit
#   pomoci histogramu
  # napriklad velikost motoru je jiste ciselna diskretni promenna
mot <- Cars93$EngineSize
hist(mot,col="skyblue",border="darkblue",main="Histogram",
     xlab="Velikost motoru",ylab="Absolutni cetnosti")
  # Jak je mozne komentovat vznikly graf? Co vime o tvaru jeho rozdeleni?

## Frekvencni rozdeleni pro ciselne promenne
# spoctete frekvencni rozdeleni pro silu vozu (Horse power)
hp <- Cars93$Horsepower
hist(hp,col="skyblue",border="darkblue",main="Histogram",
     xlab="Sila vozu",ylab="Absolutni cetnosti")
  hist(hp,col="skyblue",border="darkblue",main="Histogram",
     xlab="Sila vozu",ylab="Absolutni cetnosti",breaks=10)
    # pomoci parametru "breaks" je mozne nastavit i jemnejsi deleni, 
    #   ale pro tabulku frekvencniho rozdeleni asi neni treba
hist(hp,plot=F)
deleni<-hist(hp,plot=F)$breaks
popis<-as.character(deleni[-1])
for(i in 1:length(popis)){
  popis[i]<-paste("(",deleni[i],",",deleni[i+1],"]")
}
ac<-hist(hp,plot=F)$counts
kac<-cumsum(ac)
rc<-round(ac/sum(ac),3)
krc<-cumsum(rc)
names(ac) <- popis
data.frame("n(i)"=ac,"N(i)"=kac,"f(i)"=rc,"F(i)"=krc)
  # Co z tabulky vsechno vyctu?

############################
# Krabicovy graf
boxplot(hp,col="yellow",border="orange3",main="Krabicovy graf",
        ylab="Sila vozu")
  # samostatne body ukazuji odlehla pozorovani
  boxplot(hp,col="yellow",border="orange3",main="Krabicovy graf",
        ylab="Sila vozu",range = 3)
    # graf bez odlehlych pozorovani

## Popisne statistiky polohy pro ciselnou promennou   
# Co je v grafu videt
min(hp)
max(hp)
  # extremy
quantile(hp,0.25)
quantile(hp,0.75)
  # kvartily
median(hp)
  # median
fivenum(hp)
  # Jak byste promennou popsali na zaklade tohoto grafu?

mean(hp)
  # prumer
summary(hp)
  # zakladni popisne statistiky polohy
  # Jak lze komentovat tyto popisne statistiky?

## Spoctete frekvencni rozdeleni a nakreslete frekvencni polygon pro 
#   pocet spolucestujicich (promenna Passengers)
pass <- Cars93$Passengers
(ac<-table(pass))
(kac<-cumsum(ac))
(rc<-round(prop.table(table(pass)),2))
(krc<-cumsum(rc))
data.frame(cbind("n(i)"=ac,"N(i)"=kac,"f(i)"=rc,"F(i)"=krc))


# Frekvencni polygon  
x.val<-as.numeric(as.character(names(ac)))
ac.n<-as.numeric(ac)
# zmena typu promenne kvuli popiskum na y-ove ose v grafu
plot(x.val,ac.n,type="h",lwd=3,col="darkgreen",main="Frekvencni polygon",
     xlab="Pocet spolucestujicich",ylab="Absolutni cetnosti")
x.val2<-min(x.val):max(x.val)
ac2<-rep(0,length(x.val2))
for(i in 1:length(x.val2)){
  for(j in 1:length(x.val)){if(x.val2[i]==x.val[j]){ac2[i]<-ac[j]}}
}
lines(x.val2,ac2,col="red")
# Co graf rika? 


## Spoctete popisne statistiky polohy pro delku vozu (promenna Length).
#   Co byste o teto promenne rekli na zaklade histogramu?
#   Porovnejte delku vozu pro americke a neamericke vozy.

c_length <- Cars93$Length
hist(c_length,col="lightgreen",border="darkgreen",main="Histogram délky vozu",
     xlab="Delka vozu",ylab="Absolutni cetnosti")

hist(c_length,col="lightgreen",border="darkgreen",main="Histogram délky vozu",
     xlab="Delka vozu",ylab="Absolutni cetnosti", breaks=20)

summary(c_length)

tapply(Cars93$Length, Cars93$Origin, summary)
boxplot(Cars93$Length, main="Délka vozu (boxplot)", ylab="Delka vozu")
boxplot(Cars93$Length ~ Cars93$Origin, main="Délka vozu podle puvodu", 
        xlab="Puvod", ylab="Delka vozu")

## Porovnejte cenu vozu podle poctu Airbagu.

tapply(Cars93$Price, Cars93$AirBags, summary)
boxplot(Cars93$Price ~ Cars93$AirBags, col="lightblue", border="darkblue", main="Cena vozu podle poctu Airbagu",
        xlab="Pocet Airbagu", ylab="Cena vozu")

hist(Cars93$Price, col="lightblue", border="darkblue", main="Histogram cen vozu",
     xlab="Cena vozu", ylab="Absolutni cetnosti")

#############################
## Popisne statistiky variability
library(DescTools)
  # knihovna s uzitecnymi prikazy na popisne statistiky

# Jaka je variabilita delky vozu
delka <- Cars93$Length
var(delka)
sd(delka)
  # Zakladni charakteristiky variability odvozene od prumeru 
  # Vyberovy rozptyl a smerodatna odchylka
  # Jake maji jednotky, jak je interpretovat?
IQR(delka)
MAD(delka)
  # Robustni charakteristiky variability mene citlive na odlehla pozorovani
  # Mezikvartilove rozpeti a medianova absolutni odchylka okolo medianu
  # Jake maji jednotky, jak je interpretovat?
CoefVar(delka)
  # Variacni koeficient
  # Jake ma jednotky a jak ho interpretovat?

# Standardizovane veliciny - z.skory
z.val<-scale(delka)
  # Jak jsou velke? Co popisuji? K cemu se pouzivaji?

# Caharakteristiky tvaru rozdeleni
Skew(delka)
Kurt(delka)
  # Kolik vysly a co rikaji o tvaru rozdeleni?
  # Porovnat s histogramem?

# Popiste cenu vozu (promenna Price)
# Nakreslete grafy, vypoctete popisne statistiky polohy, variability 
#   a tvaru rozdeleni. Co Vam o datech rikaji?

# Jak popisne statistiky polohy, variability a tvaru rozdeleni reaguji 
#   na posunuti a zmenu meritka?
delka.p<-delka+10
delka.m<-delka*10
  # nove promenne
vyst<-matrix(NA,3,4)
vyst[1,1]<-mean(delka);vyst[1,2]<-sd(delka);vyst[1,3]<-Skew(delka);vyst[1,4]<-Kurt(delka)
vyst[2,1]<-mean(delka.p);vyst[2,2]<-sd(delka.p);vyst[2,3]<-Skew(delka.p);vyst[2,4]<-Kurt(delka.p)
vyst[3,1]<-mean(delka.m);vyst[3,2]<-sd(delka.m);vyst[3,3]<-Skew(delka.m);vyst[3,4]<-Kurt(delka.m)
rownames(vyst)<-c("delka","delka+10","delka*10")
colnames(vyst)<-c("Prumer","Sm.odchylka","Sikmost","Spicatost")
vyst

oldpar <- par(mfrow = c(1,3))
hist(delka,col="lightgreen")
hist(delka.p,col="lightgreen")
hist(delka.m,col="lightgreen")
par <- oldpar
  # tri histogramy