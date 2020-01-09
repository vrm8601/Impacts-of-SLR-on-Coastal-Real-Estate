/******************* Visuals **************/


proc print data=zippredi.zippre1;
run;

data zippre2;
set zippredi.zippre1;
if year="" then delete;
run;
proc sgplot data=zippre2;
 vbar year/response='value at risk'n group='zip code'n  groupdisplay=cluster;
 yaxis valuesformat=dollar30.;
run;

proc sgplot data=zippre2;
 vbar year/response='Property Tax at Risk'n group='zip code'n  groupdisplay=cluster;
 yaxis valuesformat=dollar30.;
run;

proc sort data=zippre2 out=zippre3;
  by 'year'n;
run;



/* Define the template for the graphs */
proc template;
  define statgraph graptemple;
    dynamic _BYVAL_;
    begingraph;
      entrytitle "Years Of New Hanover County " _BYVAL_;
      layout overlay / cycleattrs=true
        xaxisopts=(label="zipcode")
        yaxisopts=(label="Property Tax at Risk" griddisplay=on
          gridattrs=(color=lightgray pattern=dot)
          linearopts=(tickvaluesequence=(start=0 end=90000000
            increment=1000000) tickvaluepriority=true));
        barchart x='zip code'n  y='Value at Risk'n /
          discreteoffset=-0.1 barwidth=0.8 tip=(Y) TIPFORMAT=(Y=DOLLAR20.);
        discretelegend "Year";
      endlayout;
    endgraph;
  end;
run;

/* Create a file reference for the printer output */
filename prtout "anim1.svg"; /* Specify the output filename */

/* Set the system animation options */
options printerpath=svg /* Specify the SVG universal printer */
  nonumber nodate /* Suppress the page number and date */
  animduration=3  /* Wait 3 seconds between graphs */ 
  animloop=yes    /* Play continuously */
  noanimoverlay   /* Display graphs sequentially */
  svgfadein=1     /* One-second fade-in for each graph */
  svgfadeout=1    /* One-second fade-out for each graph */
  nobyline;       /* Suppress the BY-line */

/* Close all currently open ODS destinations */
ods _all_ close;

/* Start the animation output */
options animate=start;

/* Clear the titles and footnotes */
title;
footnote;

/* Open the ODS PRINTER destination */
ods printer file=prtout style=htmlblue;

/* Generate the graphs */
proc sgrender data=zippre3 template=graptemple;
  by 'year'n;
run;

/* Stop the animation output */
options animate=stop;

/* Close the ODS PRINTER destination */
ods printer close;

/* Open an ODS destination for subsequent programs */
ods html; /*Not required in SAS Studio */
  

  

