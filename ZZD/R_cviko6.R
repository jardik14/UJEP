rm(list = ls())
setwd("D:/Programko/UJEP/ZZD")
data <- read.csv("catalog.csv")

# Zjistěte celkový počet sesuvů půdy v jednotlivých letech
library(DT)
library(dplyr)
library(ggplot2)
library(tidyverse)

data$date <- as.Date(data$date, format = "%m/%d/%y")

table1 <- data %>% group_by(year = format(data$date, format="%Y")) %>% summarise(count = n())
table1 <- na.omit(table1)
print(datatable(table1))

# Do grafu vyneste hodnotu kumulativního součtu celkového počtu sesuvů půdy dle 
# let (počet událostí postupně sčítejte a pro každý rok vyneste dílčí součet). 
# Pro výpočet lze použít funkci cumsum()

table1["cumsum"] <- cumsum(table1$count)

print(datatable(table1))

cumsum_year_plot <- ggplot(table1, aes(x = year, y = cumsum)) + geom_point() + geom_line(aes(group=1)) + labs(title = "Kumulativní součet sesuvů půdy dle let", x = "Rok", y = "Počet sesuvů půdy")
print(cumsum_year_plot)

# Z původní tabulky vypočtěte průměrný počet sesuvů půdy ve spojených státech 
# v jednotlivých měsících (průměrováno přes všechny roky v tabulce). 
# Výsledek vykreslete do grafu.

table2 <- data %>%
  filter(country_name == "United States") %>%
  drop_na(date) %>%
  group_by(month = format(date, format="%m")) %>%
  summarise(mean = mean(1:length(month)))
print(datatable(table2, rownames = FALSE))

avg_month_plot <- ggplot(table2, aes(x = month, y = mean)) + geom_point() + geom_line(aes(group=1)) + labs(title = "Průměrný počet sesuvů půdy ve spojených státech v jednotlivých měsících", x = "Měsíc", y = "Průměrný počet sesuvů půdy")
print(avg_month_plot)


# Spočítejte průměrný počet sesuvů půdy za rok, pro každý stát v tabulce.
table3 <- data
table3["year"] <- format(data$date, format="%Y")
table3 <- table3 %>%
  group_by(country_name, year) %>%
  summarise(count = n())
table3 <- table3 %>%
  group_by(country_name) %>%
  summarise(mean = mean(count))

print(datatable(table3))


# Výsledné hodnoty vykreslete pomocí knihovny sf jako barvu státu na mapě. 
# Pro získání tabulky s mapou světa a její vykreslení můžete použít následující kód. 
# Funkce geom_sf() vykreslí polygony s hranicemi států z tabulky world. 
# Jednotlivé polygony se chovají podobně jako sloupcový graf. 
# **Tabulku world je nutné vhodným způsobem spojit s vaší tabulkou z předchozího úkolu.1
library(rnaturalearth)
library(sf)

# add country codes to table3 from data table
table3 <- merge(table3, data, by.x = "country_name", by.y = "country_name", all.x = TRUE)
world <- ne_countries(scale = "medium", returnclass = "sf")
table <- merge(world, table3, by.x = "iso_a2", by.y = "country_code", all.x = TRUE)
table <- table %>% filter(continent == "North America" | continent == "South America")
table <- table %>% replace_na(list(mean = 0))
plot <- ggplot(table) + geom_sf(aes(fill = mean)) + labs(title = "Průměrný počet sesuvů půdy za rok, pro každý stát v tabulce", fill = "Průměrný počet sesuvů půdy")
print(plot)

