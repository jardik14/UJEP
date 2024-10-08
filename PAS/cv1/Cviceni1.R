rm(list = ls())
### Cviceni k Pravdepodobnost a Statistika
## cvicici: Alena Cernikova, e-mail: alena.cernikova@ujep.cz

### Populace, reprezentativni vyber
# Vzhledem k jake populaci byste mohli tvorit reprezentativni vyber?
# Proc jste/ nejste reprezentativni vyber vzhledem ke vsem studentum VS v CR? 
#   Ke studentum UJEP? Ke studentum informatiky UJEP? Ke studentum tretiho rocniku UJEP?

# Nactete si datovy soubor Kojeni.RData
#   Data pouzita na zpracovani DP na PrF UK nekdy v roce 2001.
#   Data byla sbirana na jedne Prazske a jedne Kladenske porodnici
#   (v promenne Porodnice znaceno jako "Praha", "okresni")

setwd("D:/Programko/UJEP/PAS/cv1")
load("Kojeni.RData")

# Pro jakou populaci by byl tento vyber reprezentativni?
#   Muze/nemuze byt reprezentativni ke vsem novorozencum v CR?
#     Ke vsem novorozencum v CR v roce 2001? Ke vsem stredoceskym novorozencum
#     v roce 2001? Je mozne zobecnit vysledek porovnani Prazske vs. okresni porodnice v roce 2001?
#     A co Praha vs. Kladno v roce 2001?

# Nactete si datovy soubor Okresy03.RData
#   jedna se o udaje o vsech okesech v CR v roce 2003
#   Pro jakou populaci je reprezentativni tento datovy soubor?

load("Okresy03.RData")

# datovy soubor airquality
data("airquality")
#   denni data hodnotici kvalitu ovzdusi v New Yorku v roce 1973.
#   Jak mohu zobecnit vysledky ziskane na techto datech?
#   Muzu delat zavery o koncentraci ozonu v letnich mesicich v USA?
#   Muzu zobecnovat vysledky o zavislosti koncentrace ozonu na povetrnostnich podminkach?

# datovy soubor esoph
data("esoph")
#   data z pripadove studie rakoviny jicnu z roku 1980 z Francie
#   pocty lidi s rakovinou jicnu pri ruznych kombinacich veku, konzumace alkoholu a koureni
#   jake zavery mohu zobecnit? Jak zarucit, abych mohla zobecnit? 

# datovy soubor ChickWeight
data("ChickWeight")
#   vaha kurat spolu s jejich vekem a stravou, kterou dostavala
#   promenne: weight - vaha, time - vek kurete ve dnech, chick - identifikator kurete, diet - oznaceni vyzivy
#   co mohu z takovychto dat zjistit?

# Jak bych mela udelat vyber, kdyby me zajimal prumerny prijem obyvatel CR?
# Jak bych mela udelat vyber, kdyby me zajimalo porovnani nazoru studentu PrF UJEP a FSE UJEP.
# Jakym zpusobem bych mohla porovnavat chut dvou jogurtu? Ktery lidem chutna vic.

#################################
### Typy promennych
# Jakeho typu jsou promenne v databazi ChickWeight? 
#   Mate na vyber> ciselne spojite, ciselne diskretni, nominalni, ordinalni.
#   Ze kterych promennych mohu pocitat prumer?

# Vratme se k databazi Kojeni
# Jakeho typu jsou promenne v teto databazi? 
#   Zajimavost: jak je mozne zapsat promennou pohlavi

#################################
### Popis kategoricke promenne
# absolutni a relativni cetnosti, kumulativni absolutni a relativni cetnosti

## nominalni promenna
# vypoctete absolutni a relativni cetnosti promenne Hoch
Hoch <- Kojeni$Hoch
table(Hoch)
  # absolutni cetnosti
prop.table(table(Hoch))*100
  # relativni cetnosti v procentech
round(prop.table(table(Hoch))*100,2)
cbind("absolutni"=table(Hoch),"relativni"=round(prop.table(table(Hoch))*100,2))
  # v jedne tabulce
  # ma smysl resit kumulativni cetnosti?

# vypoctete absolutni a relativni cetnosti pro misto porodu   
# vytvorte kombinovanou promennou pro pohlavi a misto porodu a 
#   vypoctete pro ni absolutni a relativni cetnosti. 
#   A co by mi zde rekly kumulativni cetnosti?
hoch <- Kojeni$hoch
Porodnice <- Kojeni$Porodnice
Por.poh<-ifelse(hoch==1&Porodnice=="Praha","Hoch z Prahy","Hoch z venkova")
Por.poh<-ifelse(hoch==0&Porodnice=="Praha","Divka z Prahy",Por.poh)
Por.poh<-ifelse(hoch==0&Porodnice=="okresní","Divka z venkova",Por.poh)

table(Por.poh)
prop.table(table(Por.poh))*100
round(prop.table(table(Por.poh))*100,2)

# Vlstní implementace
tabulka <- Kojeni %>% 
  group_by(Porodnice, Hoch) %>% 
  summarise(n = n()) %>% 
  mutate(Procenta = n/sum(n)*100)



# Jaky graf byste pouzili pro nominalni promennou?
## POZOR: Kazdy graf musi mit nazev a oznaceni os, jinak se krati body!!!
barplot(table(Por.poh),col=2:5,main="Sloupcovy graf")
  # sloupcovy graf
pie(table(Por.poh),col=2:5,main="Kolacovy graf")
  # kolacovy graf
# popisky jednotlivych bodu
leg<-sort(unique(Por.poh))
rc<-round(prop.table(table(Por.poh))*100,2)
for(i in 1:length(leg)){
  leg[i]<-paste(leg[i],"(",rc[i],"%)")
}
pie(table(Por.poh),col=2:5,main="Kolacovy graf",labels=leg)

## ordinalni promenna
# vypoctete absolutni a relativni cetnosti pro promennou Vzdelani
Vzdel <- Kojeni$Vzdelani
table(Vzdel)
(ac<-table(Vzdel))
  # absolutni cetnosti
(rc<-round(prop.table(table(Vzdel)),2))
  # relativni cetnosti
cbind("absolutni"=ac,"relativni"=rc)
  # a jak je to zde s kumulativnimi cetnostmi?

(kac<-cumsum(ac))
  #  kumulativni absolutni cetnosti
(krc<-cumsum(rc))
  # kumulativni relativni cetnosti
cbind("n(i)"=ac,"N(i)"=kac,"p(i)"=rc,"P(i)"=krc)
  # vsechny cetnosti v jedne tabulce

# Jake grafy byste pouzili pro ordinalni promennou?

# Pouzijte data mtcars
data("mtcars")
#   data o autech z roku 1974
#   promenne: mpg - ujete mile na galon benzinu, cyl - pocet valcu,
#             disp - objem, hp - sila vozu, drat - pomer zadni osy,
#             wt - vaha, qsec - za jak dlouho ujedou 1/4 mile,
#             vs - typ motoru: 0 - ve tvaru V, 1 - primy,
#             am - prevodovka: 0 - automaticka, 1 - manualni
#             gear - pocet rychlosti, carb - pocet karburatoru 
# urcete v nich typy promennych a pro ty kategoricke (nominalni i ordinalni)
#   spocitejte popisne statistiky