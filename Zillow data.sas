/**************** Zillow Data *******************/
/* Import file */
FILENAME REFFILE 'C:/Users/vrm8601/Desktop/Datasets/Zip_Zhvi_AllHomes.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.IMPORT;
	GETNAMES=YES;
RUN;

data m;
set import;
run;



/******************** Data Cleaning ************************/
/*Just want zipcodes in NHC and don't need other variables */
data zip;
set import;
drop city metro regionid state countyname metro sizerank;
where regionname in (28401,28403,28405,28407,28409,28411,28412,28428,28429,28449);
run;

/*Transpose to make zipcodes the columns */
proc transpose data=zip out=temp;
run;

/*Rename columns to zipcode */
data zip;
set temp (firstobs=2);
rename _NAME_=Date COL1='28412'n COL2='28403'n 
COL3='28411'n COL4='28405'n COL5='28409'n COL6='28401'n 
COL7='28428'n COL8='28429'n COL9='28449'n;
run;

/* Get date variable to be recognized as a date in SAS */
/* Remove hyphen and underscore */
data zip1;
set zip;
date1=substr(date,2);
date2=compress(date1,'-');
drop date;
run;

/* Assign format */
data zip;
set zip1;
date=input(date2,yymmn6.);
format date monyy.;
run;





/*************** Saving Cleaned Data Set ***********/
/*Save permanant data set */
libname perm 'C:/Users/vrm8601/Desktop/SLR SAS Datasets';
data perm.zillow;
set zip;
run;

/* Call in data set when opening 
new SAS session so that previous code doesn't have to be run*/
libname perm 'C:/Users/vrm8601/Desktop/SLR SAS Datasets';
data zip;
set perm.zillow;
*dy=dif('28401'n);
run;



/******************* Visuals **************/
/*Scatter Plot of ZHVI for each zipcode by date*/
title 'Scatter Plot for ZHVI by Zipcode';
proc sgplot data=zip;
scatter x=date y='28401'n ;
scatter x=date y='28403'n ;
scatter x=date y='28405'n ;
scatter x=date y='28409'n ;
scatter x=date y='28411'n ;
scatter x=date y='28412'n ;
scatter x=date y='28428'n ;
scatter x=date y='28429'n ;
scatter x=date y='28449'n ;
yaxis label='ZHVI';
run;

/* Box and Whisker Plot */
title "ZHVI by Zipcode";
proc sgplot data=zipreg;
   vbox zhvi / category=zipcode;
   xaxis label="Zipcode";
run;






/********************** Time Series ********************8*/
/*Above is the time series plot fo raw ZHVI*/

/*Making data stationary*/
/*ADF test */
proc autoreg data = zip;
   model '28401'n = / stationarity =(adf =3); 
run;

proc sgplot data=zip;
scatter x=date y='28401'n ;
run;

/*Using difference in response to remove trend */
proc autoreg data=zip;
   model dy = / nlag=1 method=ml;
run;

proc sgplot data=zip;
scatter x=date y=dy ;
run;

/* Build time series model */
/* Establish a base level forecast */
proc esm data=zip out=predict lead=100;
	id date interval=month;
	forecast '28401'n / model=multseasonal;
run;

proc sgplot data=predict;
	series x=date y='28401'n / markers markerattrs=(symbol=cirlcefilled color=red)
								lineattrs=(color=red);
	refline '01AUG2019'd	/ axis=x;
	yaxis label='ZHVI';
run;	


/* arima */
proc arima data=zip ;
   identify var='28401'n nlag=120;
run;

proc arima data = zip;
identify var = '28401'n(1) nlag = 20 ;
estimate p = 1  q = 1;
run;

proc arima data = zip;
identify var = '28401'n(1) nlag = 20 ;
estimate p = 1  q = 1;
forecast lead=12 interval=month id=date out=results;
quit;










/******************* Regression *******************8**/
/*Need to rearrange dataset so that all ZHVI are one column, with a new column 
for the zipcode - This way zipcode and date can be predictors in regression model*/
proc sort data=zip out=temp;
	by date;
run;

data temp;
	set temp;
	obs=_n_;
run;

proc transpose data=temp out=stacked (rename=(col1=ZHVI)) name=zipcode;
	var '28412'n '28411'n '28403'n '28405'n '28409'n '28401'n '28428'n '28429'n 
		'28449'n;
	by obs date;
run;

proc delete data=temp;
run;

/*Want to make date as the days since so the results can be interpretted more easily */
data zipd;
set stacked;
dayssince = intck('day', '01APR1996'd,date);
run;

data new;
set zipd;
z28401=0;z28403=0;z28405=0;z28409=0;z28411=0;z28412=0;z28428=0;z28429=0;z28449=0;
select (zipcode);
when ('28401') z28401=1;
when ('28403') z28403=1;
when ('28405') z28405=1;
when ('28409') z28409=1;
when ('28411') z28411=1;
when ('28412') z28412=1;
when ('28428') z28428=1;
when ('28429') z28429=1;
when ('28449') z28449=1;
otherwise do;
z28401=.;z28403=.;z28405=.;z28409=.;z28411=.;z28412=.;z28428=.;z28429=.;z28449=.;
end;
end;
run;



/* Save Data Set */
libname perm 'C:/Users/vrm8601/Desktop/SLR SAS Datasets';
data perm.zipreg;
set zipd;
run;

/* Call in data set for new sessions*/
libname perm 'C:/Users/vrm8601/Desktop/SLR SAS Datasets';
data new;
set perm.zipreg;
run;


/******* Fitting a Model *******/
ods graphics off;
proc reg data=new;
model zhvi= dayssince z28401 z28403 z28405 z28409 z28411 z28412 z28428 z28449 z28429 / noint;
output out=predictions predicted=pred lcl=lower ucl=upper;
run;


ods graphics off;
proc reg data=new plots=all;
model zhvi= dayssince z28401 z28403 z28405 z28409 z28411 z28412 z28428 z28449 z28429;
output out=predictions predicted=pred lcl=lower ucl=upper;
run;

ods graphics;
proc glm data=new plots=diffplot;
model zhvi= date z28401 z28403 z28405 z28409 z28411 z28412 z28428 z28449 z28429; /* these options after the '/' are to show predicte values in results screen - you don't need it */
output out=preddata predicted=pred lcl=lower ucl=upper ; /* this line creates a dataset with the predicted value for all observations */
store reg;
run;
quit;


proc glm data=zipd;
class zipcode;
model zhvi=dayssince;
run;


proc glm data=new;
class zipcode;
model zhvi=dayssince|zipcode/solution;
run;


/*I think this is the best I've got so far but not sure if we should be using linear regression 
and we may need to dummy encode zipcode since it's nominal*/
proc glm data=new;
class zipcode;
model zhvi=dayssince|zipcode/solution;
lsmeans zipcode / diff adjust=tukey;
run;

























/******************** Old May Use Later **************/
/*zipcode is a character variable - we need to make it numeric
and save permanant data set for future reference */
/*data perm.stacked;
set stacked;
zip=input(zipcode,8.);
drop zipcode;
rename zip=zipcode;
run;*/

proc univariate data=stacked;
  ods output BasicMeasures=varinfo;
run;
proc sort data=varinfo;
  by varName;
proc print data=varinfo noobs;
  by varName;
  where varName in ('date', 'zipcode', 'zhvi');
run;






