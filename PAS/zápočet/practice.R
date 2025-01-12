rm(list=ls())

## Diskrétna náhodná premenná

# Priklad 1
# a)
n <- 4
k <- 3
p <- 0.85
dbinom(k,n,p)
# b)
k <- 3
w <- 850
b <- 150
n <- 4
dhyper(k,w,b,n)

# Priklad 3
k <- 3
p <- 0.65
dgeom(k,p)

# Priklad 4
p <- 0.2
# a)
k <- 5
dgeom(k,p)
# b)
k <- 4
1 - pgeom(k,p)
# c)
k <- 4
pgeom(k,p)
# d)
pgeom(5,p) - pgeom(1,p)

# Priklad 5
k <- 15
w <- 35
b <- 15
n <- 20
dhyper(k,w,b,n)

# Priklad 6
# a)
k <- 5 
lambda <- 5
dpois(k,lambda)
# b)
1 - ppois(4, lambda)

# Priklad 7
# a)
n <- 100
p <- 0.035
1 - pbinom(1, n, p)
# b)
pbinom(5,n,p) - pbinom(2,n,p)

# Priklad 8
# a)
n <- 20
p <- 0.02
dbinom(2,n,p)
# b)
dbinom(0,n,p)
# c)
pbinom(2,n,p)

# Priklad 9
k <- 5
n <- 500
p <- 0.01
pbinom(k,n,p)
496*700-4*10000

# Priklad 10
k <- 34
n <- 100
p <- 0.25
1 - pbinom(k,n,p)

# Priklad 11
# a)
n <- 400
p <- 0.005
1 - pbinom(0,n,p)
# b)
1 - pbinom(4,n,p)

# Priklad 13
first <- c(1,3,5,7,9,11,13,15,17,19)
p <- 1/6
sum <- 0
for (i in first) {
  sum <- sum + dgeom(i,p) 
}
print(sum)
