rm(list = ls())


library(eurostat)
library(dplyr)
library(ggplot2)
library(ggpubr)
library(plotly)
library(zoo)
library(dplyr)
library(TTR)


# HICP - inflace (celkový index, index 2015=100)
hicp_cz <- get_eurostat("prc_hicp_midx", time_format = "date") %>%
  filter(geo == "CZ", coicop == "CP00", unit == "I15") %>%
  select(time = TIME_PERIOD, hicp = values)

# Nezaměstnanost (v % z aktivních, NSA)
unemp_cz <- get_eurostat("une_rt_m", time_format = "date") %>%
  filter(geo == "CZ", s_adj == "NSA", sex == "T", age == "TOTAL", unit == "PC_ACT") %>%
  select(time = TIME_PERIOD, unemp = values)

# Průmyslová produkce (zpracovatelský průmysl, index 2015=100, NSA)
industry_cz <- get_eurostat("sts_inpr_m", time_format = "date") %>%
  filter(geo == "CZ", s_adj == "NSA", nace_r2 == "C", unit == "I15") %>%
  select(time = TIME_PERIOD, industry = values)

# Spojení do jedné tabulky (už 1:1 join)
data_cz <- hicp_cz %>%
  left_join(unemp_cz, by = "time") %>%
  left_join(industry_cz, by = "time")

# industry data jsou až od roku 2000, takže ořízneme i ostatní
data_cz <- data_cz %>%
  filter(time >= as.Date("2000-01-01"))

head(data_cz)

#####################
# 1. Grafické zobrazení

# HICP
p1 <- ggplot(data_cz, aes(x = time, y = hicp)) +
  geom_line(color = "blue") +
  labs(title = "HICP - ČR", x = "Datum", y = "Index") +
  theme_minimal()

# Nezaměstnanost
p2 <- ggplot(data_cz, aes(x = time, y = unemp)) +
  geom_line(color = "red") +
  labs(title = "Nezaměstnanost - ČR", x = "Datum", y = "%") +
  theme_minimal()

# Průmyslová produkce
p3 <- ggplot(data_cz, aes(x = time, y = industry)) +
  geom_line(color = "green") +
  labs(title = "Průmyslová produkce - ČR", x = "Datum", y = "Index") +
  theme_minimal()

ggarrange(p1, p2, p3, ncol = 1, nrow = 3)


# Na grafu průmyslové produkce lze dobře vidět její sezónnost (pravidelné roční výkyvy).
industry_short <- industry_cz %>%
  filter(time >= as.Date("2010-01-01") & time < as.Date("2013-01-01"))

ggplot(industry_short, aes(x = time, y = industry)) +
  geom_line(color = "green", size = 1) +
  labs(title = "Průmyslová produkce v ČR v roce 2010-2012",
       x = "Měsíc",
       y = "Index") +
  theme_minimal()
# Produkce v grafu vždy klesá v zimě (prosinec, leden) a v letních měsících (červenec, srpen).

hicp_short <- hicp_cz %>%
  filter(time >= as.Date("2005-01-01") & time < as.Date("2008-01-01"))
ggplot(hicp_short, aes(x = time, y = hicp)) +
  geom_line(color = "blue", size = 1) +
  labs(title = "HICP v ČR v letech 2005-2008",
       x = "Měsíc",
       y = "Index") +
  theme_minimal()
# Inflace má vidět mírný pokles na podzim, ale jinak je relativně stabilní.

unemp_short <- unemp_cz %>%
  filter(time >= as.Date("2007-01-01") & time < as.Date("2010-01-01"))
ggplot(unemp_short, aes(x = time, y = unemp)) +
  geom_line(color = "red", size = 1) +
  labs(title = "Nezaměstnanost v ČR v roce 2007-2010",
       x = "Měsíc",
       y = "%") +
  theme_minimal()
# V nezaměstnanosti žádna sezónnost okem není vidět.


#####################
# 2. Dekompozice + identifikace trendu pomocí klouzavého průměru

# převedem na ts
unemp_ts <- ts(unemp_cz$unemp, start = c(2000, 1), frequency = 12)
industry_ts <- ts(industry_cz$industry, start = c(2000, 1), frequency = 12)
hicp_ts <- ts(hicp_cz$hicp, start = c(2000, 1), frequency = 12)

plot(industry_ts)

# Dekompozice
industry_decomp <- decompose(industry_ts)
plot(industry_decomp)

# klouzave prumery
industry.rm3 <- rollmean(industry_ts, 3)
industry.rm5 <- rollmean(industry_ts, 5)
industry.rm7 <- rollmean(industry_ts, 7)
industry.rm9 <- rollmean(industry_ts, 9)
industry.rm11 <- rollmean(industry_ts, 11)

plot(industry_ts)
lines(industry.rm3, col = 2)
lines(industry.rm5, col = 3)
lines(industry.rm7, col = 4)
lines(industry.rm9, col = 5)
lines(industry.rm11, col = 6)
legend(2016, 60, legend=c("puvodni rada", "KP delky 3", "KP delky 5", "KP delky 7", "KP delky 9", "KP delky 11"),
       lty=1, col=1:6, cex=0.8)

# ts -> data frame
industry_df <- data.frame(
  time = time(industry_ts),
  industry = as.numeric(industry_ts)
)

# klouzavé průměry
industry_df <- industry_df %>%
  mutate(
    rm3  = rollmean(industry, k = 3, fill = NA, align = "center"),
    rm5  = rollmean(industry, k = 5, fill = NA, align = "center"),
    rm7  = rollmean(industry, k = 7, fill = NA, align = "center"),
    rm9  = rollmean(industry, k = 9, fill = NA, align = "center"),
    rm11 = rollmean(industry, k = 11, fill = NA, align = "center")
  )

p_rm <- ggplot(industry_df, aes(x = time)) +
  geom_line(aes(y = industry), color = "green") +
  geom_line(aes(y = rm3), color = "blue") +
  geom_line(aes(y = rm5), color = "red") +
  geom_line(aes(y = rm7), color = "purple") +
  geom_line(aes(y = rm9), color = "orange") +
  geom_line(aes(y = rm11), color = "brown") +
  labs(title = "Průmyslová produkce v ČR s klouzavými průměry",
       x = "Rok",
       y = "Index") +
  theme_minimal()

ggplotly(p_rm)

# expo

#####################
# 3. Hledani optimalního modelu pro samotnou řadu 
# funkční zápis trendu + sezónnost, pomoci mohou dynamické modely)

hw_model <- HoltWinters(industry_ts)

########## 

# převod na časové řady
hicp.ts <- ts(data_cz$hicp, start = c(2000,1), frequency = 12)
unemp.ts <- ts(data_cz$unemp, start = c(2000,1), frequency = 12)
industry.ts <- ts(data_cz$industry, start = c(2000,1), frequency = 12)

# 4. hledani optimalniho modelu sarima
plot(industry.ts)
industry.ts
par(mfrow = c(2,1))
acf(industry.ts, na.action = na.pass); pacf(industry.ts, na.action = na.pass)
par(mfrow = c(1,1))

d1 <- diff(industry.ts, lag = 12)
# rada prvnich sezonnich diferenci
plot(d1)
# rada je na prvni pohled bez trendu i sezonnosti
par(mfrow = c(2,1))
acf(d1, na.action = na.pass); pacf(d1, na.action = na.pass)
par(mfrow = c(1,1))


(fit.auto <- auto.arima(industry.ts))

coeftest(fit.auto) # všschny čelny jsou významné
AIC(fit.auto)
BIC(fit.auto)

acf(residuals(fit.auto))

plot(industry.ts)
lines(fitted(fit.auto), col=2)

pred.auto <- forecast(fit.auto, 30)
plot(pred.auto)


########
# 5. heldani optimalniho modelu pomoci zavislosti na jinych radach (kroskorelace)

ccf(industry.ts, unemp.ts,na.action = na.pass)
ccf(industry.ts, hicp.ts,na.action = na.pass)
# vysoká závislost u obou (nejvyssi v nulovem spozdeni)

lm1 <- lm(industry.ts ~ unemp.ts + hicp.ts)
summary(lm1)
checkresiduals(lm1)
# rezidua mají silnou autokorelaci -> lineární model nestačí



# průmysl závisí na HICP, nezaměstnanosti a zpoždění průmyslu
dyn_model <- dynlm(industry.ts ~ L(industry.ts, 1) + L(industry.ts, 12) + L(hicp.ts, 1) + L(unemp.ts, 1))
summary(dyn_model)
checkresiduals(dyn_model)
# stále korelovaná


fit.a <- auto.arima(industry.ts, xreg = cbind(hicp.ts, unemp.ts))
summary(fit.a)
coeftest(fit.a)
checkresiduals(fit.a)
# stále korelovaná



gls_model <- gls(industry.ts ~ hicp.ts + unemp.ts,
                 correlation = corARMA(p = 3, q = 2))
summary(gls_model)
checkresiduals(gls_model)
#stále korelovaná


plot(industry.ts)
lines(fitted(fit.a), col = 2)

pred.a <- forecast(fit.a, 30)
plot(pred.a)

AIC(fit.auto)
AIC(fit.a)

