rm(list = ls())
setwd("D:/Programko/UJEP/ZZD")
data <- read.csv("shootings.csv")

library(DT)
library(dplyr)
library(ggplot2)
library(tidyverse)

data$date <- as.Date(data$date)

# V tabulce nalezněte 5 států, kde nejčastěji dochází ke střelbě při policejních zásazích.

table1 <- data %>% 
  group_by(state) %>% 
  summarise(count = n()) %>% 
  arrange(desc(count)) %>%
  head(5)

print(datatable(table1))

# Pro každý z těchto států vytvořte sloupcový graf popisující počet zastřelených osob v jednotlivých letech.

table2 <- data 
table2["year"] <- format(table2$date, format="%Y")
table2 <- table2 %>% 
  filter(state %in% table1$state) %>%
  group_by(year, state) %>%
  summarise(count = n())

print(datatable(table2))



graph <-  table2 %>% 
  ggplot(aes(x = year, y = count, fill = state)) +
  geom_col() +
  facet_wrap(~state, scales = "free_y") +
  xlab("Rok") + ylab("Počet") + ggtitle("Počet zastřelených osob v jednotlivých letech")

print(graph)

# Jakými nejabsurdnějšími zbraněmi byli zněškodnění útočníci ozbrojeni? 
# Vypište 10 nejméně zastoupených hodnot z celého původního datasetu.

table3 <- data %>% 
  group_by(armed) %>% 
  summarise(count = n()) %>% 
  arrange(count) %>%
  head(10)

print(datatable(table3))

# Do koláčového grafu vyneste četnost útočníků ozbrojených těmito zbraněmi:
#   toy weapon
#   ax
#   crossbow
#   machete
#   gun

graph2 <- data %>% 
  filter(armed %in% c("toy weapon", "ax", "crossbow", "machete", "gun")) %>%
  group_by(armed) %>% 
  summarise(count = n()) %>%
  ggplot(aes(x = "", y = count, fill = armed)) +
  geom_bar(stat = "identity") +
  coord_polar("y") +
  ggtitle("Poměr útočníků ozbrojených různými zbraněmi")+
  theme_void()

print(graph2)


table4 <- data %>% 
  group_by(age, gender) %>%
  summarise(count = n())
  
graph3 <- table4 %>% 
  ggplot(aes(x = age, y = count, fill = gender)) +
  geom_col() +
  xlab("Věk") + ylab("Počet") + ggtitle("Počet útočníků podle věku a pohlaví")
print(graph3)


