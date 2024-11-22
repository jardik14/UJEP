rm(list=ls())

f <- function(x) {
  return(x*x*x-cos(x))
}

fd <- function(x) {
  return(3*x*x+sin(x))
}

f <- function(x) {
  return(x*x-2)
}

fd <- function(x) {
  return(2*x)
}

fdd <- function(x) {
  return(2)
}


Horner <- function(a, x) {
  n <- length(a)
  y <- a[n]
  yd <- y
  for (i in (n-1):2) {
    y <- y*x + a[i]
    yd <- yd*x + y
  }
  y <- y*x + a[1]
  return(c(y, yd))
}
a <- rev(c(2,-7,5,-2,11))
x <- 3
print(Horner(a, x))

NewtonRoot <- function(f, fd, x0, acc=1e-6) {
  x <- x0
  citac <- 0
  repeat {
    citac <- citac + 1
    dx <- f(x)/fd(x)
    x <- x - dx
    if (abs(dx) < acc) {
      print(citac)
      return(x)
    }
  }
}

NewtonRootVarB <- function(f, x0, acc=1e-6) {
  x <- x0
  h <- acc
  citac <- 0
  repeat {
    citac <- citac + 1
    dx <- h*f(x)/(f(x+h)-f(x))
    x <- x - dx
    if (abs(dx) < acc) {
      print(citac)
      return(x)
    }
  }
}

NewtonRootVarC <- function(f, x0, acc=1e-6) {
  x <- x0
  citac <- 0
    repeat {
      citac <- citac + 1
      y <- f(x)
      dx <- y*y/(f(x+y)-y)
      x <- x - dx
      if (abs(dx) < acc) {
        print(citac)
        return(x)
      }
    }
}

NewtonRootVarD <- function(f, fd, fdd, x0, acc=1e-6) {
  x <- x0
  citac <- 0
  repeat {
    citac <- citac + 1
    y <- f(x)
    yd <- fd(x)
    dx <- 2*y*yd/(2*yd*yd-y*fdd(x))
    x <- x - dx
    if (abs(dx) < acc) {
      print(citac)
      return(x)
    }
  }
}

HalleySquareRoot <- function(a, acc=1e-6) {
  x <- a
  citac <- 0
  repeat {
    citac <- citac + 1
    xx <- x*x
    dx <- (xx-a)*2*x/(3*xx+a)
    x <- x - dx
    if (abs(dx) < acc) {
      print(citac)
      return(x)
    }
  }
}

NewtonHorner <- function(a, x0, acc=1e-6) {
  x <- x0
  citac <- 0
  repeat {
    citac <- citac + 1
    dx <- a[1]
    for (i in 2:length(a)) {
      dx <- dx*x + a[i]
    }
    x <- x - dx
    if (abs(dx) < acc) {
      print(citac)
      return(x)
    }
  }
}

acc <- 1e-15

options(digits=20)
print(sqrt(2))
x0 <- 10
print(NewtonRoot(f, fd, x0, acc))
print(NewtonRootVarB(f, x0, acc))
print(NewtonRootVarC(f, x0, acc))
print(NewtonRootVarD(f, fd, fdd, x0, acc))
print(HalleySquareRoot(2, acc))

