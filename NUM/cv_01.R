rm(list = ls())
setwd("D:/Programko/UJEP/NUM")

# matrix with random numbers 4x4
n <- 4
A <- matrix(rnorm(n*n), nrow = n, ncol = n)
# A[1,1] <- 0

# solving with in-built function
b <- runif(n)
x <- solve(A, b)
print(x)

Gauss <- function(A, b){
  n <- length(b)
  # forward elimination
  Ab <- cbind(A, b)
  for(k in 1:(n-1)){
    for(i in (k+1):n){
      c <- -Ab[i,k]/Ab[k,k]
      j <- (k):(n+1)
      Ab[i, j] <- Ab[i, j] + c*Ab[k, j]
    }
  }
  # back substitution
  x <- b
  x[n] <- Ab[n, n+1]/Ab[n, n]
  for(i in (n-1):1) {
    j <- (i+1):n
    x[i] <- (Ab[i, n+1] - sum(Ab[i, j] * x[j]))/Ab[i, i]
    
  }
  return(x)
}

GaussPivot <- function(A, b){
  n <- length(b)
  
  # forward elimination
  Ab <- cbind(A, b)
  for(k in 1:(n-1)){
    # pivot
    pivot <- which.max(abs(Ab[k:n, k]))
    pivot <- pivot + k - 1 # index shift
    if(pivot != k){
      j <- k:(n+1)
      tmp <- Ab[k, j]
      Ab[k, j] <- Ab[pivot, j]
      Ab[pivot, j] <- tmp
    }
    for(i in (k+1):n){
      c <- -Ab[i,k]/Ab[k,k]
      j <- (k):(n+1)
      Ab[i, j] <- Ab[i, j] + c*Ab[k, j]
    }
  }
  
  # back substitution
  x <- b
  x[n] <- Ab[n, n+1]/Ab[n, n]
  for(i in (n-1):1) {
    j <- (i+1):n
    x[i] <- (Ab[i, n+1] - sum(Ab[i, j] * x[j]))/Ab[i, i]
    
  }
  return(x)
}

print(Gauss(A, b))
print(GaussPivot(A, b))


GaussLU <- function(A){
  n <- nrow(A)
  for(k in 1:(n-1)){
    for(i in (k+1):n){
      c <- -A[i,k]/A[k,k]
      j <- (k+1):n
      A[i, k] <- -c
      A[i, j] <- A[i, j] + c*A[k, j]
    }
  }
  return(A)
}

LU <- GaussLU(A)
L <- LU
U <- LU
L[upper.tri(L)] <- 0
diag(L) <- 1
U[lower.tri(U)] <- 0

