rm(list=ls())


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

p <- function(v) {return(8*0.89/(3*v-1)-3/(v*v))}



n <- Bisekce(
  function(x){
a <- Bisekce(function(v) p(v)-0.6,0.5,0.8)
b <- Bisekce(function(v) p(v)-0.6,2,10)
return(MidPointRuleRichardson(function(v) p(v)-x,a,b,8))
}, 0.6, 0.62)
print(n)
v <- seq(0.5,3,0.01)
plot(v,p(v), type = "l", xlim = c(0.5,3), ylim = c(0,1.6))
abline(n,0,col="red")
