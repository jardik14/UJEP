rm(list = ls())
students <- read.csv("StudentsPerformance2.csv")

# bodový graf (base graphics)

plot(students$writing.score, students$reading.score, xlab = "Writing score", ylab = "Reading score", main = "Students performance", col = "blue")

# bodový graf (ggplot2)
library(ggplot2)
library(dplyr)

bodovy_graf_ggplot <- students %>% ggplot(aes(x = writing.score, y = reading.score)) + geom_point() + labs(x = "Writing score", y = "Reading score", title = "Students performance")

print(bodovy_graf_ggplot)

# histogram

students["avg_score"] = (students$math.score + students$reading.score + students$writing.score)/3

# base graphics

hist(students$avg_score, xlab = "Average score", main = "Histogram of average score")

# ggplot2

histogram_ggplot <- students %>% ggplot(aes(x = avg_score)) + geom_histogram(bins = 10, color = "black", fill = "white") + labs(x = "Average score", title = "Histogram of average score")

print(histogram_ggplot)

# boxplot by ethnicity

# base graphics

boxplot(students$math.score ~ students$race, xlab = "Ethnicity", ylab = "Math score", main = "Boxplot of math score by ethnicity")


# ggplot2

boxplot_ggplot <- students %>% ggplot(aes(students$race, students$math.score)) + geom_boxplot() + labs(x = "Ethnicity", y = "Math score", title = "Boxplot of math score by ethnicity")

print(boxplot_ggplot)

# koláž

students2 <- students %>% group_by(race.ethnicity,gender) %>% summarise(avg_score)

kolaz <- students2 %>% ggplot(aes(x = race.ethnicity, y = avg_score)) + geom_boxplot() + facet_wrap(~gender) + labs(x = "Ethnicity", y = "Math score", title = "Boxplot of math score by ethnicity")

print(kolaz)

# ethnics count

students3 <- students %>% group_by(race.ethnicity,gender) %>% summarise(count = n(), .groups = "drop")

ethnics_count <- students3 %>% ggplot(aes(x = race.ethnicity, y = count)) + geom_col()

print(ethnics_count)

ethnics_count2 <- students3 %>% ggplot(aes(x = race.ethnicity, y = count)) + geom_col() + facet_wrap(~gender)

print(ethnics_count2)

# etnika koláč

ethincs_pie <- students3 %>% ggplot(aes(x = "", y = count, fill = race.ethnicity)) + geom_col(color = "black") + coord_polar("y") + facet_wrap(~gender)

print(ethincs_pie)