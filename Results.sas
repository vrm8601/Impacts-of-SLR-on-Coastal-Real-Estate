/*********** Read in Cleaned Data ************/
libname perm 'C:/Users/vrm8601/Desktop/SLR SAS Datasets';

data tax;
set perm.tax;
run;

data combined;
set perm.combined;
run;

data finalmerge;
set perm.finalmerge;
run;

data zip;
set perm.zipreg;
dayssince = intck('day', '01APR1996'd,date);
run;


/******************* Visuals **************/
/*Scatter Plot of ZHVI for each zipcode by date*/
title 'Scatter Plot for ZHVI by Zipcode';
proc sgplot data=zip;
scatter x=date y=zhvi / group=zipcode;
run;





/***************** Predictions *****************/

/* Current Median Value */
proc means data=perm.tax noprint;
class zipcode;
var apr;
output out=currentmed median(apr)=med_pred mean(apr)=mean_pred;/*Not predicted value - just easier later on
if all are named the same thing to compare*/
run;

/* Don't want 28480 since we don't have predictons for that zip code
- will use 28428 as substitution later on */
data currentmed;
set currentmed;
if zipcode=28480 then delete;
run;

proc sql;
create table want as
select a.*, b.med_pred
from tax as a
left join currentmed as b
on a.zipcode=b.zipcode;
quit;



/************** 0 FT SLR ****************/
/* Make all those in 0 ft SLR to 0 value*/
data pred0ft;
set combined;
if dsname='A0'
then ypred=0;
if zipcode=28480 then delete;
run;

/*Count how many parcels are at risk*/
proc sql;
select count(ypred),zipcode
from pred0ft
where ypred=0
group by zipcode
;
run;

/*Stats WITH 0 ft SLR*/
proc means data=pred0ft noprint;
class zipcode;
var ypred;
output out=vars0ft median(ypred)=med_pred mean(ypred)=mean_pred sum(ypred)=totalvalpred0;
run;


/**************** Regression *******************/
data zip1;
set perm.zipreg;
where date gt '01Jan2011'd and date lt '01Jan2018'd and zipcode in ('28401','28403','28405','28429','28449');
run;

proc glm data=zip1;
class zipcode;
model zhvi=date|zipcode/solution;
lsmeans zipcode / diff adjust=tukey;
  ods output ParameterEstimates=pest1;
run;

data zip2;
set perm.zipreg;
where date gt '01JAN2008'd; *28411','28412;
run;

proc glm data=zip2;
class zipcode;
model zhvi=dayssince|zipcode/solution;
lsmeans zipcode / diff adjust=tukey;
  ods output ParameterEstimates=pest2;
run;

data zip3;
set perm.zipreg;
where date gt '01JAN2007'd; /* 28409 and 28428;*/
run;

proc glm data=zip3;
class zipcode;
model zhvi=dayssince|zipcode/solution;
lsmeans zipcode / diff adjust=tukey;
  ods output ParameterEstimates=pest3;
run;


/***************** 2060 ***********************/
data pred1ftbase;
set finalmerge;
if Zipcode=28401
then ypred= (29.2447-13.5656)*14763 - 122737.2286 + 103100;
if Zipcode=28403
then ypred= (29.2447-7.2067)*14763 - 103557.6158 + 187300;
if Zipcode=28405
then ypred= (29.2447-11.0491)*14763 - 88025.6333 + 170000;
if Zipcode=28409
then ypred= (-0.8286+4.6281)*14763 - 133235.6299 + 222600;
if Zipcode=28411
then ypred= (10.0612-0.9103)*14763 - 100145.0082 + 215800;
if Zipcode=28412
then ypred= (10.0612-3.2981)*14763 - 141549.2878 + 179300;
if Zipcode=28428
then ypred= (-0.8286+3.0585)*14763 -114613.8288 + 269900;
if Zipcode=28429
then ypred= (29.2447-16.2618)*14763 -74431.1098 + 124200;
if Zipcode=28449
then ypred= (29.2447)*14763 + 121400.4638 + 303800;
if Zipcode=28480
then ypred= (-0.8286+3.0585)*14763 -114613.8288 + 269900;
run;



/*See 2060 stats without SLR to make comparisons with 1 ft SLR*/
proc means data=pred1ftbase noprint;
class zipcode;
var ypred;
output out=vars60noslr median(ypred)=med_pred mean(ypred)=mean_pred sum(ypred)=totalvalpred;
run;

/* Now applying depreciation to get predictions with affect of SLR*/
/* Make all those in 1 ft SLR to 0 value if 33% or more of parcel in inundated*/
data pred1ft;
set pred1ftbase;
if dsname='A1' and percentage ge 33
then ypred=0;
run;

/*Count how many parcels are at risk*/
proc sql;
create table atrisk1 as
select count(ypred) as atrisk,zipcode
from pred1ft
where ypred=0
group by zipcode
;
run;

/* Total Number of Parcels in each Zipcode*/
proc sql;
create table total as
select zipcode, count(*) from tax
group by zipcode
;
run;

/*Stats WITH 1 ft SLR*/
proc means data=pred1ft noprint;
class zipcode;
var ypred;
output out=vars1ft median(ypred)=med_pred mean(ypred)=mean_pred sum(ypred)=totalvalpred1;
run;


data all;
merge vars60noslr vars1ft total atrisk1;
by zipcode;
if zipcode=. then delete;
format totalvalpred totalvalpred1 med_pred mean_pred dollar20.;
rename _TEMG001=totalparcels totalvalpred=totalValNoSLR totalvalpred1=totalValWith1ft atrisk=numberAtRisk;
drop _FREQ_ _TYPE_;
run;




/********************* 2100 ***********************/
data pred2ftbase;
set finalmerge;
if Zipcode=28401
then ypred= (29.2447-13.5656)*37773 - 122737.2286 + 103100;
if Zipcode=28403
then ypred= (29.2447-7.2067)*37773 - 103557.6158 + 187300;
if Zipcode=28405
then ypred= (29.2447-11.0491)*37773 - 88025.6333 + 170000;
if Zipcode=28409
then ypred= (-0.8286+4.6281)*37773 - 133235.6299 + 222600;
if Zipcode=28411
then ypred= (10.0612-0.9103)*37773 - 100145.0082 + 215800;
if Zipcode=28412
then ypred= (10.0612-3.2981)*37773 - 141549.2878 + 179300;
if Zipcode=28428
then ypred= (-0.8286+3.0585)*37773 -114613.8288 + 269900;
if Zipcode=28429
then ypred= (29.2447-16.2618)*37773 -74431.1098 + 124200;
if Zipcode=28449
then ypred= (29.2447)*37773 + 121400.4638 + 303800;
if Zipcode=28480
then ypred= (-0.8286+3.0585)*37773 -114613.8288 + 269900;
run;



/*See 2100 stats without SLR to make comparisons with 2 ft SLR*/
proc means data=pred2ftbase noprint;
class zipcode;
var ypred;
output out=vars2100NOSLR median(ypred)=med_pred mean(ypred)=mean_pred sum(ypred)=totalvalpred2noslr;
run;



/* Now applying depreciation to get predictions with affect of SLR*/
/* Make all those in 1 ft SLR to 0 value if more than 33% of parcel is inundated*/
data pred2ft;
set pred2ftbase;
if dsname='A2' and percentage ge 33
then ypred=0 ;
run;

/*Count how many parcels are at risk*/
proc sql;
create table risk as
select count(ypred) as numberAtRisk2ft,zipcode
from pred2ft
where ypred=0
group by zipcode
;
run;

/*Stats WITH 2 ft SLR*/
proc means data=pred2ft noprint;
class zipcode;
var ypred;
output out=vars2ft median(ypred)=med_pred mean(ypred)=mean_pred sum(ypred)=totalvalpredwith2;
run;

data all;
merge all risk vars2ft vars2100noslr;
by zipcode;
if zipcode=. then delete;
format totalvalpred totalvalpred2noslr med_pred mean_pred totalvalpredwith2 dollar20.;
rename numberAtRisk=numberAtRisk1ft;
drop _FREQ_ _TYPE_ totalvalpred2 totalvalpred;
run;

data perm.all;
set all;
run;

/*********** Finalized Datasets - Our Predictions and USGS to Compare ****************/
FILENAME REFFILE 'C:/Users/vrm8601/Desktop/comparisons.xlsx';

proc import out = OurPrediction datafile=REFFILE 
            dbms=xlsx;
     sheet="Ours"; 
     getnames=yes;
run;

options validvarname=any;
data ourprediction;
set ourprediction;
drop j k l;
run;


data perm.our;
set ourprediction;
run;


proc import out = ActualPrediction datafile=REFFILE 
            dbms=xlsx;
     sheet="Actual"; 
     getnames=yes;
run;

data perm.actual;
set ActualPrediction;
run;

/******************************** Plots *****************************/
/* Total Value at Risk Grouped by Year then Ziocode*/
proc sgplot data=ours;
vbarparm category=zipcode response= 'Total Value at Risk'n /groupdisplay=cluster group=year;
run;


/* Total Value at Risk Grouped by Zipcode then Year*/
proc sgplot data=ours;
vbarparm category=year response= 'Total Value at Risk'n /groupdisplay=cluster group=zipcode;
run;

/* Number of Homes at Risk Bar Chart */
proc sgplot data=ours;
vbarparm category=year response='Number of Homes at Risk'n / groupdisplay=cluster group=zipcode;
run;

data ours;
set perm.our;
'Percentage at Risk'n='Number of Homes at Risk'n/'Total Parcels'n;
if zipcode=. then delete;
run;

/*Percentage of Total Homes at Risk */
proc sgplot data=ours;
vbarparm category=zipcode response='Percentage at Risk'n / groupdisplay=cluster group=year ;
yaxis label='Percentage of Total Homes at Risk';
run;


