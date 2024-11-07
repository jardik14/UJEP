rm(list = ls())
setwd("D:/Programko/UJEP/NUM")

ExpTaylor <- function(x, n=1) {
  term <- rep(1, length(x))
  res <- term
  if (n>1) {
    for (i in 1:n) {
      term <- term * x/i
      res <- res + term
    }
  }
  return(res)
}

x <- seq(-3, 3, by=0.001)
plot(exp, xlim=c(-3,3), lwd=8, col="red")
for (i in 1:5) {
  lines(x, ExpTaylor(x, i), lwd=2, col=i)
}

# --------------------------------------------
FirstDerA <- function(f, x, h) {
  return(function(x) (f(x+h) - f(x))/h)
}
FirstDerB <- function(f, x, h) {
  return(function(x) (f(x+h) - f(x-h))/(2*h))
}
SecondDer <- function(f, x, h) {
  return(function(x) (f(x+h) - 2*f(x) + f(x-h))/(h^2))
}

a <- 0
b <- 2*pi
plot(cos, xlim=c(a,b), lwd=4, col="red")
h <- 0.000000005
plot(function(x) FirstDerA(sin, x, h)(x), xlim=c(a,b), lwd=2, col="blue", add=TRUE)

h <- 0.00000005
plot(function(x) FirstDerA(sin, x, h)(x)-cos(x), xlim=c(a,b), lwd=2, col="blue")
plot(function(x) FirstDerB(sin, x, h)(x)-cos(x), xlim=c(a,b), lwd=2, col="red", add=TRUE)
h <- 0.000000005
plot(function(x) FirstDerA(sin, x, h)(x)-cos(x), xlim=c(a,b), lwd=2, col="blue")
plot(function(x) FirstDerB(sin, x, h)(x)-cos(x), xlim=c(a,b), lwd=2, col="red", add=TRUE)
h <- 0.0000000005
plot(function(x) FirstDerA(sin, x, h)(x)-cos(x), xlim=c(a,b), lwd=2, col="blue")
plot(function(x) FirstDerB(sin, x, h)(x)-cos(x), xlim=c(a,b), lwd=2, col="red", add=TRUE)

h <- 0.00000005
plot(function(x) -sin(x), xlim=c(a,b), lwd=4, col="red")
plot(function(x) SecondDer(sin, x, h)(x), xlim=c(a,b), lwd=2, col="blue", add=TRUE)

# --------------------------------------------
MidPointRule <- function(f, a, b, n=1) {
  h <- (b-a)/n
  return (h*sum(f(h*(1:n)+a-h/2)))
}

a <- 0
b <- pi
cat("Exact solution int_a^b sin(x)", cos(a)-cos(b), "\n")
for(i in 1:20) {
  cat("MidPointRule with n=", 2^i, ":", MidPointRule(sin, a, b, 2^i), "\n")
}

# --------------------------------------------
SimpsonRule <- function(f, a, b, n=1) {
  h <- (b-a)/n
  h_half <- h/2
  suma <- f(a) + f(b)
  x_even <- h*(1:n)+a-h_half
  suma <- suma + 4*sum(f(x_even))
  x_odd <- h*(1:(n-1))+a
  suma <- suma + 2*sum(f(x_odd))
  return(suma*h/6)
}

a <- 0
b <- pi
cat("Exact solution int_a^b sin(x)", cos(a)-cos(b), "\n")
for(i in 1:20) {
  cat("SimpsonRule with n=", 2^i, ":", SimpsonRule(sin, a, b, 2^i), "\n")
}
