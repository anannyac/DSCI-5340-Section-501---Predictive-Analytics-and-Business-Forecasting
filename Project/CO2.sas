FILENAME REFFILE '/home/u49607241/Assignment_Tejdeep/GLB.Ts+dSST.csv';

/*
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.IMPORT3;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; RUN;
*/

/* Durbin Watson Test*/
proc reg data=WORK.IMPORT3;
	model CO2= / dw;
run;
quit;


/* Linear Regression Y=mX+C */
proc reg data=WORK.IMPORT3 alpha=0.05 plots(only)=(diagnostics residuals fitplot 
		observedbypredicted);
	model CO2=Date /;
	run;
quit;


/* Linear Regression Y=m1 X+m2 X^2 + C */
proc glmselect data=WORK.IMPORT;
	model CO2=Date Date*Date / showpvalues selection=none;
run;

proc reg data=WORK.IMPORT3 alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model CO2=&_GLSMOD /;
	run;
quit;

/* ARIMA Exploratory Analysis to find p,d,q */	
proc sort data=WORK.IMPORT3;
	by Date;
run;

proc timeseries data=WORK.IMPORT3 seasonality=12 plots=(series 
		histogram cycles corr);
	id Date interval=month;
	var CO2 / accumulate=none transform=none dif=0 sdif=0;
run;


/* ARIMA Prediction using defined p,d,q */
ods noproctitle;
ods graphics / imagemap=on;
proc arima data=WORK.IMPORT3 plots
    (only)=(series(corr crosscorr) residual(corr normal) 
		forecast(forecast forecastonly));
	identify var=CO2(1);
	estimate p=(1 2) q=(1) method=ML;
	forecast lead=12 back=0 alpha=0.05 id=Date interval=month;
	outlier;
	run;
quit;


