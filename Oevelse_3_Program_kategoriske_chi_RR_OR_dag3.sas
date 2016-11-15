/* Indtaster data. Fordi jeg kun taster grupperne ind, skal jeg bruge "weight antal" i de efterfølgende analyser. */
/*Jeg taster 1: og 2: for at rangordne, dvs. angive hvad der er referencegruppen. Dette giver mere letfortolkelige RR og OR */
/*Kan også bruge ~foran referencekategorien, som er det absolut højeste værdi*/

data astma;
input treatment$ discharge$ antal;
datalines;
2:placebo 1:dis 2
2:placebo 2:no_dis 71
1:prednisolon 1:dis 20
1:prednisolon 2:no_dis 47
;
run;

/* Tabeller med udregning af forventede værdier og Chi-squared */
proc freq data=astma;
tables treatment*discharge /
chisq nopercent nocol expected;
weight antal;
run;



/* Kvantificering af differensen P1-P2 Husk at angive eksponering FØR outcome: eksponering*outcome*/
proc freq data=astma;
tables treatment*discharge / riskdiff;
weight antal;
run;


/* Relativ risiko og odds ratio Husk at angive eksponering FØR outcome: eksponering*outcome */
proc freq data=astma;
tables treatment*discharge / relrisk;
weight antal;
run;



/*Opgave 3*/

data sleep;
input gender$ hrs$ number;
datalines;
1:dreng 1:<7 88
1:dreng 2:7,5 109
1:dreng 3:8 210
1:dreng 4:8,5 324
1:dreng 5:9 359
1:dreng 6:9,5 313
1:dreng 7:10 182
1:dreng 8:>10 85
2:pige 1:<7 92
2:pige 2:7,5 108
2:pige 3:8 217
2:pige 4:8,5 349
2:pige 5:9 436
2:pige 6:9,5 334
2:pige 7:10 198
2:pige 8:>10 65
;
run;


/* Tabeller med udregning af forventede værdier og Chi-squared */
proc freq data=sleep;
tables gender*hrs /
chisq trend nopercent nocol expected;
weight number;
run;
