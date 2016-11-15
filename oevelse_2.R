library('dplyr')
library(car)

oeko <- read.csv("http://publicifsv.sund.ku.dk/~lts/basal/data/oeko.txt", header=T, sep=" ")

#Creat new variable with log of koncentration
oeko$logkonc <- log10(oeko$konc)

#Compare the two boxplots of normal koncentration and transformed koncentration
boxplot(konc~sas_ansat, data=oeko)
boxplot(logkonc~sas_ansat, data=oeko)

summary(oeko$logkonc)
describe(oeko$logkonc)

#Laver abstid om til en faktor
oeko$abstid <- as.factor(oeko$abstid)


#T-test for at sammenligne om logkonc er forskellig hos SAS-ansatte vs ikke-SAS-ansatte
t.test(logconc ~ sas_ansat, oeko)

#Tilbagetransformering af differensen og konfidensintervaller
10^c(-0.32, -0.046)
10^(1.83-1.64)


#Two way ANOVA with interaction and print of summary table

aov1 <- aov(logkonc ~ sas_ansat + abstid + sas_ansat:abstid, data=oeko)
summary(aov1)

#Show the means
model.tables(aov1, "means")

#Hvis der oenskes Tukey bagefter kan dette bare goeres paa foelgende vis:
#TukeyHSD(aov1)

table(oeko$sas_ansat, oeko$abstid)

#Levenes test for homogenuous variance (requires library(car)), Hvis p>0.05 er der ikke evidens for at varianserne er uens
leveneTest(logkonc ~ abstid, data=oeko)
