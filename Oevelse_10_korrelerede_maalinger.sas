ods graphics on;

/*Indlæser data*/
data swabs;
	infile "http://publicifsv.sund.ku.dk/~lts/basal/data/swabs.txt" URL firstobs=2;
	input crowding$ family name$ swabs;
run;


/*Create a scatter plot med forskellige farver for hver gruppe af crowding*/
proc sgplot data=swabs;
	scatter x=family y=swabs / group=crowding;
run;

proc sgpanel data=swabs;
panelby=crowding;
series  x=name  y=swabs/ group=family;
run;



/*Varianskomponentmodel med rabbit som random variabel*/
/*s står for solution og bevirker, at man får parameterestimater*/
/*cl betyder, at man også gerne vil have konfidensintervaller på estimaterne*/
proc mixed plots=all data=swabs;
class family crowding name;						
model swabs = crowding name / ddfm=kr s cl outpm=predm outp=predi;	/*Jeg gemmer outputtet i et nyt dataset "predm"*/
random family; 														/*family kan ikke både være med i modellen (fixed effect) og som random*/
estimate "child1 vs child3" name -1 0 1 0 0 / cl;
run;


/*I stedet for estimate sætning, kan jeg også angive hvilken værdi jeg vil have som reference: ved at skrive i class linien: 
name(ref="child1")*/

/*Jeg undersøger for interaktion*/
proc mixed plots=all data=swabs;
class family crowding name;						
model swabs = crowding name crowding*name / ddfm=kr s cl;	
random family; 													
run;

/*Jeg kan sortere datasettet, så SAS ikke tegner flere linier for hver gruppe*/
/*proc sort data=predm;*/
/*by crowding name;*/
/*run;*/

/*Alternativt kan jeg bare vælge en familie i hver kategori af crowding*/
proc sgplot data=predm; 
where family in (1,7,13);
series Y=Pred X=name / group=crowding;
run;
