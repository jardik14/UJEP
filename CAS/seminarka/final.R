library(eurostat)
library(TTR)
library(zoo)
library(forecast)
library(dplyr)
library(ggplot2)
library(reshape2)
library(knitr)

tourism <- get_eurostat("tour_occ_nim")
tourism.cz <- tourism %>%
  filter(geo == "CZ",
         c_resid == "TOTAL",
         nace_r2 == "I551-I553",
         unit == "NR") %>%
  arrange(TIME_PERIOD)

tourism.ts <- ts(tourism.cz$values, start = c(2015,1), end=c(2025,1), frequency = 12)

plot(tourism.ts) # lze videt sezonni slozku

tourism.ts.dec <- decompose(tourism.ts, type="multiplicative")
plot(tourism.ts.dec)

#klouzave prumery
rm6 <- rollmean(tourism.ts, k=6)
rm12 <- rollmean(tourism.ts, k=12)
rm24 <- rollmean(tourism.ts, k=24)
rm48 <- rollmean(tourism.ts, k=48)

plot(tourism.ts)
lines(rm6, col="red")
lines(rm12, col="blue")
lines(rm24, col="green")
lines(rm48, col="purple")
legend("topleft", legend=c("6","12","24","48"), col=c("red","blue","green","purple"), lty=1)
# podivame se na vysledky a podle toho, jak detailni vyhlazeni chceme, volime delku klouzaveho prumeru
# neni dobre, kdyz vyhlazena rada vykazuje opacne vykyvy nez rada puvodni 
#   to znaci male vyhlazeni
# 12 a 24 vypadaji dobre, 6 je malo, 48 je moc, je dobre videt trend

hw.model <- HoltWinters(tourism.ts, seasonal="multiplicative")

plot(tourism.ts, main="Model Holt-Winters", ylab="Values", lwd=2)
lines(hw.model$fitted[,1], col="red", lwd=2)
legend("topleft", legend=c("Fit", "Data"), col=c("red", "black"), lty=1)


par(mfrow=c(2,1))
acf(tourism.ts, main="ACF")
pacf(tourism.ts, main="PACF")
par(mfrow=c(1,1))

sarima.model <- auto.arima(tourism.ts, seasonal=TRUE)
summary(sarima.model)
coeftest(sarima.model)




checkresiduals(sarima.model)

manual.model <- arima(tourism.ts, order=c(0,1,1), seasonal=list(order=c(0,1,1), period=12))
summary(manual.model)
checkresiduals(manual.model)

plot(tourism.ts, main="SARIMA model", ylab="Values", lwd=2)
lines(fitted(sarima.model), col="red", lwd=2)
lines(fitted(manual.model), col="blue", lwd=2)
legend("topleft", legend=c("SARIMA", "Manual", "Data"), col=c("red", "blue", "black"), lty=1)




dat0 <- get_eurostat("tour_occ_nim")
foreign <- subset(dat0, geo == "CZ" & unit == "NR" & nace_r2 == "I551-I553" & c_resid == "FOR")
foreign.ts <- ts(foreign$values, start=c(2015,1), end=c(2025,1), frequency=12)


cz.adj <- tourism.ts / decompose(tourism.ts, type="multiplicative")$seasonal
foreign.adj <- foreign.ts / decompose(foreign.ts, type="multiplicative")$seasonal
plot(cz.adj, main="Celková přenocování v ČR (sezónně očištěno)", ylab="Počet přenocování")

ccf_result <- ccf(foreign.adj, cz.adj, lag.max = 24, main="Kroskorelace zahraničních turistů a celkových přenocování")

dynamic_model <- dynlm(cz.adj ~ L(foreign.adj, 0:3))
summary(dynamic_model)
AIC(dynamic_model)

# SARIMA s exogenní proměnnou
sarimax_model <- auto.arima(tourism.ts, 
                            xreg = foreign.adj, 
                            seasonal = TRUE, 
                            stepwise = FALSE, 
                            approximation = FALSE)

summary(sarimax_model)
checkresiduals(sarimax_model) # ljungbox test kontroluje autokorelaci / pokud je hodnota < 0,05 byla by pritomna autokorelace

pred_hw <- forecast(hw.model, h=10)
plot(pred_hw, main="Predikce 10 budoucích měsíců – Holt-Winters", ylab="Počet přenocování", xlab="Rok")

pred_sarima <- forecast(sarima.model, h=10)
plot(pred_sarima, main="Predikce 10 budoucích měsíců – SARIMA", ylab="Počet přenocování", xlab="Rok")

pred_manual <- forecast(manual.model, h=10)
plot(pred_manual, main="Predikce 10 budoucích měsíců – Manuální ARIMA", ylab="Počet přenocování", xlab="Rok")

# Predikce zahraničních turistů
fit_foreign <- auto.arima(foreign.ts)
foreign_future <- forecast(fit_foreign, h=10)$mean

# Predikce SARIMAX
pred_sarimax <- forecast(sarimax_model, xreg = foreign_future, h = 10)
plot(pred_sarimax, main="Predikce 10 budoucích měsíců – SARIMAX", ylab="Počet přenocování", xlab="Rok")





  # Výpočet přesnosti modelů
  # ----------------------
accuracy_df <- rbind(
  HoltWinters = accuracy(pred_hw)[,c("RMSE","MAPE")],
  SARIMA = accuracy(pred_sarima)[,c("RMSE","MAPE")],
  ManualARIMA = accuracy(pred_manual)[,c("RMSE","MAPE")],
  SARIMAX = accuracy(pred_sarimax)[,c("RMSE","MAPE")]
)
print(accuracy_df)





