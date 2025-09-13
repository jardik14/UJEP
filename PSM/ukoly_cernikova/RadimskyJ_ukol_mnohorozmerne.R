rm(list=ls())

# Načtení dat
wineUrl <- 'http://archive.ics.uci.edu/ml/machine-learning-databases/wine/wine.data'
wine <- read.table(wineUrl, header=FALSE, sep=',', stringsAsFactors=FALSE,
                   col.names=c('Cultivar', 'Alcohol', 'Malic.acid','Ash', 'Alcalinity.of.ash',
                               'Magnesium', 'Total.phenols','Flavanoids', 'Nonflavanoid.phenols',
                               'Proanthocyanin', 'Color.intensity', 'Hue', 'OD280.OD315.of.diluted.wines',
                               'Proline'))

library(ggplot2)

# Jednofaktorová analýzu rozptylu (ANOVA)
# Nulová hypotéza H₀: Střední hodnoty proměnné jsou shodné napříč skupinami
# Alternativní hypotéza H₁: Alespoň jedna skupinová střední hodnota se liší.

# ANOVA p-hodnoty
anova_pvals <- sapply(names(wine)[-1], function(var) {
  summary(aov(as.formula(paste(var, "~ Cultivar")), data = wine))[[1]][["Pr(>F)"]][1]
})

# Dataframe pro ggplot
anova_df <- data.frame(Variable = names(anova_pvals), P_value = anova_pvals)
anova_df <- anova_df[order(anova_df$P_value), ]

#P-hodnoty pro ANOVA
anova_df

# Mnohorozměrná analýza rozptylu (MANOVA) - testuje všechny proměnné současně
# H₀: Vektor středních hodnot pro všechny proměnné je stejný ve všech skupinách (Cultivar)
# H₁: Alespoň jeden vektor středních hodnot se liší.

manova_fit <- manova(as.matrix(wine[, -1]) ~ wine$Cultivar)
summary(manova_fit, test = "Pillai")

# Pillaiova statistika - čím vyšší, tím větší rozdíly mezi skupinami
# Pillai = 0.9 (výsoká hodnota -> silné rozdíly mezi skupinami)
# p-hodnota = 2.2e-16 (nulová hypotéza je silně zamítnuta)

# Vizualizace výsledků ANOVA
# Logaritmická osa pro lepší čitelnost
ggplot(anova_df, aes(x = reorder(Variable, -P_value), y = -log10(P_value))) +
  geom_col(fill = "steelblue") +
  labs(title = "Významnost rozdílů mezi odrůdami (ANOVA)",
       x = "Proměnná", y = "-log10(p-hodnota)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Z výsledků můžeme vidět, že odrůdy se nejvíce odlišují v proměných:
# Flavanoids, OD280.OD315.of.diluted.wines a Total.phenols

# -----------------------------------------

# Standardizace a PCA
wine_scaled <- scale(wine[,-1])
pca <- prcomp(wine_scaled)

# Procento vysvětlené variance
summary(pca)

# Grafické znázornění
plot(pca, type="l", main="Scree plot")
biplot(pca, scale=0)
# Biplot:
# - šipky ukazují, jak moc každá původní proměnná přispívá k jednotlivým komponentám.
#     z grafu lze vidět, např. že původní proměnné Alcohol a Color.intensity 
#     mají silný negativní vliv na novoi proměnnou PC2

# - čísla (body) představují jednotlivé vzorky v prostoru hlavních komponent


# z lomu grafu "Scree plot" je vidět, že první 3 komponenty zachycují většinu variance

# Váhy proměnných (loadingy) pro PC1–PC3
# ukazují, jak moc každá původní proměnná přispívá k těmto novým komponentám
loadings <- pca$rotation[, 1:3]
print("Loadingy pro první 3 komponenty:")
print(loadings)

# Nový dataset s prvními 3 komponentami + Cultivar
pca_data <- data.frame(pca$x[, 1:3])
pca_data$Cultivar <- wine$Cultivar

# Kolik procent informace zachováváme?
explained_var <- summary(pca)$importance[2, 1:3]  # proportion of variance
total_explained <- sum(explained_var)
cat("Celková vysvětlená variance pomocí PC1–PC3:", round(total_explained * 100, 2), "%\n")


# Faktorová analýza
library(psych)
fa_result <- fa(wine_scaled, nfactors = 3, rotate = "varimax", fm = "ml")

# Výstup s faktorovými zátěžemi
print(fa_result$loadings, cutoff = 0.3)

fa.diagram(fa_result)

# Faktorová analýza nám z původních dat extrahovala 3 faktory:

# ML1 - Tento faktor zachycuje obsah polyfenolů ve víně – látky ovlivňující chuť,
# hořkost, barvu a antioxidantní vlastnosti. 
# Vysoké hodnoty tohoto faktoru by odpovídaly vínům s bohatším tělem a strukturou.

# ML2 - Tento faktor vystihuje mineralitu a zásaditost popela, 
# tedy vlastnosti spojené s anorganickým složením vína – 
# může jít o vliv půdy, způsob vinifikace nebo přítomnost solí.

# ML3 - Tento faktor kombinuje sílu a sytost vína – vysoký obsah alkoholu, 
# barva (intenzita) a obsah aminokyselin (Proline). Může být spojen s plnějšími, 
# intenzivnějšími víny.


fa_scores <- data.frame(fa_result$scores)
fa_scores$Cultivar <- as.factor(wine$Cultivar)

library(plotly)

# interaktivní 3D scatter plot
plot_ly(fa_scores, 
        x = ~ML1, y = ~ML2, z = ~ML3, 
        color = ~Cultivar, 
        colors = c("#1f77b4", "#2ca02c", "#d62728"),
        type = "scatter3d", mode = "markers") %>%
  layout(scene = list(
    xaxis = list(title = "Faktor 1 – Fenolový profil"),
    yaxis = list(title = "Faktor 2 – Mineralita"),
    zaxis = list(title = "Faktor 3 – Alkohol/barva")
  ),
  title = "3D zobrazení vín v prostoru faktorů")

# -----------------------------------------

library(MASS)

# Rozdělení na trénovací a testovací data
train_idx <- sample(1:nrow(wine), size = 0.7 * nrow(wine))
train_data <- wine[train_idx, ]
test_data  <- wine[-train_idx, ]

# Zastoupení jednotlivých odrůd v datech
table(wine$Cultivar)
prop.table(table(wine$Cultivar))
# procentuální zastoupení odrůd je poměrně vyvážené, 
# není třeba měnit apriori pravděpodobnosti (defaultně: 1/3, 1/3, 1/3)

# LDA model na trénovacích datech
lda_model <- lda(Cultivar ~ ., data = train_data)

# Predikce na testovacích datech
lda_pred <- predict(lda_model, newdata = test_data)$class

# Matice záměn (confusion matrix)
table(Predikce = lda_pred, Skutečnost = test_data$Cultivar)

# Chybovost (misclassification rate)
mean(lda_pred != test_data$Cultivar)

presnost <- sum(lda_pred == test_data$Cultivar) / nrow(test_data)
cat("Presnost LDA modelu:", round(presnost * 100, 2), "%\n")

# -----------------------------------------


# Určení optimálního počtu skupin
wss <- numeric(10)
for (k in 1:10) {
  set.seed(123)
  km <- kmeans(wine_scaled, centers = k, nstart = 25)
  wss[k] <- km$tot.withinss
}
plot(1:10, wss, type = "b", pch = 19, frame = FALSE,
     xlab = "Počet skupin K", ylab = "Součet vnitroskupinové variability",
     main = "Metoda lokte")
# Nejlepší počet skupin je 3, protože zde je největší pokles variability

# K-means clustering s optimálním počtem skupin
set.seed(123)
km3 <- kmeans(wine_scaled, centers = 3, nstart = 25)
table(km3$cluster)

# Hierarchické shlukování
# Výpočet vzdáleností a hierarchická shluková analýza
dist_matrix <- dist(wine_scaled)
hclust_model <- hclust(dist_matrix, method = "ward.D2")
rect.hclust(hclust_model, k = 3, border = "red")
# aglomerační hierarchické shlukování s metrikou Ward.D2 (minimalizuje celkovou vnitroshlukovou variabilitu)

# Dendrogram
plot(hclust_model, labels = FALSE, main = "Hierarchické shlukování")

# Rozdělení do 3 skupin
cutree3 <- cutree(hclust_model, k = 3)
table(cutree3)

# Charakterizace shluků k-means pomocí průměrů
wine$Cluster <- km3$cluster
aggregate(. ~ Cluster, data = wine[,-1], mean)  # bez Cultivar
  # z výstupu můžeme například vidět že 1. shluk má nejnižší hodnoty flavanoidů a fenolů a zároveň má nejvyšší intenzitu barvy
  # oproti tomu 3. shluk má nejníší hodnotu alkoholu a zároveň nejnižší barevnou intenzitu

# Skupina 1 – „Silná, tmavá vína s nízkým obsahem fenolů“
# - Alkohol: 13.13 (střední)
# - Malic acid: 3.31 (nejvyšší kyselost ze všech skupin)
# - Total phenols: 1.68 (nejnižší obsah fenolů)
# - Flavanoids: 0.82 (velmi nízké – nízká antioxidační aktivita)
# - Color intensity: 7.23 (nejvyšší barva ze všech skupin)
# - Proline: 619 (střední hodnota)
# => Tato vína mají vysokou kyselost, málo fenolových látek, ale velmi intenzivní barvu.
#    Pravděpodobně se jedná o ostřejší, jednodušší vína s výrazným vzhledem.

# Skupina 2 – „Silná, bohatá vína s vysokým obsahem fenolů“
# - Alkohol: 13.68 (nejvyšší – silná vína)
# - Total phenols: 2.85 (nejvyšší fenolová složka)
# - Flavanoids: 3.00 (výrazně nejvyšší – silné antioxidanty a tělo)
# - OD280/OD315: 3.16 (čistota a vyzrálost)
# - Color intensity: 5.45 (střední)
# - Proline: 1100 (nejvyšší – plné tělo)
# => Jde o plná, strukturovaná vína s vysokou kvalitou a komplexním chuťovým profilem.

# Skupina 3 – „Lehká, jemná vína s nižším obsahem alkoholu“
# - Alkohol: 12.25 (nejnižší – lehká vína)
# - Total phenols: 2.25 (méně fenolů)
# - Flavanoids: 2.05 (nižší než u skupiny 2, ale vyšší než u skupiny 1)
# - Color intensity: 2.97 (nejnižší – světlá vína)
# - OD280/OD315: 2.80 (nižší čistota a vyzrálost)
# - Proline: 510 (nejnižší – lehčí víno)
# => Tato vína jsou světlejší, jemnější, s nižším alkoholem a méně plným tělem.
#    Pravděpodobně jde o běžná, svěží vína vhodná k lehkému pití.

# Porovnání shluků k-means a hierarchického shlukování
table(Kmeans = km3$cluster, Hclust = cutree3)
  # oba shlukovací algoritmy vytvořily podobné shluky, jen jinak uspořádané

# Porovnání shluků s původními odrůdami
table(Kmeans = km3$cluster, Cultivar = wine$Cultivar)
table(Hclust = cutree3, Cultivar = wine$Cultivar)
  # oba algoritmy vytvořily shluky, které se výrazně překrývají s původními odrůdami vína



# Shlukování komponent PCA
# díky redukované dimenzionalitě dat můžeme shlukování vizualizovat v 3D prostoru

# K-means na PCA
kmeans_pca <- kmeans(pca_data, centers = 3, nstart = 25)

# Přidání shluku do PCA dat
pca_data$Cluster <- as.factor(kmeans_pca$cluster)

# 3D vizualizace
library(scatterplot3d)
scatterplot3d(pca_data$PC1, pca_data$PC2, pca_data$PC3,
              color = as.numeric(pca_data$Cluster),
              pch = 19,
              xlab = "PC1", ylab = "PC2", zlab = "PC3",
              main = "K-means clustering na PCA (3D)",
              angle = 55)

legend("topright", legend = levels(pca_data$Cluster),
       col = 1:3, pch = 19, title = "Cluster")
  # pomocí parametru angle můžeme měnit úhel pohledu na 3D graf

# Pro nalezení idealních úhlů pro zobrazení dat v 3D prostoru je dobré využít interaktivní grafy
# Vytvoření interaktivního 3D scatter plotu
plot_ly(data = pca_data,
        x = ~PC1, y = ~PC2, z = ~PC3,
        color = ~Cluster,
        colors = c("#1f77b4", "#2ca02c", "#d62728"),
        type = "scatter3d",
        mode = "markers",
        marker = list(size = 4)) %>%
  layout(title = "K-means clustering na PCA (3D)",
         scene = list(
           xaxis = list(title = "PC1"),
           yaxis = list(title = "PC2"),
           zaxis = list(title = "PC3")
         ))


