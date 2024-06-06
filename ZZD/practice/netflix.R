rm(list = ls())
setwd("D:/Programko/UJEP/ZZD/practice")
data <- read.csv("netflix_titles.csv")

library(DT)
library(dplyr)
library(ggplot2)

# remove last 13 columns

data <- data[,apply(data, 2, function(x) { sum(!is.na(x)) > 0 })]

# movies released eych year

table1 <- data %>% filter(type == "Movie") %>% group_by(release_year) %>% summarise(count = n())

plot1 <- ggplot(table1, aes(x = release_year, y = count)) + geom_col() + labs(title = "Number of movies released by year", x = "Year", y = "Number of movies")

print(datatable(table1))
print(plot1)

# movies by country

table2 <- data %>% 
  filter(type == "Movie") %>% 
  group_by(country) 

table2$country <- gsub(",.*", "", table2$country)

# group by country but United States and India are distinct and all other countries are grouped as "Other"

table2 <- table2 %>% 
  summarise(count = n()) %>% 
  mutate(country = ifelse(country == "United States", "United States", ifelse(country == "India", "India", "Other")))

plot2 <- ggplot(table2, aes(x = "", y = count, fill = country)) + geom_col() + coord_polar("y") + labs(title = "Number of movies by country", x = "", y = "Number of movies")

print(datatable(table2))
print(plot2)

# movies by length (create intervals by 10 minutes)

table3 <- data %>% filter(type == "Movie")

table3$duration <- as.numeric(gsub(" min", "", table3$duration))

table3$duration <- cut(table3$duration, breaks = seq(0, 300, by = 30))

table3 <- table3 %>% group_by(duration) %>% summarise(count = n())

plot3 <- ggplot(table3, aes(x = duration, y = count)) + geom_col() + labs(title = "Number of movies by length", x = "Length", y = "Number of movies")

print(datatable(table3))
print(plot3)


