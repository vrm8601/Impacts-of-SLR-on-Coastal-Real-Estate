/* Generated Code (IMPORT) */
/* Source File: our predictions.csv */
/* Source Path: C:/Users/ed2489/Desktop/Datasets */
/* Code generated on: 11/27/19, 9:54 AM */

%web_drop_table(WORK.IMPORT3);


FILENAME REFFILE 'C:/Users/ed2489/Desktop/Datasets/our predictions.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.IMPORT3;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.IMPORT3; RUN;


proc print data=WORK.IMPORT2;
run;
filename RD'C:\Users\ed2489\Desktop\SLR SAS Datasets'; 
proc mapimport out=temp datafile="C:\Users\ed2489\Desktop\zipcode\zipcodes.shp";
select zipcode;
run;

* make ZIP a numeric variable ... look up ZIP on SASHELP.ZIPCODE, keep new hanover county ZIPs;


data newhanover;

set temp;

zip = zipcode;

set sashelp.zipcode (keep=zip state county) key=zip / unique;

run;




proc sgmap mapdata=newhanover maprespdata=med_vars2 noautolegend;

 choromap med_val/ mapid=zipcode id=zipcode name='zipcode' lineattrs=(thickness=0);

 keylegend 'zipcode' / title='Mean value of properties';
run;

title "Number Homes At Risk If RLS 1FT";
proc gmap data=WORK.IMPORT2PROC CONTENTS DATA=WORK.IMPORT2; RUN;


proc print data=WORK.IMPORT2;
run;
filename RD'C:\Users\ed2489\Desktop\SLR SAS Datasets'; 
proc mapimport out=temp datafile="C:\Users\ed2489\Desktop\zipcode\zipcodes.shp";
select zipcode;
run;

* make ZIP a numeric variable ... look up ZIP on SASHELP.ZIPCODE, keep new hanover county ZIPs;


data newhanover;

set temp;

zip = zipcode;

set sashelp.zipcode (keep=zip state county) key=zip / unique;

run;

title "Median Number Homes At Risk If RLS 1FT Or 2Ft";

proc gmap data=WORK.IMPORT2
  map=newhanover;
  id zipcode;
  block 'Homes At Risk'n/ STATISTIC=mean levels=all blocksize=1 relzero cempty=bgr;
run;
quit;

/*  interactive map*/
x 'cd C:\Users\ed2489\Desktop\map';
ods html file='rise1ft.html'; 
title "Home Value loss if sea level rise 1 ft in Each Zipcode";
proc sgmap mapdata=newhanover maprespdata=WORK.IMPORT2;

 choromap 'Homes At Risk'n/ mapid=zipcode id=zipcode  lineattrs=(thickness=1 color=gray);

 keylegend 'zipcode' / title="Value at Risk";
run;
ods html close;
