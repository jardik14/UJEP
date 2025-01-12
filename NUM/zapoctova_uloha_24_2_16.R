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

MidPointRule <- function(f, a, b, n = 1){
  h <- (b-a)/n
  return(h*sum(f(a+h*(1:n)-h*0.5)))
}
MidPointRuleRichardson <- function(f, a, b, n = 1){
  res <- sapply(2^(0:(n-1)), function(n) MidPointRule(f, a, b, n))
  if(n > 1){
    for(i in 1:(n-1)){
      m <- n-i+1
      power <- 4^i
      res <- (power*res[2:m]-res[1:(m-1)])/(power-1)
    }
  }
  return(res)
}


MidPointRuleRichardson(function(alpha) MidPointRuleRichardson(function(x) exp(-alpha*x)*sin(x), 0, 2*pi, 20),0 , 10, 20)
# nevyřešeno

