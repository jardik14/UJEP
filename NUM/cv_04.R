rm(list = ls())
setwd("D:/Programko/UJEP/NUM")

# Metoda nejmenších čtverců
phi <- function(x) {
  return(c(1, x, x*x))
}
coef <- function(x, y, phi) {
  M <- sapply(x, phi) 
  A <- M %*% t(M)
  b <- c(M %*% y)
  return(solve(A, b))
  
}

x <- seq(0,2*pi,0.1)
y <- sin(x)

a <- coef(x, y, phi)

xs <- seq(0,2*pi,0.001)

plot(x, y)
lines(xs, a %*% sapply(xs, phi), col = "red")

# ----------------------------------------------

x <- seq(0,2*pi,0.01)
y <- sin(x) + 0.2*sin(16*x) + 0.1*sin(32*x)

phi <- function(x) {
  return(c(sin(x), sin(16*x)))
}
     
a <- coef(x, y, phi)

xs <- seq(0,2*pi,0.0001)
plot(x, y)
lines(xs, a %*% sapply(xs, phi), col = "red")

# ----------------------------------------------

x <- seq(1,2,0.01)
y <- 1/(x*x-0.2*x+0.01) + rnorm(length(x), 0, 0.03)
plot(x, y)

phi <- function(x) {
  return(c(1, x, x*x))
}

a <- coef(x, 1/y, phi)

xs <- seq(1,2,0.001)
plot(x, y)
lines(xs, 1/(a %*% sapply(xs, phi)), col = "red")
