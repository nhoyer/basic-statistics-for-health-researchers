ods graphics on;

data cadmium;
	infile "http://staff.pubhealth.ku.dk/~lts/basal/data/cadmium.txt" URL firstobs=2;
	input group age vitcap;
			if group=1 then fgroup='expo>10';
			if group=2 then fgroup='expo<10';
			if group=3 then fgroup='no-expo';
run;


/*Jeg beregner summary statistics for hver gruppe for sig, der laves boxplots fordi jeg har sat ods graphics til*/
proc means data=cadmium;
	class fgroup;
	var vitcap;
run;


/*One way ANOVA*/
proc glm plots=all data=cadmium;
class fgroup;
model vitcap = fgroup / solution clparm;
run;


/*Lineær regression for gruppen "no-expo"*/
proc glm data=cadmium;
	model vitcap = age / clparm;
	where fgroup='no-expo';
run;


/*Lineær regression for gruppen "expo<10"*/
proc glm data=cadmium;
	model vitcap = age / clparm;
	where fgroup='expo<10';
run;


/*Lineær regression for gruppen "expo>10"*/
proc glm data=cadmium;
	model vitcap = age / clparm;
	where fgroup='expo>10';
run;


/*Lineær regression for alle udnersøgte personer samlet*/
proc glm data=cadmium;
	model vitcap = age / clparm;
run;


/*Model med tilladt interaktion som tester korrelationen mellem alder og vitcap med fgroup som kovariat, og også de enkelte variable*/
proc glm data=cadmium;
	class fgroup;
	model vitcap = age fgroup fgroup*age / solution clparm;
run;	








/*OPGAVE 2*/

data data;
	infile "http://staff.pubhealth.ku.dk/~lts/basal/data/juul2.txt" URL firstobs=2;
	input age height menarche sex igf1 tanner testvol weight;
	logigf1=log10(igf1);
run;


/*Lineær regression for gruppen "1", dvs mænd i tanner stadium 1*/
proc glm data=data;
	model logigf1 = age / clparm;
	where sex=1 and tanner=1;
run;

/*Lineær regression for gruppen "2", dvs kvinder i tanner stadium 1*/
proc glm data=data;
	model logigf1 = age / clparm;
	where sex=2 and tanner=1;
run;

/*Lineær regression som sammneligner de to grupper*/
proc glm data=data;
	model logigf1 = age/ solution clparm;
	where tanner=1;
run;
