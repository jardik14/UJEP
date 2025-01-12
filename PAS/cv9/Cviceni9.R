# Potrebne knihovny
library(fitdistrplus)
library(DescTools)

# Nactete databazi Stulong.RData
load("D:/Programko/UJEP/PAS/cv4/Stulong.RData")
names(Stulong)<-c("ID","vyska","vaha","syst1","syst2","chlst","vino","cukr","bmi",
                  "vek","KOURrisk","Skupina","VekK")

###########################
### Odhad rozdeleni

## Jake rozdeleni ma cholesterol? 
chol <- Stulong$chlst
hist(chol,col="azure", border="darkblue", main="Histogram pro hladinu cholesterolu", xlab="Cholesterol")
PlotQQ(chol, pch=19)
Skew(chol)
Kurt(chol)

# Pomer sikmosti a spicatosti, k jakemu rozdeleni mam nejblize
descdist(chol ,discrete=FALSE, boot=1000)

# zkusim normalni, logisticke a lognormalni
(fit1 <- fitdist(chol,"norm"))
(fit2 <- fitdist(chol,"logis"))
(fit3 <- fitdist(chol,"lnorm"))

# porovnani pomoci AIC a BIC kriterii
data.frame(distr=c("Norm","Logis","Lognorm"),
           AIC=c(fit1$aic,fit2$aic,fit3$aic),
           BIC=c(fit1$bic,fit2$bic,fit3$bic)
)
  # nejnizsi hodnoty AIC i BIC ma lognormalni rozdeleni

# 95%-ni intervaly spolehlivosti pro odhady parametru lognormalniho rozdeleni
data.frame(estimate=coef(fit3),
           ci0.95lo=coef(fit3)-1.96*fit3$sd,
           ci0.95up=coef(fit3)+1.96*fit3$sd
)

# kontrola, jak jednotlivym rozdelenim sedi Q-Q plot
PlotQQ(chol)
PlotQQ(chol, qdist=function(p) qlogis(p,location=coef(fit2)[1],scale=coef(fit2)[2]))
PlotQQ(chol, qdist=function(p) qlnorm(p,meanlog=coef(fit3)[1],sdlog=coef(fit3)[2]))
  # lognormalni rozdeleni sedi nejlepe

## Jakym rozdelenim se ridi systolicky tlak 1 (syst1)?
syst <- Stulong$syst1
hist(syst,col="azure", border="darkblue", main="Histogram pro systolicky tlak", xlab="Systolicky tlak")
PlotQQ(syst, pch=19)
Skew(syst)
Kurt(syst)

descdist(syst ,discrete=FALSE, boot=1000)

(fit1 <- fitdist(syst,"norm"))
(fit2 <- fitdist(syst,"logis"))
(fit3 <- fitdist(syst,"lnorm"))
(fit4 <- fitdist(syst,"gamma"))
(fit5 <- fitdist(syst,"weibull"))
(fit6 <- fitdist(syst,"unif"))
(fit7 <- fitdist(syst,"exp"))


data.frame(distr=c("Norm","Logis","Lognorm","Gamma","Weibull","Uniform","Exponential"),
           AIC=c(fit1$aic,fit2$aic,fit3$aic,fit4$aic,fit5$aic,fit6$aic,fit7$aic),
           BIC=c(fit1$bic,fit2$bic,fit3$bic,fit4$bic,fit5$bic,fit6$bic,fit7$bic)
)


PlotQQ(syst)
PlotQQ(syst, qdist=function(p) qlogis(p,location=coef(fit2)[1],scale=coef(fit2)[2]))
PlotQQ(syst, qdist=function(p) qlnorm(p,meanlog=coef(fit3)[1],sdlog=coef(fit3)[2]))
## Jakym rozdelenim se ridi cukr?
cukr <- Stulong$cukr
hist(cukr,col="azure", border="darkblue", main="Histogram pro hladinu cukru", xlab="Cukr")
PlotQQ(cukr, pch=19)
Skew(cukr)
Kurt(cukr)

descdist(cukr ,discrete=FALSE, boot=1000)

(fit1 <- fitdist(cukr,"norm"))
(fit2 <- fitdist(cukr,"logis"))
(fit3 <- fitdist(cukr,"unif"))
(fit4 <- fitdist(cukr,"exp"))


data.frame(distr=c("Norm","Logis","Uniform","Exponential"),
           AIC=c(fit1$aic,fit2$aic,fit3$aic,fit4$aic),
           BIC=c(fit1$bic,fit2$bic,fit3$bic,fit4$bic)
)


PlotQQ(cukr)
PlotQQ(cukr, qdist=function(p) qlogis(p,location=coef(fit2)[1],scale=coef(fit2)[2]))
PlotQQ(cukr, qdist=function(p) qexp(p,rate=coef(fit7)[1])) 
  # nejlepe sedi exponencialni rozdeleni

######################
### Interval spolehlivosti

# Nactete data mtcars z vestavene knihovny R-ka
data(mtcars)
?mtcars

### Interval spolehlivosti pro stredni hodnotu (prumer)
## Spoctete 95% interval spolehlivosti pro prumernou spotrebu (promenna mpg).
mpg <- mtcars$mpg
hist(mpg)

# Rucni vypocet
mn <- mean(mpg)
sd <- sd(mpg)
n <- length(mpg)
alpha <- 0.05
q.t <- qt(1-alpha/2,n-1)

# Dolni mez
mn - q.t*sd/sqrt(n)
# Horni mez
mn + q.t*sd/sqrt(n)

# v knihovne DescTools existuje jednoducha funkce pro vypocet
MeanCI(mpg)

## Vypoctete 90% interval spolehlivosti pro spotrebu, kdyz vite, ze rozptyl teto promenne je 36.
# pri rucnim vypoctu je treba pouzit kvantil normalniho rozdeleni
sd <- sqrt(36)
alpha <- 0.1
q.n <- qnorm(1-alpha/2)
  # kvantil normalniho rozdeleni je mensi nez kvantil t-rozdeleni, proc?

# Dolni mez
mn - q.n*sd/sqrt(n)
# Horni mez
mn + q.n*sd/sqrt(n)

# vypocet pomoci funkce v knihovne DescTools
MeanCI(mpg, sd=6, conf.level = 0.9)

## Spoctete a INTERPRETUJTE 99%-ni interval spolehlivosti pro silu vozu (promenna hp).
hp <- mtcars$hp

mn <- mean(hp)
sd <- sd(hp)
n <- length(hp)
alpha <- 0.01
q.t <- qt(1-alpha/2,n-1)

# Dolni mez
mn - q.t*sd/sqrt(n)
# Horni mez
mn + q.t*sd/sqrt(n)

MeanCI(hp, conf.level = 0.99)


## A jak spocitat interval spolehlivosti pro silu vozu
#  pomoci bootstrapu?
hp <- mtcars$hp

boots <- list()
B <- 10000
for(i in 1:B) boots[[i]] <- sample(hp, replace=TRUE)
  # bootstrapove vybery
means <- unlist(lapply(boots, mean))
  # bootstrapove prumery

hist(means,col="honeydew2",xlab="Horsepower",
     main="Histogram bootstrapovych prumeru")
abline(v=mean(hp),lwd=3,col="navy")
abline(v=quantile(means,probs=c(0.005,0.995)), lwd=3, col="red")
c(mean=mean(hp), quantile(means,probs=c(0.005,0.995)))
  # bootstrapovy interval spolehlivosti

# Pomoci funkce
MeanCI(hp, method="boot", conf.level = 0.99)
BootCI(hp, FUN = mean, conf.level = 0.99)
  # pomoci parametru FUN mohu pocitat interval spolehlivosti pro libovolnou funkci
  decil <- function(x) quantile(x,0.1)  
  BootCI(prom3,FUN = decil)
    # bootstrapovy interval spolehlivosti pro dolni decil
  
#################################
### Interval spolehlivosti pro rozdil prumeru
  
## Lisi se od sebe prumerne hodnoty spotreby v zavislosti na typu prevodovky (promenna am)?
# Vypoctete 95% interval spolehlivosti pro rozdil prumeru.
am <- mtcars$am
tapply(mpg, am, mean)
MeanDiffCI(mpg ~ am)

  # druhy zpusob je pres dvouvyberovy t-test pro ruzne rozptyly
  t.test(mpg ~ am)

# Co tento interval znamena 
#   Se spolehlivosti 95% se skutecny rozdil dvojice prumeru nachazi
#   v itntervalu od -11.280194 do -3.209684
# Lisi se tedy spotreba podle typu prevodovky?
#   Interval neobsahuje nulu, ano lisi se.
  
## Lisi se od sebe rychlost vozu (promenna qsec) podle typu motoru (promenna vs).
qsec <- mtcars$qsec
vs <- mtcars$vs

tapply(qsec, vs, mean)
MeanDiffCI(qsec ~ vs)

  # druhy zpusob je pres dvouvyberovy t-test pro ruzne rozptyly
  t.test(qsec ~ vs)
## Lisi se od sebe vaha voyu (promenna wt) podle typu prevodovky?
  
###############################
### Interval spolehlivosti pro pravdepodobnost (podil)
  
## Spoctete 95% interval splehlivosti pro podil voyu s automatickou prevodovkou.
am <- mtcars$am
table(am)  
  # hodnota 0 znaci automatickou prevodovku
prop.table(table(am))
  # odhad podilu vozu s automatickou prevodovkou

# rucni vypocet
p <- prop.table(table(am))[1]
n <- length(am)
alpha <- 0.05
q.n <- qnorm(1-alpha/2)

# dolni mez
p - q.n*sqrt(p*(1-p)/n)
# horni mez
p + q.n*sqrt(p*(1-p)/n)

# vypocet pomoc funkce z balicku DescTools
BinomCI(table(am)[1], n, method ="wald")

## Vypoctete 90% interval spolehlivosti pto motor ve tvaru V (promenna vs).
# hodnota 0 je pro motor ve tvaru V

#################################
### Interval spolehlivosti pro rozdil podilu

## A je rozdil v tomto podilu podle typu motoru?
vs <- mtcars$vs
(tab <- table(am, vs))

# vypocet 
BinomDiffCI(x1 = tab[1,1], n1 = tab[1,1] + tab[1+2], x2 = tab[2,1], n2 = tab[2,1] + tab[2+2], method ="wald")

## Spoctete 99% interval spolehlivosti pro rozdil podilu autometickych prevodovek
#   mezi vozy se ctyrmi valci a vozi se sesti valci (promenna cyl).
