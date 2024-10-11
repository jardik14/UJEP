rm(list = ls())
setwd("D:/Programko/UJEP/NUM")

n <- 4
A <- matrix(runif(n*n), nrow = n)
diag(A) <- diag(A)*100
b <- runif(n)

# Gauss-Seidel method (bez vektorizace)
x <- numeric(n)
for(i in 1:20) {
  for(i in 1:n) {
    soucet <- 0
    for(j in 1:n) {
      if(j != i) {
        soucet <- soucet + A[i,j] * x[j]
      }
    }
    x[i] <- (b[i] - soucet) / A[i,i]
    
  }
}

# Gauss-Seidel method (s vektorizací)
GaussSeidel <- function(A, b) {
  n <- length(b)
  x <- numeric(n)
  repeat {
    for(i in 1:n) {
      x[i] <- (b[i] - sum(A[i,]*x) + A[i,i]*x[i]) / A[i,i]
    }
    if(sum(abs(A %*% x - b)) < 1e-10) {
      return(x)m
    }
  }
}


# Jacobi method (s vektorizací)


x0 <- numeric(n)
for(i in 1:200) {
  for(i in 1:n) {
    x[i] <- (b[i]-sum(A[i,]*x0)+A[i,i]*x0[i])/A[i,i]
  }
  x0 <- x
}


n <- 10
a <- runif(n)
b <- runif(n-1)
c <- runif(n-1)
d <- runif(n)

u <- a
y <- d
for(i in 2:n){
  coef <- b[i-1]/u[i-1]
  u[i] <- a[i] - coef*c[i-1]
  y[i] <- d[i] - coef*y[i-1]
}
x <- y
x[n] <- y[n]/u[n]
for(i in (n-1):1){
  x[i] <- (y[i] - c[i]*x[i+1])/u[i]
}


