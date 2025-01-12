#############################
### Priklady na pravdepodobnost

### Diskretni rozdeleni
## Binomicke rozdeleni: n - pocet pokusu, p - pst uspechu
#   pocet uspechu v n-pokusech
# pbinom(k,n,p) - distribucni funkce
# dbinom(k,n,p) - pravdepodobnostni funcke
# stredni hodnota n*p
# rozptyl n*p*(1-p)

## Uloha 15 (taham 10,alespon 7 žen)
p <- 0.5076
1 - pbinom(6,10,p)

## Hypergeometricke rozdeleni: w - pocet bilych kouli v osudi, b - pocet cernych kouli v osudi
#   n - pocet kouli tazenych z osudi
#   pocet bilych kouli mezi n tazenymi
# phyper(k,w,b,n) - distribucni funkce
# dhyper(k,w,b,n) - pravdepodobnostni funcke
# stredni hodnota n*w/(w+b)
# rozptyl (n*w/(w+b))*(1-w/(w+b))*((w+b-n)/(w+b-1))

## Uloha 19

dhyper(3,6,43,6)

## Geometricke rozdeleni: p - pravdepodobnost uspechu
# cekani na prvni uspech, do prikazu se zadava pocet neuspechu pred prvnim uspechem
# pgeom(k,p) - distribucni funkce
# dgeom(k,p) - pravdepodobnostni funcke
# stredni hodnota (1-p)/p
# rozptyl (1-p)/p^2

## Uloha 15 (p že první žena bude 4. pokus)
p <- 0.5076
dgeom(3,p)

## Poissonovo rozdeleni: lambda - stredni hodnota
# pocet udalosti
# ppois(k,lambda) - distribucni funkce
# dpois(k,lambda) - pravdepodobnostni funcke
# stredni hodnota lambda
# rozptyl lambda

## Uloha 20

# a)
1 - ppois(2,9)

# b)
dpois(0,1)

#################################
### Spojita rozdeleni
## Normalni rozdeleni: mu - stredni hodnota, sigma - smerodatna odchylka
# pnorm(x,mu,sigma) - distribucni funkce
# qnorm(x,mu,sigma) - kvantilova funkce

## Uloha S6

# a) P(X > 18)
 1 - pnorm(18,23,5)

# b) P(8 < X < 22)
pnorm(22,23,5) - pnorm(8,23,5)

# c) P(X < x) = 0,95
qnorm(0.95,23,5)

# d) P(X > x) = 0,75
qnorm(0.25,23,5)

# e)
qnorm(0.025, 23, 5)
qnorm(0.975, 23, 5)

## Uloha 14
mu <- 0
# sigma <- ?
# a) stanovte smerodatnou odchylku, aby P{|X| ≤ 5} = 0.95

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

## Lognormalni rozdeleni: mu , sigma (velicina ln(X) ~ N(mu, sigma^2))
# plnorm(x,mu,sigma) - distribucni funkce
# qlnorm(x,mu,sigma) - kvantilova funkce
# stredni hodnota exp(mu+sigma^2/2)
# rozptyl (exp(sigma^2)+2)*exp(2*mu+sigma^2)

## Uloha S9

mu <- 5
sigma <- 1
# a) P(X < 100)
plnorm(100,mu,sigma)

# b) P(50 < X < 100)
plnorm(100,mu,sigma) - plnorm(50,mu,sigma)

## Uloha S10
mu <- 7
sigma <- 3
1 - plnorm(20000, mu, sigma)

## Exponencialni rozdeleni: int - intenzita
# pexp(x,int) - distribucni funkce
# qexp(x,int) - kvantilova funkce
# distribucni funkce P(X <= t) = 1 - exp(-int*t)
# stredni hodnota 1/int
# rozptyl 1/int^2

## Uloha S13
mu <- 2000
int <- 1/mu

# a) P(X > 3000)
1 - pexp(3000,int)

# b) P(X < 2000)
pexp(2000,int)

# c) P(X < x) = 0,05
qexp(0.05,int)

#################################
### Centralni limitni veta
## Rozdeleni souctu nezavislych, stejne rozdelenych nahodnych velicina
#  konverguje k normalnimu pro pocet techto velicin rostouci nade vsechny meze.

library(TeachingDemos)
clt.examp(1)
clt.examp(2)
clt.examp(5)
clt.examp(10)
clt.examp(50)

################################
### Nactete data Policie.RData

load("D:/Programko/UJEP/PAS/cv6/Policie.RData")

### Testovani hypotez
# Pred testem musime stanovit
#   testovane hypotezy: nulovou (H0) a alternativni (H1)
#   hladinu vyznamnosti (nejcasteji alfa = 0.05)
# Vyhodnoceni pomoci p-hodnoty
#   p-hodnota <= alfa => H0 zamitame, plati H1
#   p-hodnota > alfa => H0 nezamitame

## Pomoci jednovyberoveho t-testu na hladine vyznamnosti 5% rozhodnete,
#   zda prumerna vyska policistu muze byt 180 cm.

# H0: vyska = 180 cm vs. H1: vyska <> 180 cm
vyska <- Policie$height
t.test(vyska, mu=180)
  # p-hodnota 0.0965 > 0.05 => nezamitame H0
  # Neprokazalo se, ze prumerna vyska policistu se lisi od 180 cm.
  #   Muze byt 180 cm.

## Pomoci jednovyberoveho t-testu na hladine vyznamnosti 5% rozhodnete,
#   zda prumerna hmotnost policistu muze byt 75 kg.
hmotnost <- Policie$weight
t.test(hmotnost,mu=75)


## Pomoci jednovyberoveho t-testu na hladine vyznamnosti 5% rozhodnete,
#   zda prumerna hmotnost policistu je mensi nez 80 kg.

#####################
### Interval spolehlivosti pro prumer
# a jeho spojitost s jednovyberovym t-testem

## Spoctete 95% interval spolehlivosti pro prumer vysky kdyz vite, 
#  ze rozptyl vysky dospelych muzu je 49.
vyska <- Policie$height

# Rucni vypocet
mn <- mean(vyska)
sd <- sqrt(49)
n <- length(vyska)
alpha <- 0.05
q.n <- qnorm(1-alpha/2)

# Dolni mez
mn-q.n*sd/sqrt(n)
# Horni mez
mn+q.n*sd/sqrt(n)

# vypocet pomoci funkce v knihovne DescTools
MeanCI(prom2,sd=sd)

# a kdyby mi skutecny rozptyl nikdo nerekl?
# Rucni vypocet
mn <- mean(vyska)
sd <- sd(vyska)
n <- length(vyska)
alpha <- 0.05
q.t <- qt(1-alpha/2,n-1)

# Dolni mez
mn-q.t*sd/sqrt(n)
# Horni mez
mn+q.t*sd/sqrt(n)

# vypocet pomoci funkce v knihovne DescTools
MeanCI(vyska)
  # dostavam sirsi interval nez predtim, proc?
# spojitost s jednovyberovym t-testem
# interval spolehlivosti je soucasti vystupu z jednovyberoveho t-testu
t.test(vyska, mu = 0)
  # na zaklade intervalu spolehlivosti rozhodnete, zda prumerna vyska muzu
  #   muze byt 175 cm, 177 cm, 181 cm

## Spoctete 99%-ni interval spolehlivosti pro stredni hodnotu reakcni doby,
#  kdyz vim, ze rozptyl je 0.015 a kdyz nevim nic.
MeanCI( , conf.level=0.99)

###################################
## A jak spocitat interval spolehlivosti pro stredni hodnotu reakcni doby 
#  pomoci bootstrapu?
reakce <- Policie$react

boots <- list()
B <- 10000
for(i in 1:B) boots[[i]] <- sample(reakce,replace=TRUE)
  # bootstrapove vybery
means <- unlist(lapply(boots,mean))
  # bootstrapove prumery

hist(means,col="honeydew2",xlab="reakcni doba",
     main="Histogram bootstrapovych prumeru")
abline(v=mean(reakce),lwd=3,col="navy")
abline(v=quantile(means,probs=c(0.025,0.975)),lwd=3,col="red")
c(mean=mean(reakce),quantile(means,probs=c(0.025,0.975)))
  # bootstrapovy interval spolehlivosti

# Pomoci funkce
MeanCI(reakce,method="boot")
BootCI(reakce,FUN = mean)
  # pomoci parametru FUN mohu pocitat interval spolehlivosti pro libovolnou funkci
decil <- function(x) quantile(x,0.1)  
BootCI(prom3,FUN = decil)
  # bootstrapovy interval spolehlivosti pro dolni decil
