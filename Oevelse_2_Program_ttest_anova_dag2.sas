
data a1;
infile "http://staff.pubhealth.ku.dk/~lts/basal/data/oeko.txt" URL firstobs=2;
input sas_ansat $ abstid konc ;
/* inddel i 6 grupper, kun vist for 1 eksempel */
if sas_ansat="ja" and abstid=1 then gruppe=1;
run;


/* create new dataset and calculate differences and mean for both methods*/
DATA oeko;
	SET a1;
	logkonc=log10(konc);
RUN;

/* inddel i 6 grupper */
if sas_ansat="ja" and abstid=1 then gruppe=1

/* Histogram over sædkvalitet - dette er egentlig forkert, da jeg ikke behøver at tjekke om HELE populationen er normalfordelt, men snarere den enkelte gruppe */
ods graphics / reset imagename='oeko-konc-hist';
proc sgplot data=oeko;
    histogram konc;
    density konc;
    xaxis labelattrs=(color=blue size=0.8cm);
    yaxis labelattrs=(color=blue size=0.8cm);
run;
ods graphics off;


/* Boxplots før logaritmetransformering*/
proc boxplot data=oeko;
plot konc*sas_ansat;
run;

/* Boxplots efter logaritmetransformering*/
proc boxplot data=oeko;
plot logkonc*sas_ansat;
run;


/*  estimater baseret på sas_ansat (ja/nej)*/
proc means N mean median clm data=oeko;
class sas_ansat;
var konc logkonc;
run;


/* Uparret t-test for at sammenligne logkonc hos sas_ansat (ja/nej) */
proc ttest data=oeko;
class sas_ansat;
var logkonc;
run;
/* Alle svar skal tilbagetransformeres i hånden (eller i R) p<0.05 */


/* Plots for alle grupper */
ods graphics on;
proc glm plots=all data=oeko;
class abstid;
model logkonc=abstid / solution clparm;
run;
ods graphics off;


/* Summary statistics for alle 6 grupper */
PROC MEANS DATA=oeko;
VAR logkonc;
class sas_ansat abstid;
RUN;


/* Boxplot for hver af de 6 grupper (sas_ansat og abstid)  uden at sortere abstid-gruppen*/
proc sgplot data=oeko;
vbox logkonc / category=sas_ansat group=abstid;
run;


/* sortering af abstid-gruppen */
PROC SORT DATA=oeko;
  BY sas_ansat abstid;
  RUN;

/* Boxplot for hver af de 6 grupper (sas_ansat og abstid) */
proc sgplot data=oeko;
vbox logkonc / category=sas_ansat group=abstid;
run;


/* Two way ANOVA - additiv model, dvs uden interaktion*/

ods graphics on;
proc glm plots=all data=oeko;
class sas_ansat abstid;
model logkonc = sas_ansat abstid / solution clparm;
run;
ods graphics off;


/* Two way ANOVA - med interaktion*/
ods graphics on;
proc glm plots=all data=oeko;
class sas_ansat abstid;
model logkonc = sas_ansat abstid sas_ansat*abstid/ solution clparm;
run;
ods graphics off;










/* predikterede vÃ¦rdier fra interaktionsmodel */
data ny;
set ny;
predikteret=10**predikt;
run;
proc sort data=ny;
by sas_ansat abstid;
run;
ods graphics / reset imagename='pred-interaktion';
proc sgplot data=ny; where nr in (13,11,1,148,146,147); 
    series y=predikteret x=abstid / group=sas_ansat;
run;
ods graphics off;

