rm(list = ls())

x <- 2
res <- round(sqrt(cos(x + (3/2) * pi)), digits = 3)
print(res)
res <- round(log(2*x^2 + 10, 4), digits = 3)
print(res)
x <- 4
res <- round(sqrt(as.complex(cos(x + (3/2) * pi))), digits = 3)
print(res)
res <- round(log(2*x^2 + 10, 4), digits = 3)
print(res)


text <- "copak zlaTOvláska ale JMELí!"
text <- paste(toupper(substring(text, 1, 1)), tolower(substring(text, 2)), sep = "")
print(text)

pole1 <- c(1, 2, 3)
pole2 <- c(3, 4, 5)

#skalarni soucin
res <- sum(pole1 * pole2)
print(res)

#vzdalenost bodu v 3D prostoru
res <- sqrt(sum((pole1 - pole2)^2))
print(res)

vektor <- 0:10
vektor <- vektor/10*2-1
print(vektor)

rozsah <- -10:10
rozsah <- rozsah[rozsah %% 2 == 0 & rozsah >= 0 
                 | rozsah %% 2 == 1 & rozsah < 0]
print(rozsah)

text <- "Well, there's egg and bacon; egg sausage and bacon; egg and spam;
egg bacon and spam; egg bacon sausage and spam; spam bacon sausage and spam;
spam egg spam spam bacon and spam;
spam sausage spam spam bacon spam tomato and spam;"

text_faktory <- factor(scan(text = text, what = " "))
print(summary(text_faktory))

A <- matrix(c(-1, 1, -1, 1, -2, 1, 1, -3, 1, 2, -3, 1, 2, 3, 4, -1), 
            nrow=4,ncol=4,byrow = TRUE)
b <- c(0,0,0,0)
res <- solve(A, b)
print(res)

A <- matrix(c(4,2,2,4,6,8,-2,2,4), nrow=3, ncol=3, byrow = TRUE)
B <- matrix(c(sum(A[1,]*A[,1]), 0,0,0, sum(A[2,]*A[,2]), 0,0,0, sum(A[3,]*A[,3])), nrow=3, ncol=3, byrow = TRUE)
print(B)

res <- A %*% B
print(res)

res[res < 0] <- abs(res[res < 0])
print(res)






