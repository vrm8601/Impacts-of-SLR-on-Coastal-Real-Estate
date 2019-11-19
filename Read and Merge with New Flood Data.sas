filename RD'C:\Users\vrm8601\Desktop\Datasets';

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



/*********First estimate missing values of APRTOT then 
merge with other tax dataset with zipcodes **************************/

/*Set 0 aprtot to missing so it doesn't affect mean*/
data tax1;
set tax;
if aprtot=0 then aprtot=.;
run;

/*Setting missing aprtot to the mean value by NBHD - have 948 missing still*/
proc sql;
create table tax3 as
	select case
			when aprtot eq . then mean(aprtot)
			else aprtot
			end
			as apr, nbhd,mapid, mapidkey, pid, aprtot, owner_zip,adrstr
	from work.tax1
	group by nbhd
	;
quit;

/* Doing it by street - get 405 missing still*/
/*If we do it just by street and not NBHD first,
there are 314 missing but may not be as accurate*/
proc sql;
create table tax4 as
	select case
			when nbhd='' and aprtot eq . then mean(aprtot)
			else apr
			end
			as apr, nbhd,mapid, mapidkey, pid, aprtot, owner_zip,adrstr
	from work.tax3
	group by adrstr
	;
quit;


/*405 missing still*/
data taxsearch;
set tax4;
where apr=.;
run;

/*Get rid of remaining missing??? I don't know how to estimate them
if there's not a singe APRTOT for a certain NBHD or street*/
data tax5;
set tax4;
if apr=. then delete;
run;
/*now 107842 in data set*/




/*Read in tax data set with zipcodes */
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
select tax4.pid, apr, zipcode
from tax4 right join taxzip
on tax4.pid eq taxzip.pid
;
quit;

data aprcount;
set taxmerge;
where apr=.;
run;
/*562 missing apr now??*/

/*There are some with missing PID - delete??*/
data tax;
set taxmerge;
where pid ne '';
run;

data aprcount;
set tax;
where apr=.;
run;
/*Now still 406 missing apr again*/



/******** Flood Zones Data**************** 37836 observations*/


data flood;
	infile RD('Parcels_in_Zone_VE_and_Coastal_A.txt') dsd firstobs=2;
	input OBJECTID FID_S_FLD_HAZ_AR DFIRM_ID $ VERSION_ID $ FLD_AR_ID: $11.
	STUDY_TYP: $26. FLD_ZONE $ ZONE_SUBTY: $34. SFHA_TF $ STATIC_BFE: 21. V_DATUM $
	DEPTH: 21. LEN_UNIT: $ VELOCITY: 21. VEL_UNIT $ AR_REVERT $ AR_SUBTRV $ BFE_REVERT: 21.
	DEP_REVERT: 21. DUAL_ZONE: $ SOURCE_CIT: $13. OBJECTID:	FID_S_FLD_:	FID_S_FLD1:	
	FID_S_FL_1: FID_S_FL_2:	Shape_Leng:	Shape_Area: FID_PARCEL: 21. FID_ZIPCODE: OBJECT_ID:
	ZIPCODE: FID_par_1: PID: $18. PIN: $16. MAPID: $18. MAPIDKEY: $14. FTR_CODE: $ SUBIDKEY:
	ACRES: 15. GlobalID: $38. Shape_STAr: 23. Shape_STLe: 23. Shape_Length: 17. Shape_Area: 17.;
run;






/*Select just variables we need*/
data flood;
	set flood;
	keep pid fld_zone acres zone_subty;
run;


/* Right join preserves all of flood data and matches with tax*/
proc sql;
create table merge1 as
select tax.pid, apr,zipcode, fld_zone, acres, ZONE_SUBTY
from tax right join flood
on tax.pid eq flood.pid
;
quit;


/*Save permanant data set*/
libname perm 'C:/Users/vrm8601/Desktop/SLR SAS Datasets';
data perm.finalmerge;
set merge1;
run;

libname perm 'C:/Users/vrm8601/Desktop/SLR SAS Datasets';
data final;
set perm.finalmerge;
run;






/****************** Other *******************/
/*See what's still missing*/
data perm.nozipmerge;
set merge;
run;

data mis;
set merge1;
where pid='';
run;

data mis;
set merge1;
where apr=.;
run;


/*Only matches - 37662*/
proc sql;
create table merge as
select tax.pid, apr, fld_zone, acres, zone_subty, fld_zone
from tax join flood
on tax.pid eq flood.pid
;
quit;



