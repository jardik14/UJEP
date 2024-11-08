rm(list=ls())


f <- function(t,X) {
  return(c(X[2], -X[1]-0.1*X[2]))
}

Euler <- function(x, y, f, h) {
  return(y + h*f(x,y))
}

# Runge-Kutta 2
RK2 <- function(x, y, f, h) {
  h_half <- h/2
  return(y + h*(f(x,y) + f(x+h_half, y+h_half*f(x,y)))/2)
}

# Runge-Kutta 4
RK4 <- function(x, y, f, h) {
  h_half <- h/2
  h_sixth <- h/6
  k1 <- f(x,y)
  k2 <- f(x+h_half, y+h_half*k1)
  k3 <- f(x+h_half, y+h_half*k2)
  k4 <- f(x+h, y+h*k3)
  return(y + h_sixth*(k1 + 2*k2 + 2*k3 + k4))
}


tMAX <- 100
n <- 1000
h <- tMAX/n
t <- seq(0, tMAX, by=h)
n <- n+1
X <- matrix(0, nrow=n, ncol=2)
X[1,1] <- 100
X[1,2] <- 0

for (i in 2:n) {
  X[i,] <- Euler(t, X[i-1,], f, h)
}

plot(t, X[,1], type="l", col="red", xlab="t", ylab="x(t)")


Xrk2 <- X
for (i in 2:n) {
  Xrk2[i,] <- RK2(t, Xrk2[i-1,], f, h)
}
lines(t, Xrk2[,1], type="l", col="blue")


Xrk4 <- X
for (i in 2:n) {
  Xrk4[i,] <- RK4(t, Xrk4[i-1,], f, h)
}
lines(t, Xrk4[,1], type="l", col="black")

# analytical solution
lines(t, 100*exp(-0.1*t/2)*cos(t), col="green", add=TRUE)


