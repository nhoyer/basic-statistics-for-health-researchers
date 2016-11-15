ods graphics on;

/*Dollartegn er egnetlig kun vigtig hvis selve data indeholder BOGSTAVER. Det er ok at beholde dem som numeriske, hvis bare 1/0*/
data gvhd;
	infile "http://publicifsv.sund.ku.dk/~lts/basal/data/gvhd.txt" URL firstobs=2;
	input pnr rcpage donage type$ preg index gvhd$;
			if type=1 then ftype='AML';
			if type=2 then ftype='ALL';
			if type=3 then ftype='CML';
			if type=1 OR type=2 then kronisk=0;
			if type=3 then kronisk=1;
			if type=1 OR type=3 then lymfatisk=0;
			if type=2 then lymfatisk=1;
			lindex=log2(index);
			
run;

/* Tabeller med udregning af forventede værdier og Chi-squared */
proc freq data=gvhd;
tables ftype*gvhd /
chisq fisher nopercent nocol expected;
run;



/*Skrabet logistisk regression*/
proc logistic data=gvhd;
class type / ref=first param=glm;
model gvhd (event="1")= rcpage donage type preg lindex;
run ;

/*Vi fjerner rcpage (højest p-værdi)*/
proc logistic data=gvhd;
class type;
model gvhd (event="1")= donage type preg lindex;
run ;

/*Vi fjerner donage (højest p-værdi)*/
proc logistic data=gvhd;
class type;
model gvhd (event="1")= type preg lindex;
run ;


/*Skrabet logistisk regression med lymfatisk vs myeloid og akut vs kronisk. Class angiver hvilke variabel SAS skal se som kategoriske*/
proc logistic data=gvhd;
class kronisk lymfatisk preg;
model gvhd (event="1")= rcpage donage kronisk lymfatisk preg lindex;
run ;


/*Vi fjerner alder*. REF=first angiver at vi har 0 som reference*/
proc logistic data=gvhd;
class kronisk lymfatisk preg /REF=first;
model gvhd (event="1")=  kronisk lymfatisk preg donage lindex;
run ;


/*Vi fjerner donage*/
proc logistic data=gvhd;
class kronisk lymfatisk preg /REF=first;
model gvhd (event="1")=  kronisk lymfatisk preg lindex;
run ;


/*Vi fjerner lindex*/
proc logistic data=gvhd;
class kronisk lymfatisk preg /REF=first;
model gvhd (event="1")=  kronisk lymfatisk preg;
run ;



/*Er der interaktion? param=glm angiver at jeg får estimater for alle 3 grupper i type (og ikke kun de ikke-reference)*/
proc logistic data=gvhd;
class kronisk lymfatisk preg /REF=first PARAM=glm;
model gvhd (event="1")=  kronisk lymfatisk preg rcpage donage lindex lindex*preg;
run ;





ods graphics off;