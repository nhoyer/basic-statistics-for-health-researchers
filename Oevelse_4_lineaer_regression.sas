/* Hent tekst-filen fra nettet bw=bodyweight rmr=resting metabolic rate derudover angiver i id-nr for alle*/
data metabol;
	infile "http://publicifsv.sund.ku.dk/~lts/basal/data/rmr.txt" URL firstobs=2;
	input bw rmr;
	idnr=_N_; 
run;


/*Create a scatter plot*/
proc sgplot data=metabol;
	scatter x=bw y=rmr;
run;



/*Create a model with raw data, CLPARM ANGIVER AT JEG VIL HAVE CONFIDENSGRÆNSER, estimate angiver at jeg vil kende rmr-værdierne for 70 kg kvinder*/
proc glm data=metabol;
	model rmr = bw / clparm;
	estimate "rmr for kropvægt=70" intercept 1 bw 70;
run;	
/*Fordi konfidensintervaller for 70 kg kvinder ikke overlapper med 70 kg mænd, er der signifikant forskel*/


/*Tegne en regressionslinie*/
proc sgplot data=metabol;
	reg x=bw y=rmr /
		markerattrs=(color=blue) lineattrs=(color=red);
run;			


/*Indtegne konfidensgrænser rlclm=regressionlineconfidenslimitsmean 95%*/
symbol v=circle c=blue i=rlclm95;
proc gplot data=metabol;
	plot rmr*bw;
run;


/*Indtegne smooth line i det samme plot (derfor overlay)*/
symbol2 v=PLUS c=RED i=SM75S;
proc gplot data=metabol;
	plot rmr*bw=1 rmr*bw=2 /overlay;
run;



/*Diagnostic plots for model (label) angiver at jeg vil markere de yderlige punkter*/
ods graphics on;
proc glm plots=(diagnostics(LABEL) residuals(smooth)) data=metabol;
	model rmr = bw /clparm;
run;
ods graphics off;