filename RD'C:\Users\vrm8601\Desktop\Datasets'; 
/*Change path to where .txt datasets are on your computer*/


/*************** New Hanover County Tax Parcel Data ***************/
data tax;
  infile RD('Tax_Parcel_data.txt') dsd firstobs=2;
  input OID_: MAPID: $18. MAPIDKEY: $14. PID: $18. CUR:$ OWNDAT_TAX: OWNONE: $50. 
  OWNER_NUM: OWNER_STRE: $20. OWNER_ST_1 : $ OWNER_DIR : $ OWNER_UNIT: $ 
  OWNER_UN_1 : $ OWNER_CITY: $20. OWNER_STAT: $ OWNER_ZIP: $ OWNER_COUN: $ OWNER_ADDR: $ 
  OWNER_AD_1 : $ OWNER_AD_2 : $ ADRNO ADRADD$ UNITNO$ ADRSTR$ ADRSUF$ ADRDIR $
  CITYNAME: $10. SUBDIV: $15. ACRES: 17. LEGALONE : $40.
  PAR_PARID: $18. PARDAT_TAX MUNI$ NBHD$ ZONING$ LUC$ CLASS$ R_CARD C_CARD SFLA AREASUM
  APRVAL_TAX APRLAND APRBLDG APRTOT OBYVAL: SALE_DATE: $16. SALE_INSTR:$ SALE_BOOK$
  SALE_PAGE $ SALE_PRICE XCOORD YCOORD;
run; 



/*******************  Tax Data Cleaning **********************/

*First estimate missing values of APRTOT (Appraised Total Value) then 
merge with other tax dataset with zipcodes;
/*Set 0 APRTOT to missing so it doesn't affect mean*/
data tax1;
set tax;
if aprtot=0 then aprtot=.;
run;

/*Setting missing aprtot to the median value of it byneighborhood 
- have 948 missing still*/
/*APR is our new estimated value. It is equal to APRTOT unless APRTOT is missing,
then we assign the median value of ARPTOT for the neighborhood*/

proc sql;
create table tax3 as
	select case
			when aprtot eq . then median(aprtot)
			else aprtot
			end
			as apr, nbhd,mapid, mapidkey, pid, aprbldg, aprtot, adrstr, class, acres
	from work.tax1
	group by nbhd
	;
quit;

/* Doing it by street - get 405 missing still*/
*If we do it just by street and not NBHD first,
there are 314 missing but may not be as accurate, 
so run above code first then this part;
proc sql;
create table tax4 as
	select case
			when nbhd='' and aprtot eq . then median(aprtot)
			else apr
			end
			as apr, nbhd,mapid, mapidkey, pid, aprbldg, aprtot, adrstr, class, acres
	from work.tax3
	group by adrstr
	;
quit;


/*405 missing APR still*/
data taxsearch;
set tax4;
where apr=.;
run;

/*Get rid of remaining missing??? I don't know how to estimate them
if there's not a singe APRTOT value for a certain neighborhood or street*/
data tax5;
set tax4;
if apr=. then delete;
run;
/*now 107842 records in data set*/




/********** Read in tax data set with zipcodes ***********/
data taxzip;
  infile RD('all_parcels_with_zipcodes.csv') dsd firstobs=2;
  input OID_: FID : OBJECTID : Zipcode : SHAPE_area : 11. SHAPE_len : 11. 
  FID_parcel : PID: $18. PIN : $16. MAPID: $18. MAPIDKEY: $14. FTR_CODE : $ 
  SUBIDKEY : ACRES :11. GlobalID :$38.
  Shape_STAr : 12. Shapre_STLe: 12.;
run; 
/* Merge both tax data sets to get zipcode and aprtot together */
proc sql;
create table taxmerge as
select tax4.pid, apr, zipcode, aprbldg, class, taxzip.acres
from tax4 right join taxzip
on tax4.pid eq taxzip.pid
;
quit;

/*See how many still missing*/
data aprcount;
set taxmerge;
where apr=.;
run;
/*562 missing apr now*/

/*There are some with missing PID - delete???*/
data tax;
set taxmerge;
where pid ne '';
run;

data aprcount;
set tax;
where apr=.;
run;
/*Now still 406 missing apr again*/

/**** Save permanent dataset so don't have to rerun all above code again ***/
libname perm 'C:/Users/vrm8601/Desktop/SLR SAS Datasets';
/*Change path to where you want the dataset to be saved on your computer*/
data perm.tax;
set tax;
run;






/********** 0-10 Ft SLR Elevations ************/

/*0 foot SLR*/
data A0;
	infile RD('Parcels_SLR_0ft.txt') dsd firstobs=2;
	input FID FID_zipcod OBJECTID ZIPCODE FID_parcel PID: $18. PIN: $16.
	MAPID: $18. MAPIDKEY: $14. FTR_CODE: $ SUBIDKEY: ACRES: 15. 
	GlobalID: $38. Shape_STAr: 23. Shape_STLe: 23. Shape_Leng: 17. 
	Shape_Area: 17.;
run;

/*1 foot SLR*/
data A1;
	infile RD('Parcels_SLR_1ft.txt') dsd firstobs=2;
	input FID FID_zipcod OBJECTID ZIPCODE FID_parcel PID: $18. PIN: $16.
	MAPID: $18. MAPIDKEY: $14. FTR_CODE: $ SUBIDKEY: ACRES: 15. 
	GlobalID: $38. Shape_STAr: 23. Shape_STLe: 23. Shape_Leng: 17. 
	Shape_Area: 17.;
run;

data A1;
set A1;
shape_acres=2.29568e-5*Shape_Area;
if acres ne 0
then percentage=(shape_acres/acres)*100;
run;


data A2;
set A2;
shape_acres=2.29568e-5*Shape_Area;
if acres ne 0
then percentage=(shape_acres/acres)*100;
run;



/*2 foot SLR*/
data A2;
	infile RD('Parcels_SLR_2ft.txt') dsd firstobs=2;
	input FID FID_zipcod OBJECTID ZIPCODE FID_parcel PID: $18. PIN: $16.
	MAPID: $18. MAPIDKEY: $14. FTR_CODE: $ SUBIDKEY: ACRES: 15. 
	GlobalID: $38. Shape_STAr: 23. Shape_STLe: 23. Shape_Leng: 17. 
	Shape_Area: 17.;
run;


/*Now stack all datasets together and create variable for what level of SLR
(A0 is 0 ft ... A10 is 10 ft)*/
data Combined2;
set A0-A2 indsname = source;  /* the INDSNAME= option is on the SET statement */
libref = scan(source,1,'.');  /* extract the libref */
dsname = scan(source,2,'.');  /* extract the data set name */
run;


/*Save permanent dataset */
data perm.combined;
set Combined2;
run;


data combined;
set perm.combined;
run;



/**** Merge tax and 0-10 ft SLR data ****/
proc sql;
create table finalmerge as
select combined.pid, apr,combined.zipcode, combined.acres, dsname, class, aprbldg, percentage
from tax right join combined
on tax.pid eq combined.pid
;
quit;

/* Save permanent dataset for future use */
data perm.finalmerge;
set finalmerge;
run;





/* For new SAS Session Run this code to get datasets*/
libname perm 'C:/Users/vrm8601/Desktop/SLR SAS Datasets';

data tax;
set perm.tax;
run;


proc sql;
create table count as
select count(*),zipcode from tax
group by zipcode;
quit;



data combined;
set perm.combined;
run;

data finalmerge;
set perm.finalmerge;
run;


/***************** Predictions *****************/

/* Current Median Value */
proc means data=perm.tax noprint;
class zipcode;
var apr;
output out=currentmed median(apr)=med_pred mean(apr)=mean_pred;/*This is not a predicted value but 
I just named it this so it's easier to plot things later if the median values 
have the same name*/
run;

/* Don't want 28480 since we don't have predictons for that zip code
and I don't want it to be included in the plot later */
data currentmed;
set currentmed;
if zipcode=28480 then delete;
run;

/* Was going to use this output dataset for macros but never did */
proc sql;
create table want as
select a.*, b.med_pred
from tax as a
left join currentmed as b
on a.zipcode=b.zipcode;
quit;




/********************* Predictions *************************/
*y_pred=(B_1+B_3)∗date_new + B_2 + y_median −(B_1+B_3)*date_old − B_2

date_old=8310 which is the number of days between April 4,1996 to June 1, 2019 
(the days since the first zillow date to our data's date)

date_new=14,824 which is the number of days between June 1, 2019 (our data's date) and
January 1, 2060 for the 1 ft SLR

191254.2053 old intercept - don't need

y_median is the median home value for the specific zipcode we are estimating
B_1 = 765.940, the parameter estimate for dayssince alone
B_2 is the parameter estimate for the zipcode alone
B_3 is the parameter estimate for zipcode*dayssince, so is 
different for each zipcode 
These estimates can be found in the Zillow code by running the glm procedure
at the very end;


/* Make all those in 0 ft SLR to 0 value*/
data pred0ft;
set combined;
if dsname='A0'
then ypred=0;
if zipcode=28480 then delete;
run;

/*Count how many parcels are at risk for 0 FT SLR*/
proc sql;
select count(ypred),zipcode
from pred0ft
where ypred=0
group by zipcode
;
run;



*y_pred=(B_1+B_3)∗date_new + B_2 + y_median −(B_1+B_3)*date_old − B_2;
/*date_new = 14824, the number of days between August 1, 2019 and January 1, 2060
date_old=8522, the number of days between April 1, 1996 to August 1, 2019 */
/* This is the baseline prediction for 2060 - NOT including depreciation from SLR*/
data pred1ftbase;
set finalmerge;
if Zipcode=28401
then ypred= zipcode-est*14824 + date-est*14848 + 103100
if Zipcode=28403
then ypred= (765.940+12.100)*14824 - 395884.038 + 187300 - (765.940+12.100)*8522;
if Zipcode=28405
then ypred= (765.940-182.545)*14824 + 176545.993 + 170000 - (765.940-182.545)*8522;
if Zipcode=28409
then ypred= (765.940-349.703)*14824 + 838039.542 + 222600 - (765.940-349.703)*8522;
if Zipcode=28411
then ypred= (765.940-368.579)*14824 + 907581.154 + 215800 - (765.940-368.579)*8522;
if Zipcode=28412
then ypred= (765.940-366.365)*14824 + 813260.731 + 179300 - (765.940-366.365)*8522;
if Zipcode=28428
then ypred= (765.940-56.735)*14824 - 22727.305 + 269900 - (765.940-56.735)*8522;
if Zipcode=28429
then ypred= (765.940-348.332)*14824 + 730507.516 + 124200 - (765.940-348.332)*8522;
if Zipcode=28449
then ypred= (765.940)*14824 - 1818371.181 + 303800 - (765.940*8522);
run;

/*See 2060 stats without SLR to make comparisons with 1 ft SLR*/
proc means data=pred1ftbase noprint;
class zipcode;
var ypred;
where zipcode ne 28480;
output out=vars60noslr median(ypred)=med_pred mean(ypred)=mean_pred sum(ypred)=totalvalpred;
run;

/* Now applying depreciation to get predictions with affect of SLR*/
/* Make all those in 1 ft SLR to 0 value*/
data pred1ft;
set pred1ftbase;
if dsname='A1'
then ypred=0;
if zipcode=28480 then delete;
run;

/*Count how many parcels are at risk*/
proc sql;
select count(ypred),zipcode
from pred1ft
where ypred=0
group by zipcode
;
run;

/*Stats WITH 1 ft SLR*/
proc means data=pred1ft noprint;
class zipcode;
var ypred;
output out=vars1ft median(ypred)=med_pred mean(ypred)=mean_pred sum(ypred)=totalvalpred1;
run;





/* For 2 ft SLR - year 2100*/
/*Now date_now =29373, the number of days between August 1,2019 to January 1,2100*/
/* This is the baseline prediction for 2100 - NOT including depreciation from SLR*/
data pred2ftbase;
set finalmerge;
if Zipcode=28401
then ypred= (765.940-249.684)*29373 + 397082.048 + 103100 - (765.940-249.684)*8522;
if Zipcode=28403
then ypred= (765.940+12.100)*29373 - 395884.038 + 187300 - (765.940+12.100)*8522;
if Zipcode=28405
then ypred= (765.940-182.545)*29373 + 176545.993 + 170000 - (765.940-182.545)*8522;
if Zipcode=28409
then ypred= (765.940-349.703)*29373 + 838039.542 + 222600 - (765.940-349.703)*8522;
if Zipcode=28411
then ypred= (765.940-368.579)*29373 + 907581.154 + 215800 - (765.940-368.579)*8522;
if Zipcode=28412
then ypred= (765.940-366.365)*29373 + 813260.731 + 179300 - (765.940-366.365)*8522;
if Zipcode=28428
then ypred= (765.940-56.735)*29373 - 22727.305 + 269900 - (765.940-56.735)*8522;
if Zipcode=28429
then ypred= (765.940-348.332)*29373 + 730507.516 + 124200 - (765.940-348.332)*8522;
if Zipcode=28449
then ypred= (765.940)*29373 - 1818371.181 + 303800 - (765.940*8522);
run;


/*See 2100 stats without SLR to make comparisons with 2 ft SLR*/
proc means data=pred2ftbase noprint;
class zipcode;
where zipcode ne 28480;
var ypred;
output out=vars2100NOSLR median(ypred)=med_pred mean(ypred)=mean_pred sum(ypred)=totalvalpred2;
run;



/* Now applying depreciation to get predictions with affect of SLR*/
/* Make all those in 1 ft SLR to 0 value*/
data pred2ft;
set pred2ftbase;
if dsname='A2'
then ypred=0;
if zipcode=28480 then delete;
run;

/*Count how many parcels are at risk*/
proc sql;
select count(ypred),zipcode
from pred2ft
where ypred=0
group by zipcode
;
run;

/*Stats WITH 2 ft SLR*/
proc means data=pred2ft noprint;
class zipcode;
var ypred;
output out=vars2ft median(ypred)=med_pred mean(ypred)=mean_pred sum(ypred)=totalvalpred2;
run;



/* Instead of combining the stats in each case and calculating the total value at 
risk here I just did it in excel */



/* Plot with SLR */
/*Stack the three output stat datasets (ones including depreciation)*/
data plotslr;
set currentmed vars1ft vars2ft indsname = source;  /* the INDSNAME= option is on the SET statement */
dsname = scan(source,2,'.');
if dsname='CURRENTMED'
then date='01jun19'd;
if dsname='VARS1FT'
then date='01jan2060'd;
if dsname='VARS2FT'
then date='01jan2100'd;
format date YEAR4.;
run;


proc sgplot data=plotslr;
vbar date /response=mean_pred group=zipcode groupdisplay=cluster;
xaxis label='Date';
yaxis label='Median Home Value';
run;


/* Plot without SLR */
/*Stack the three output stat datasets (ones NOT including depreciation)*/
data plotnoslr;
set currentmed vars60noslr vars2100NOSLR indsname = source;  /* the INDSNAME= option is on the SET statement */
dsname = scan(source,2,'.');
if dsname='CURRENTMED'
then date='01jun19'd;
if dsname='VARS60NOSLR'
then date='01jan2060'd;
if dsname='VARS2100NOSLR'
then date='01jan2100'd;
format date YEAR4.;
run;


proc sgplot data=plotnoslr;
vbar date /response=mean_pred group=zipcode groupdisplay=cluster;
xaxis label='Date';
yaxis label='Median Home Value';
run;

/* The differences are so small that you can't really even tell they're different
So I guess I'll plot the total value at risk */