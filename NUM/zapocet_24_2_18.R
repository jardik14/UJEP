rm(list=ls())

Bisekce <- function(f,a,b){
  if(f(a)*f(b) < 0){
    fa <- f(a)
    fb <- f(b)
    repeat{
      c <- (a+b)/2
      if(c == a || c == b) break
      fc <- f(c)
      if(fa*fc < 0){
        b <- c
        fb <- fc
      }else{
        a <- c
        fa <- fc
      }
    }
  }else{
    print("Mas blbe vstup.")
  }
  return(c)
}

GaussPivot <- function(A, b){
  n <- length(b)

  Ab <- cbind(A, b)
  for(k in 1:(n-1)){
    pivot <- which.max(abs(Ab[(k:n), k])) + k - 1
    if(pivot != k){
      j <- k:(n+1)
      pom <- Ab[k, j]
      Ab[k, j] <- Ab[pivot, j]
      Ab[pivot, j] <- pom
    }
    for(i in (k+1):n){
      c <- -Ab[i,k]/Ab[k,k]
      j <- (k+1):(n+1)
      Ab[i, j] <- Ab[i, j] + c*Ab[k, j]
    }
  }

  x <- b
  x[n] <- Ab[n, n+1]/Ab[n, n]
  for(i in (n-1):1){
    j <- (i+1):n
    x[i] <- (Ab[i, n+1] - sum(Ab[i,j]*x[j]))/Ab[i, i]
  }
  return(x)
}


n <- 10
A <- matrix(0, nrow = 10, ncol = 10)
test <- 1
for (i in 1:n) {
  for (j in 1:n) {
    A[i,j] <- cos((i-1)*j) - j
  }
}

y <- c(1:n)
for (i in 1:n) {
  y[i] <- sin(i)
}

x <- GaussPivot(A, y)

Lagrange <- function(t, x, y){
  n <- length(x)
  suma <- 0
  for(i in 1:n){
    nasobic <- 1
    for(j in 1:n){
      if(j != i) nasobic <- nasobic*(t-x[j])/(x[i]-x[j])
    }
    suma <- suma + y[i]*nasobic
  }
  return(suma)
}
a <- min(x)
b <- max(x)
t <- seq(a, b, by=0.001)


plot(x,y, col="red", ylim=c(-10,10))
lines(t, Lagrange(t,x,y), col="blue")

y <- Lagrange(0, x,y)
abline(v=0)
points(0,y,col="green")

