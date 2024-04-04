rm(list = ls())

# Fibonacci vector
fib <- function(n) {
  for (i in 1:n) {
    if (i == 1) {
      fib <- 0
    } else if (i == 2) {
      fib <- c(fib, 1)
    } else {
      fib <- c(fib, fib[i-1] + fib[i-2])
    }
  }
  return(fib)
}

print(fib(10))


# Reseni kvadraticke rovnice
qadr <- function(a, b, c) {
  D <- b^2 - 4*a*c
  if (D > 0) {
    x1 <- (-b + sqrt(D)) / (2*a)
    x2 <- (-b - sqrt(D)) / (2*a)
    return(c(x1, x2))
  } else if (D == 0) {
    x <- -b / (2*a)
    return(c(x, NA))
  } else {
    return(c(NA, NA))
  }

}

print(qadr(1, -3, 2))
print(qadr(1, -2, 1))
print(qadr(1, 1, 1))



tabulka <- iris
print(str(tabulka))

# Stredni hodnoty
print(apply(tabulka[1:4], 2, mean))

# Smerodatne odchylky
print(apply(tabulka[1:4], 2, sd))

# Unique species
print(unique(tabulka$Species))

# Tabulka z HTML
library(rvest)

html_content <- read_html(url("https://ki.ujep.cz/cs/historie/"))

tabulky <- html_table(html_content, header = TRUE)

tbl <- tabulky[[2]]

res <- tbl[tbl$`Dosud na UJEP?` == "ANO", ]
print(res)

tabulky <- append(tabulky, list(res))

library(writexl)

write_xlsx(tabulky,"tabulky.xlsx")


