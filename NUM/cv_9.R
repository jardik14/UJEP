rm(list=ls())

g <- function(x){return(0.5*(x+2/x))}

x <- seq(0,3,0.01)

plot(x,g(x),type="l",col="blue", ylim=c(0,3), xlim=c(0,3))
abline(0,1,col="red")

x <- 0.5
for(i in 1:10){
  y <- g(x)
  segments(x,x,x,y,lwd=2,col="black")
  segments(x,y,y,y,lwd=2,col="black")
  x <- y
}

plot(cos, xlim=c(0,pi/2), col="blue", type="l")
abline(0,1,col="red")

x <- 0.1
for(i in 1:10){
  y <- cos(x)
  segments(x,x,x,y,lwd=2,col="black")
  segments(x,y,y,y,lwd=2,col="black")
  x <- y
}

g <- function(x){return(2*log(x+2))}
x <- seq(0,10,0.01)
plot(x,g(x),type="l",col="blue", ylim=c(0,5), xlim=c(0,5))
abline(0,1,col="red")

x <- 0.1
for(i in 1:10){
  y <- g(x)
  segments(x,x,x,y,lwd=2,col="black")
  segments(x,y,y,y,lwd=2,col="black")
  x <- y
}



f <- function(y) {
  dS <- beta*y[1]*y[2]
  dI <- nu*y[2]
  return(c(-dS,dS-dI,dI))
}

g <- function(h, f, y0) {
  y1 <- y0 + h*f(y0)
  y1 <- y0 + h*(f(y0) + f(y1))/2
  y1 <- y0 + h*(f(y0) + f(y1))/2
  y1 <- y0 + h*(f(y0) + f(y1))/2
  y1 <- y0 + h*(f(y0) + f(y1))/2
  return(y1)
}

nrow <- 5000
ncol <- 3
SIR <- matrix(0,nrow,ncol)
SIR[1,] <- c(999,1,0)
beta <- 0.01
nu <- 1
h <- 0.001
for(i in 2:nrow){
  SIR[i,] <- g(h,f,SIR[i-1,])
}
i <- 1:nrow
plot(i, SIR[,1], ylim=c(0,1000), col="blue")
points(i, SIR[,2], col="red")
points(i, SIR[,3], col="green")



f <- function(y) {
  return(c(y[1]*(r-a*y[2]), y[2]*(-s+b*y[1])))
}

g <- function(h, f, y0) {
  y1 <- y0 + h*f(y0)
  y1 <- y0 + h*(f(y0) + f(y1))/2
  y1 <- y0 + h*(f(y0) + f(y1))/2
  y1 <- y0 + h*(f(y0) + f(y1))/2
  y1 <- y0 + h*(f(y0) + f(y1))/2
  return(y1)
}

nrow <- 5000
ncol <- 2
LV <- matrix(0,nrow,ncol)
LV[1,] <- c(10,10)
r <- 1.2
s <- 1.0
a <- 0.01
b <- 0.015

h <- 0.005
for(i in 2:nrow){
  LV[i,] <- g(h,f,LV[i-1,])
}
i <- 1:nrow
plot(i, LV[,1], ylim=c(0,20), col="blue")
points(i, LV[,2], col="red")
legend("topright", legend=c("Prey","Predator"), col=c("blue","red"), lty=1:1)
plot(LV[,1], LV[,2])