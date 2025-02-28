rm(list=ls())
setwd("D:/Programko/UJEP/PAS/zápočet")
load("cars.RData")

# 1. -------------------

engsize <- cars$EngineSize

hist(engsize, main="Histogram pro proměnnou EngineSize", xlab="Velikost motoru v litrech", ylab="Hustota",freq=F)
jadro <- density(engsize)
lines(jadro)
curve(dnorm(x,mean(engsize),sd(engsize)),from=min(engsize),to=max(engsize), add=T,col=2)


# 2. -------------------
drive <- cars$DriveTrain
table(drive)
rear_count <- 16
total <- 10+67+16

prop.test(rear_count, total, conf.level = 0.9, correct = FALSE)


# 3. -------------------
rpm <- cars$RPM
type <- cars$Type

oneway.test(rpm ~ type, var.equal = TRUE)


# 4. ------------------
price <- cars$Price
power <- cars$Horsepower

plot(price ~ power, main="Bodový graf proměnných Price a Horsepower", xlab="Počet koní", ylab="Cena")
model <- lm(price ~ power)
abline(model, col=2)
summary(model)



## Pravděpodobnostní rozdělení

# 1.
k <- 14
n <- 25
p <- 0.4
1 - pbinom(k,n,p)


# 2.
k <- 2
w <- 18
b <- 12
n <- 5
dhyper(k,w,b,n)

# 3. 
mu <- 10
sigma <- 2
pnorm(8,mu,sigma)

# 4. 
mu <- 2
int <- 1/mu
pexp(3,int) - pexp(1,int)
