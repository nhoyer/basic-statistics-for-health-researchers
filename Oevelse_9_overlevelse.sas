ods graphics on;

/*Indlæser data*/
data pbc;
	infile "http://publicifsv.sund.ku.dk/~lts/basal/data/pbc.txt" URL firstobs=2;
	input dead months azathiop bilirubin;
	logbilirubin = log2(bilirubin);
run;


/*Kaplan Meier kurver, stratificeret efter azathioprin-behandling*/ 
/*Hvis jeg vil vise censurering, skal jeg bruge en anden procedure: proc lifetest*/
PROC PHREG DATA=pbc PLOTS(OVERLAY=ROW CL)=S;
	MODEL months*dead(0) =;
STRATA azathiop;
BASELINE OUT=km /* Lav datasæt KM til egne plots */
SURVIVAL=KMcurves /* Kaplan-Meier estimat */
LOWER=LowerBound UPPER=UpperBound /* Punktvise konfidensgrænser */
/ METHOD=PL /* Estimeres ved Kaplan & Meier’s Product Limit metode */
CLTYPE=LOGLOG; /* Holder konfidensgrænserne inden for 0-1 */
RUN;


/*Log-rank test for forskel mellem azathioprin vs ikke-azathioprin*/
PROC PHREG DATA=pbc;
MODEL months*dead(0) = azathiop
/ TIES=DISCRETE /* For at beregne log-rank HELT korrekt */
RL=PL; /* Konfidensgrænser p˚a Hazard Ratio */
RUN;
/*det der kommer ud som "Score" er resultatet fra log-rank test*/


/*Tjek om bilirubin eller logbilirubin er normalfordelte*/
proc sgplot data=pbc;
    histogram bilirubin;
    density bilirubin;
    xaxis labelattrs=(color=blue size=0.8cm);
    yaxis labelattrs=(color=blue size=0.8cm);
run;

proc sgplot data=pbc;
    histogram logbilirubin;
    density logbilirubin;
    xaxis labelattrs=(color=blue size=0.8cm);
    yaxis labelattrs=(color=blue size=0.8cm);
run;

proc univariate data=pbc;
    var logbilirubin;
    qqplot logbilirubin 
	/ normal(mu=est sigma=est color=red)
                  height=3; 
run;




/*Jeg inkluderer både den almindelige og den log-transformerede bilirubin i min Cox model*/
PROC PHREG DATA=pbc;
MODEL months*dead(0) = bilirubin logbilirubin;
*- Hvis de ikke er signifikante enkeltvis, kan vi s˚a fjerne begge? p<0,05 betyder at der er signifikant forskel mellem bilirubin og logbilirubin-*;
BeggeUd: TEST bilirubin = logbilirubin = 0;
*- Hvis begge er signifikante, vil vi gerne se, om der er U-form (dette kan ses ved at estimatet for hhv. mindst dbl og størst dbl har forskellig fortegn (ikke situationen her) -*;
ESTIMATE "Mindst dbl" bilirubin 5 logbilirubin 1 / EXP ;
ESTIMATE "Størst dbl" bilirubin 264 logbilirubin 1 / EXP ;
RUN;

/*Jeg prøver også at lave modeller med kun bilirubin eller kun logbilirubin. Det er disse estimater jeg skal bruge i rapporteringen!*/
PROC PHREG DATA=pbc;
MODEL months*dead(0) = bilirubin ;
RUN;

PROC PHREG DATA=pbc;
MODEL months*dead(0) = logbilirubin ;
RUN;

/*Jeg tester om log2bilirubin stadig er signifikant, også når azathioprin også indgår i modellen. Samtidig testes for azathioprins effekt, korrigeret for log2bilirubin*/
PROC PHREG DATA=pbc;
MODEL months*dead(0) = azathiop logbilirubin;
RUN;

/*jeg kan også vælge at azathioprine er en stratificeringsvariabel. Derfor vile den ikke indgå i modellen og der kræves ikke proportionelle rater ift. de andre variable*/
PROC PHREG DATA=pbc;
MODEL months*dead(0) = logbilirubin;
STRATA azathiop;
BASELINE OUT=check LOGLOGS=LCumRate / METHOD=CH; /*Jeg laver et nyt dataset (check) hvor jeg har beregnet den kumulerede rate*/
RUN;


/*Modelkontrol*/
/*Vi definerer nogle parametre til figuren*/
SYMBOL1 C=BLACK V=NONE I=STEPLJ L=1 MODE=INCLUDE;
SYMBOL2 C=RED V=NONE I=STEPLJ L=1 MODE=INCLUDE;
AXIS2 LABEL=(A=90);


*- Først et plot med almindelig lineær tidsakse -*;
PROC GPLOT DATA=check; 
PLOT LCumRate*months=azathiop / VAXIS=AXIS2 NOLEGEND;
RUN;

/* Nye definitioner: Log-skaleret akse*/
AXIS1 LOGBASE=2 
INTERVAL=PARTIAL ; /* Aksen slutter ved den største observerede værdi */

*- S˚a et plot med logaritmisk tidsakse -*;
/*Data logbilirubin er med i den oprindelige model (den jeg har brugt for at beregne LCumRate, er der taget højde for bilirubins effekt*/
PROC GPLOT DATA=check; 
WHERE 0<months; *- Bemærk, at months=0 skal fjernes pga. logaritmen, man kan ikke tage log af 0 -*;
PLOT LCumRate*months=azathiop / HAXIS=AXIS1 VAXIS=AXIS2 NOLEGEND;
GOPTIONS DEVICE=; *- SKAL med for SAS Enterprise, ellers helt unødvendig! -*;
RUN;



