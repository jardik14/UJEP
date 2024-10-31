Lagrange <- function(t,x,y) {
  n <-  length(x)
  suma <- 0
  for (i in 1:n) {
    product <- 1
    for (j in 1:n) {
      if (j != i) {
        product <- product * (t - x[j]) / (x[i] - x[j])
      }
    }
    suma <- suma + y[i] * product
  }
  return(suma)
}

Vandermonde <- function(x,y) {
  n <- length(x)
  A <- matrix(1, n, n)
  for (j in 2:n) {
    A[,j] <- A[,j-1] * x
  }
  return(solve(A,y))
}

Horner <- function(x, coef) {
  n <- length(coef)
  res <- coef[n]
  for (i in (n-1):1) {
    res <- res * x + coef[i]
  }
  return(res)
}

NewtonPolCoef <- function(x,y) {
  n <- length(x)
  coef <- numeric(n)
  coef[1] <- y[1]
  if (n > 1) {
    for (i in 2:n) {
      suma <- 0
      produkt <- 1
      for (j in 1:(i-1)) {
        suma <- suma + coef[j] * produkt
        produkt <- produkt * (x[i] - x[j])
        
      }
      coef[i] <- (y[i]-suma)/produkt
      
    }
  }
  return (coef)
}

NewtonPolValue <- function(t, x, coef) {
  n <- length(coef)
  res <- coef[n]
  for (i in (n-1):1) {
    res <- res * (t - x[i]) + coef[i]
  }
  return(res)
}

n <- 5
x <- runif(n)
y <- runif(n)

plot(x,y, col="red", ylim=c(-1,1))
t <- seq(0,1,0.001)
lines(t, Lagrange(t,x,y), col="blue")
lines(t, Horner(t, Vandermonde(x,y)), col="green")
lines(t, NewtonPolValue(t, x, NewtonPolCoef(x,y)), col="black")











