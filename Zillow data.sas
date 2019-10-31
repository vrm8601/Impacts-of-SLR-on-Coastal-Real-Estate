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
dy=dif('28401'n);
run;


/*Plotting ZHVI for each zipcode by date*/
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




/* Time Series */
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

proc esm data=zip out=predict lead=5;
	id date interval=month;
	forecast '28401'n / model=addwinters;
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




/* Regression */

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

/*Now we need to create 8 dummy variables for the zipcodes since this is our categorical variable*/






