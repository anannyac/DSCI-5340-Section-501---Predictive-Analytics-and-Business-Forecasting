FILENAME REFFILE '/home/u49607241/Assignment_Tejdeep/GLB.Ts+dSST.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.IMPORT3;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.IMPORT3; RUN;

proc sort data=WORK.IMPORT3 out=Work.preProcessedData;
	by Date;
run;

proc timeseries data=Work.preProcessedData seasonality=12 plots=(series 
		histogram cycles corr);
	id Date interval=month;
	var CO2 / accumulate=none transform=none dif=0 sdif=0;
run;

proc sort data=WORK.IMPORT3 out=Work.preProcessedData;
	by Date;
run;

proc arima data=Work.preProcessedData plots
    (only)=(series(corr crosscorr) residual(corr normal) 
		forecast(forecastonly));
	identify var=CO2(1);
	estimate p=(1 2) q=(1) method=ML;
	forecast lead=12 back=0 alpha=0.05 id=Date interval=month;
	outlier;
	run;
quit;

proc delete data=Work.preProcessedData;
run;


