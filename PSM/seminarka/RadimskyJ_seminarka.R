rm(list=ls())

# Příprava dat
load("D:/Programko/UJEP/PSM/seminarka/SatData.RData")
df <- satisfaction

# Ošetření duplicitních názvů sloupců 'quality'
quality_pos <- which(names(df) == "quality")
if(length(quality_pos) >= 2) {
  names(df)[quality_pos[1]] <- "expe_quality"  # pro EXPE konstrukci
  names(df)[quality_pos[2]] <- "val_quality"   # pro VAL konstrukci
}

# Vytvoření kompozitních skóre (průměry indikátorů)
df$IMAG <- rowMeans(df[, c("reputation", "trustworthiness", "seriousness", "solidness", "care")], na.rm = TRUE)
df$EXPE <- rowMeans(df[, c("exp_products", "exp_services", "service", "solutions", "expe_quality")], na.rm = TRUE)
df$QUAL <- rowMeans(df[, c("qual_products", "qual_services", "range_products", "qual_personal", "qual_overall")], na.rm = TRUE)
df$VAL  <- rowMeans(df[, c("benefits", "investments", "val_quality", "price")], na.rm = TRUE)
df$SAT  <- rowMeans(df[, c("satisfaction", "expectations", "comparison", "performance")], na.rm = TRUE)
df$LOY  <- rowMeans(df[, c("return", "switch", "recommendation", "loyalty")], na.rm = TRUE)

# Základní charakteristika šetření
n_resp <- nrow(df)
cat("Počet respondentů:", n_resp, "\n")
summary(df[, c("IMAG","EXPE","QUAL","VAL","SAT","LOY")])

# i) ----------------------------------------------------

# Regresní analýza: predikce celkové spokojenosti (SAT)
model_sat <- lm(SAT ~ IMAG + EXPE + QUAL + VAL + LOY, data = df)
summary(model_sat)

# Vizualizace regresních koeficientů
library(broom)
library(ggplot2)
coef_df <- broom::tidy(model_sat)
coef_df <- coef_df[coef_df$term != "(Intercept)", ]

ggplot(coef_df, aes(x = reorder(term, estimate), y = estimate)) +
  geom_col() +
  coord_flip() +
  labs(
    x = "Prediktor",
    y = "Odhad koeficientu"
  ) +
  theme_minimal()

# Doporučení pro strategii banky
# Na základě signifikantních prediktorů (p < 0.05) zaměřit marketingové aktivity na tyto
# konstrukty s nejvyššími koeficienty: VAL (vnímání hodnoty), IMAG (budování reputace) a LOY (loajalita).

# ii) ---------------------------------------------------

# Logistická regrese pro odchod klienta (odchod)
# Definice binární proměnné odchod: 1 = vysoká ochota přejít (switch > 5), 0 = nízká
df$odchod <- ifelse(df$switch > 5, 1, 0)
print(table(df$odchod))

# Modelování rizikových faktorů odchod pomocí logistické regrese
model_odchod <- glm(odchod ~ IMAG + EXPE + QUAL + VAL + SAT, data=df, family=binomial)
summary(model_odchod)

# Výpočet poměrů šancí (OR)
or_df <- exp(cbind(OR = coef(model_odchod), confint(model_odchod)))
cat("\nPoměry šancí a 95% CI:\n")
print(or_df)

# Vizualizace OR
coef_odchod <- broom::tidy(model_odchod)
coef_odchod <- coef_odchod[coef_odchod$term != "(Intercept)", ]
coef_odchod$OR <- exp(coef_odchod$estimate)
coef_odchod$lower <- exp(coef_odchod$estimate - 1.96*coef_odchod$std.error)
coef_odchod$upper <- exp(coef_odchod$estimate + 1.96*coef_odchod$std.error)

ggplot(coef_odchod, aes(x=reorder(term, OR), y=OR)) +
  geom_point() +
  geom_errorbar(aes(ymin=lower, ymax=upper), width=0.2) +
  coord_flip() +
  labs(title="Poměry šancí pro odchod", x="Prediktor", y="OR (95% CI)") +
  theme_minimal()

# iii) -------------------------------------------------

# Diskriminační analýza pro klíčové segmenty
library(MASS)
# Definice segmentů
med_SAT <- median(df$SAT, na.rm=TRUE)
med_LOY <- median(df$LOY, na.rm=TRUE)
df$segment <- with(df, factor(
  ifelse(odchod == 1, 
         "leave",                             # odcházející klienti
         ifelse(SAT >  med_SAT & odchod == 0, 
                "stay_sat",                    # spokojení a zůstanou
                "stay_unsat"))                       # nespokojení ale zůstanou
))
print(table(df$segment))

# Výběr několika prediktorů pro diskriminaci (dotazníkové otázky)
vars_lda <- c("reputation","exp_services","qual_overall","price","performance")
# LDA model
model_lda <- lda(segment ~ ., data=df[, c("segment", vars_lda)])
print(model_lda)

# Vyhodnocení klasifikace
pred_lda <- predict(model_lda)
# Klasifikační matice
print(table(df$segment, pred_lda$class))
# Přesnost klasifikace
accuracy <- sum(df$segment == pred_lda$class) / nrow(df)
print(accuracy*100) # přesnost v procentech

# iv) ------------------------------------------------

# Shluková analýza pro profilaci segmentů
# Výběr proměnných: kompozitní skóre
clust_data <- scale(df[, c("IMAG","EXPE","QUAL","VAL","SAT","LOY")])

# Určení počtu shluků (scree plot)
wss <- sapply(1:6, function(k) {kmeans(clust_data, k, nstart=20)$tot.withinss})
plot(1:6, wss, type="b", xlab="Počet shluků", ylab="Within-cluster SS", main="Elbow metoda")

k <- 2
set.seed(123)
km <- kmeans(clust_data, centers=k, nstart=25)
df$cluster <- factor(km$cluster)
cat(sprintf("\nShlukování: použito %d shluků\n", k))
print(table(df$cluster))

# Profilace shluků: průměry kompozitních skóre
cluster_profile <- aggregate(df[, c("IMAG","EXPE","QUAL","VAL","SAT","LOY")], by=list(cluster=df$cluster), mean)
print(cluster_profile)

# v) ------------------------------------------------

# Korelační analýza kompozitních skóre
library(corrplot)
# Vypočítat matici korelací
comp_scores <- df[, c("IMAG","EXPE","QUAL","VAL","SAT","LOY")]
M <- cor(comp_scores, use="pairwise.complete.obs")
# Vykreslit heatmapu korelací s koeficienty
corrplot(M, method="color", addCoef.col="black", number.cex=0.7, tl.cex=0.8, title="Korelace kompozitních skóre")

