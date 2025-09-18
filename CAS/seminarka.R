rm(list = ls())

library(eurostat)
library(dplyr)
library(ggplot2)
library(dynlm)
library(nlme)

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



data_cz <- data_cz %>%
  filter(time >= as.Date("2000-01-01"))

data_cz <- data_cz %>%
  filter(time < as.Date("2024-01-01"))


# převod na časové řady
hicp.ts <- ts(data_cz$hicp, start = c(2000,1), frequency = 12)
unemp.ts <- ts(data_cz$unemp, start = c(2000,1), frequency = 12)
industry.ts <- ts(data_cz$industry, start = c(2000,1), frequency = 12)


########## 

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
