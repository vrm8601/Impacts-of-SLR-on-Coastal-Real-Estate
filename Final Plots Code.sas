
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


