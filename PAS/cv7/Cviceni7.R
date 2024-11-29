rm(list=ls())

### Testovani hypotez
# Pred testem musime stanovit
#   testovane hypotezy: nulovou (H0) a alternativni (H1)
#   hladinu vyznamnosti (nejcasteji alfa = 0.05)
# Vyhodnoceni pomoci p-hodnoty
#   p-hodnota <= alfa => H0 zamitame, plati H1
#   p-hodnota > alfa => H0 nezamitame

### Chi-kvadrat test nezavislosti dvou kategorickych promennych

## Souvisi spolu barva vlasu a pohlavi?
# testovane hypotezy
#   H0: barva vlasu a pohlavi spolu nesouvisi
#   H1: barva vlasu a pohlavi spolu souvisi
(tab <- HairEyeColor[,1,])
  # tabulka absolutnich cetnosti

# prikaz pro vypocet chi-kvadrat testu je chisq.test
chisq.test(tab)
  # zakladni volani testu
  # test porovnava pozorovane a ocekavane cetnosti
chisq.test(tab)$obs
chisq.test(tab)$exp
  # predpokladem chi-kvadrat testu je, ze vsechny ocekavane cetnosti jsou vetsi nez 5

# neni-li splnen predpoklad, pouziva se Fisheruv exaktni test
fisher.test(tab)
  # p-hodnota testu vysla 0.9174 > alfa => nezamitame H0
  # souvislost mezi barvou vlasu a pohlavim se neprokazala

## Souvisi spolu barva vlasu a barvaoci u muzu?
(tab <- HairEyeColor[,,1])

chisq.test(tab)

chisq.test(tab)$obs
chisq.test(tab)$exp

fisher.test(tab)


## Souvisi spolu pocet valu a pocet rychlosti u osobnich vozu?
?mtcars
data("mtcars")
valce <- mtcars$cyl
rychlosti <- mtcars$gear
  # nacteni dat

(tab <- table(valce,rychlosti))

chisq.test(tab)

fisher.test(tab)

plot(as.factor(valce),as.factor(rychlosti), main="Souvislost počtu válců a počtu rychlostí", xlab="Počet válců", ylab="Počet rychlostí")

# vstupem do chi-kvadrat testu muse byt tabulka absolutnich cetnosti, nebo primo dvojice promennych

## Souvisi spolu typ prevodovky a pocet rychlosti?
prevod <- mtcars$am
rychlosti <- mtcars$gear

(tab <- table(prevod,rychlosti))

chisq.test(tab)

fisher.test(tab)

plot(as.factor(prevod),as.factor(rychlosti), main="Souvislost typu převodovky a počtu rychlostí", xlab="Typ převodovky", ylab="Počet rychlostí")
###############################
## Příklad 8

# Pri kontrole účtovných dokladov sa počas posledných rokov nachádzalo stabilne zhruba 2 % účtov
# s formálnymi nedostatkami. Ak audítor vyberie náhodne 20 účtovných dokladov, aká je
# pravdepodobnosť, že: a) budú práve dva chybné, b) ani jeden nebude chybný, c) maximálne dva budú
# chybné?

# a) budou práve dva chybné
dbinom(2,20,0.02)

# b) ani jeden nebude chybný
dbinom(0,20,0.02)

# c) maximálne dva budou chybné
sum(dbinom(0:2,20,0.02))
pbinom(2,20,0.02)


## Příklad 16 

# Divízia má 25 pracovníkov, z ktorých sú 15 za spísanie petície za zmenu pravidiel pre prácu nadčas,
# zvyšní sú proti. Pre spísanie petície je potrebná nadpolovičná väčšina hlasov. Do novokoncipovaného
# celodivízného výboru je náhodne vybraných 5 členov, ktorí majú na programe rokovania aj
# rozhodovať o vypísaní, resp. nevypísaní uvedenej petičnej akcie. S akou pravdepodobnosťou bude
# hlasovanie v celodivíznom výbore v prospech petície? (0.6988)

sum(dhyper(3:5,15,10,5))
1 - phyper(2,15,10,5)

plot(0:5,dhyper(0:5,15,10,5),type="s",main="Hypergeometrické rozdělení",xlab="Počet zastánců petice",ylab="Pravděpodobnost")


## Příklad 4

# Pravdepodobnosť chyby pri prenose jedného bitu je 0.20. Jednotlivé prenosy sú navzájom nezávislé.
# Pri prvej chybe prenos končí. Určite pravdepodobnosť, že
# a) bude prenesených práve 5 bitov,
# b) bude prenesených aspoň 5 bitov,
# c) budú prenesené najviac 4 bity,
# d) bude prenesených najmenej 2 a najviac 5 bitov.

# a) bude prenesených práve 5 bitov
dgeom(5,0.2)

# b) bude prenesených aspoň 5 bitov
1 - pgeom(4,0.2)

# c) budou prenesené najviac 4 bity
pgeom(4,0.2)

# d) bude prenesených najmenej 2 a najviac 5 bitov
pgeom(5,0.2) - pgeom(1,0.2)


## Příklad 6

# Realitný maklér jedná v priemere s 5 zákazníkmi za deň. Aká je pravdepodobnosť, že počet
# zákazníkov makléra za jeden deň a) bude práve 5, b) bude väčší ako 4.

# a) bude práve 5
dpois(5,5)

# b) bude větší než 4
1 - ppois(4,5)


## Příklad 10

# Kvôli chorobe vymeškal študent 2 týždne z vyučovania. V deň, keď sa vrátil do školy, učiteľ rozdal
# študentom 100-otázkový test vždy so štyrmi možnosťami odpovedí, z ktorých jedna bola správna.
# Keďže študent látku vôbec nepoznal, odpovede vyberal náhodne. Na vyhovenie z testu mal odpovedať
# správne aspoň na 35 zo 100 otázok. Určte pravdepodobnosť, že študent vyhovel z testu.

1- pbinom(34,100,0.25)


## Příklad 18

# Podnik poskytujúci v typickej zimnej obci v čase od 21.00 h večer do 7.00 h ráno opravy kúrenia
# obdrží v priemere každé dve hodiny jednu telefonickú objednávku. Náklady na prevádzku tohto
# zariadenia sú pokryté, keď za noc obdrží aspoň tri objednávky. Vypočítajte pravdepodobnosť, že tieto
# náklady budú pokryté.

1 - ppois(2,5)


## Příklad S2

# Istá firma sa rozhodla podrobiť svojich zamestnancov IQ testu. Priemerný výsledok IQ testu bol 115,
# disperzia 256. Predpokladajme, že hodnoty IQ testu možno spoľahlivo opísať Gaussovým rozdelením.
# Určte pravdepodobnosť, že hodnota IQ testu pri náhodne vybranom zamestnancovi nadobudne
# hodnoty: a) menšie alebo rovné ako 120, b) väčšie ako 105, c) v rozpätí 100 a 130.

# a) menší nebo rovno 120
smerodatna_odchylka <- sqrt(256)
pnorm(120,115,smerodatna_odchylka)

###############################
### Vypocty pravdepodobnosti

### Diskretni rozdeleni
## Binomicke rozdeleni: n - pocet pokusu, p - pst uspechu
# pbinom(k,n,p) - distribucni funkce
# dbinom(k,n,p) - pravdepodobnostni funcke

## Hypergeometricke rozdeleni: w - pocet bilych kouli v osudi, b - pocet cernych kouli v osudi
#   n - pocet kouli tazenych z osudi
# phyper(k,w,b,n) - distribucni funkce
# dhyper(k,w,b,n) - pravdepodobnostni funcke

## Geometricke rozdeleni: p - pravdepodobnost uspechu
# pgeom(k,p) - distribucni funkce
# dgeom(k,p) - pravdepodobnostni funcke

## Poissonovo rozdeleni: lambda - stredni hodnota
# ppois(k,lambda) - distribucni funkce
# dpois(k,lambda) - pravdepodobnostni funcke

### Spojita rozdeleni
## Normalni rozdeleni: mu - stredni hodnota, sigma - smerodatna odchylka
# pnorm(x,mu,sigma) - distribucni funkce
# qnorm(p,mu, sigma) - kvantilova funkce

# hustota - vyska dospelych muzu
curve(dnorm(x,180,7),from=150,to=210, main="Hustota N(180, 49)",col="red",ylab="Hustota")
# distribucni funkce - vyska dospelych muzu
curve(pnorm(x,180,7),from=150,to=210, main="Distribucni funkce N(180, 49)",col="purple",ylab="Hustota")
# pravdepodobnost, ze nahodne vybrany muz bude mensi nez 170 cm
oldpar <- par(mfrow=c(1,2))
curve(dnorm(x,180,7),from=150,to=210, main="Hustota N(180, 49)")
lines(c(0,170),c(0,0),lwd=3,col="green") 
xx <- seq(150,170,length.out=101)
polygon(c(150,xx,170),c(0,dnorm(xx,180,7),0),col="green")
# umime-li zmerit velikost zelene plochy, mame pst :)

curve(pnorm(x,180,7),from=150,to=210, main="Distr. fce N(180, 49)")
lines(c(170,170),c(0,pnorm(170,180,7)),col="green",lty=2,lwd=2)
lines(c(0,170),c(pnorm(170,180,7),pnorm(170,180,7)),col="green",lty=2,lwd=2)
# hodnotu lze vycist z distribucni funkce
par(oldpar)


## Lognormalni rozdeleni: mu - stredni hodnota, sigma - smerodatna odchylka
# plnorm(x,mu,sigma) - distribucni funkce
# qlnorm(p,mu,sigma) - kvantilova funkce

## Exponencialni rozdeleni: int - intenzita
# pexp(x,int) - distribucni funkce
# qexp(p,int) - kvantilova funkce
