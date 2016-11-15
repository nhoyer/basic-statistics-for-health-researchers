/*Indlæser filen*/
data brain;
	infile "http://staff.pubhealth.ku.dk/~lts/basal/data/brain.txt" URL firstobs=2;
	input litter body brain; 
	idnr=_N_; 
run;

/*Slår ODS graphics on, en gang for alle*/
ODS Graphics ON;

/*Create a scatter plot*/
proc sgplot data=brain;
	scatter x=litter y=brain;
run;

/*Create a matrix of scatter plots*/
proc sgscatter data=brain;
	matrix _numeric_ / diagonal=(kernel histogram);
run;


/*Create a model with raw data (brain weight as an effect of litter size), CLPARM ANGIVER AT JEG VIL HAVE CONFIDENSGRÆNSER*/
proc glm data=brain;
	model brain = litter / clparm;
run;

/*Create a model with raw data (brain weight as an effect of body weight), CLPARM ANGIVER AT JEG VIL HAVE CONFIDENSGRÆNSER*/
proc glm data=brain;
	model brain = body / clparm;
run;

/*Create a model with raw data (body weight as an effect of litter size), CLPARM ANGIVER AT JEG VIL HAVE CONFIDENSGRÆNSER*/
proc glm data=brain;
	model body = litter / clparm;
run;

/*calculate correlation between litter and body*/
proc corr pearson spearman data=brain;
var litter body;
run;


/*Create a multivariate model with both body weight and litter size as covariates for the outcome brain size*/
proc glm data=brain;
	model brain = body litter / clparm;
run;







=======================================================================
Spørgsmål 2
=======================================================================
/*Indlæser filen*/
data biomass;
	infile "http://staff.pubhealth.ku.dk/~lts/basal/data/biomasse.txt" URL firstobs=2;
	input sol biomass; 
	idnr=_N_; 
run;

/*Slår ODS graphics on, en gang for alle*/
ODS Graphics ON;

/*Create a scatter plot*/
proc sgplot data=biomass;
	scatter x=sol y=biomass;
run;





/*simpel lineær model over soltimer som kovariat og biomasse som outcome. noint tvinger linien igennem 0,0*/
proc glm data=biomass;
	model biomass = sol / noint clparm;
	estimate "biomass for sol=200" sol 200;
run;
