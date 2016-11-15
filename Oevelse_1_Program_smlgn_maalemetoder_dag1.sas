data lunge;
infile "http://staff.pubhealth.ku.dk/~lts/basal/data/wright.txt" URL firstobs=2;
input wright1 wright2 mini1 mini2;
run;

/* create new dataset and calculate differences and mean for both methods*/
DATA lung1;
	SET lunge;
	difwright=wright2-wright1;
	meanwright=(wright1+wright2)/2;
	difmini=mini2-mini1;
	meanmini=(mini1+mini2)/2;
	dif=meanwright-meanmini;
	mean=(meanwright+meanmini)/2;
RUN;


/* Scatterplot */
PROC SGPLOT DATA=lung1;
  SCATTER X=meanwright Y=difwright;
RUN;

/* Bland-Altman plot wright*/
proc sgplot data=lung1;
	scatter X=meanwright Y=difwright / markerattrs=(color=blue);
	lineparm x=40 y=0 slope=0 / lineattrs=(color=red);
run;


/* Bland-Altman plot mini*/
proc sgplot data=lung1;
scatter X=meanmini Y=difmini / markerattrs=(color=blue);
lineparm x=40 y=0 slope=0 / lineattrs=(color=red);
run;



/* Summary statistics for differencer (for at kunne beregne limits of agreement) */
PROC MEANS DATA=lung1;
VAR difmini difwright;
RUN;



/* histogrammer til check af normalfordelingen af wright*/
ods graphics / reset imagename='wright-dif-hist';
proc sgplot data=lung1;
    histogram difwright;
    density difwright;
    xaxis labelattrs=(color=blue size=0.8cm);
    yaxis labelattrs=(color=blue size=0.8cm);
run;
ods graphics off;

/* histogrammer til check af normalfordelingen af mini*/
ods graphics / reset imagename='mini-dif-hist';
proc sgplot data=lung1;
    histogram difmini;
    density difmini;
    xaxis labelattrs=(color=blue size=0.8cm);
    yaxis labelattrs=(color=blue size=0.8cm);
run;
ods graphics off;





/* fraktildiagrammer til check af normalfordelingen */
ods graphics on / reset imagename='wright-dif-qq';
proc univariate data=lung1;
    var difwright;
    qqplot difwright / normal(mu=est sigma=est color=red)
                  height=3; 
run;
ods graphics off;

ods graphics on / reset imagename='mini-dif-qq';
proc univariate data=lung1;
    var difmini;
    qqplot difmini / normal(mu=est sigma=est color=red)
                  height=3; 
run;
ods graphics off;



/* Scatterplot af differenserne mod hinanden*/
PROC SGPLOT DATA=lung1;
SCATTER X=difmini Y=difwright;
RUN;


/* Bland-Altman plot for de to metoder overfor hinanden */
ods graphics / reset imagename='gnsnit-bland-altman';
proc sgplot data=lung1;
    scatter x=mean y=dif /
    markerattrs=(color=blue size=0.3cm);
    xaxis labelattrs=(color=blue size=0.8cm);
    yaxis labelattrs=(color=blue size=0.8cm);
run;
ods graphics off;


/* Summary statistics for differencer mellem metoderne (for at kunne beregne limits of agreement) */
PROC MEANS DATA=lung1;
VAR dif ;
RUN;



/* T-test for at se, om der er systematisk forskel på de to metoder */
proc ttest data=lung1;
    paired meanwright*meanmini;
run;

proc ttest data=lung1;
    var dif;
run;