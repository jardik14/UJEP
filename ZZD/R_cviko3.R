rm(list = ls())
# Tabulka z HTML
library(rvest)

html_content <- read_html(url("https://ki.ujep.cz/cs/historie/"))

tabulky <- html_table(html_content, header = TRUE)

tbl <- tabulky[[2]]


print(tbl)

# Nahrazení hodnoty Dosud

tbl[9, "Do"] = "2024"

tbl$Do <- as.integer(tbl$Do)

tbl["celkem_let"]=tbl$Do-tbl$Od

tbl <- tbl[order(tbl$celkem_let, decreasing = TRUE),]

print(tbl)

# Students performance


students <- read.csv("D:/Programko/UJEP/ZZD/StudentsPerformance.csv", header = TRUE , sep = ",")


students["avg_score"] = (students$math.score + students$reading.score + students$writing.score)/3


students <- subset(students, subset = grepl("*high school*", students$parental.level.of.education))




# avg for each gender and ethnicity
library(dplyr)


students <- students %>% group_by(gender,race.ethnicity) %>% summarise(mean(avg_score))

students <- students[order(students$gender),]

#students <- students %>% arrange(gender, race.ethnicity)

print(students)
library(tidyr)

students_wider <- students %>% pivot_wider(
  names_from = gender,
  values_from = `mean(avg_score)`
)

students_wider["percentage"] = (students_wider$female - students_wider$male)


print(students_wider)


