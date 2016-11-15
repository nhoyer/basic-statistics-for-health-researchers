/*Indlæser filen*/
data calcium_raw;
	infile "http://publicifsv.sund.ku.dk/~lts/basal/data/calcium_modi.txt" URL firstobs=2;
	input id treat$ dage bmd1 bmd5; 
run;


/* create new dataset and calculate differences and mean for both methods*/
DATA calcium;
	SET calcium_raw;
	dif=bmd5-bmd1;
	if bmd5<0 then bortfald=1 else bortfald=0;
RUN;

/*Create a scatter plot med forskellige farve for hver behandlingsgruppe*/
proc sgplot data=calcium;
	scatter x=bmd1 y=bmd5 / group=treat;
run;


/* Plots for bmd1 */
ods graphics on;
proc glm plots=all data=calcium;
class treat;
model bmd1=treat / solution clparm;
run;
ods graphics off;


/* Plots for bmd5 */
ods graphics on;
proc glm plots=all data=calcium;
class treat;
model bmd5=treat / solution clparm;
run;
ods graphics off;


/* Plots for dif */
ods graphics on;
proc glm plots=all data=calcium;
class treat;
model dif=treat / solution clparm;
run;
ods graphics off;


/* Summary statistics for begge grupper */
PROC MEANS DATA=calcium;
VAR bmd1;
class treat;
RUN;

/*Uparret t-test*/
proc ttest data=calcium;
    var bmd5;
	class treat;
run;

/*Tegne to regressionslinier oveni et scatterplot*/
proc sgplot data=calcium;
reg x=bmd1 y=bmd5 / group=treat;
run;


/* ANCOVA med baseline værdierne som kovariat*/
proc glm data=calcium;
class treat;
model bmd5=treat bmd1 / solution clparm;
estimate "bmd5 for en behandlet pige med bmd1=0.8" intercept 1 treat 1 0 bmd1 0.8;
run;

/*ANCOVA for at beregne gennemsnittet for samme baseline værdier, inklusive diagnostics panel*/
ods graphics on;
proc glm plots=(DiagnosticsPanel Residuals(smooth)) data=calcium;
class treat;
model bmd5 = bmd1 treat / solution clparm;
output out=ny p=yhat r=residual cookd=cook;
run;
ods graphics off;

/*Differensen for hver pige ved en t-test*/
proc ttest data=calcium;
    var dif;
	class treat;
run;

/*Analysen af hældningen i hver gruppe for sig*/
proc sort data=calcium; by treat;
run;
ods graphics on;
proc glm plots=all data=calcium; by treat;
model bmd5=bmd1 / clparm;
estimate "bmd1=0,8" intercept 1 bmd1 0.8;
run;
ods graphics off;