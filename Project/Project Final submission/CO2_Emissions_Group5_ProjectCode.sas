proc import out= work.Proj
datafile= "/home/u58824655/CO2 Emission Data.xls"
dbms=xls replace; getnames=yes; datarow=2;
run;
proc print data=work.Proj;
title "CO2 Emission Data from 2010";
run;
symbol interpol=l;
/* STEP 3 -- fit a regression model, linear time trend */
proc gplot data = work.Proj;
plot CO2*time;
proc reg data= work.Proj;
model CO2 = Time/noint clm cli;
output out = results predicted = yhat residual=resid;
proc gplot data = work.Proj;
plot resid*Time;
run;
data work.Proj;
input CO2 time;
datalines;
0.73 1
0.79 2
0.91 3
0.85 4
0.73 5
0.62 6
0.59 7
0.63 8
0.59 9
0.69 10
0.77 11
0.46 12
0.48 13
0.51 14
0.62 15
0.62 16
0.51 17
0.57 18
0.71 19
0.71 20
0.54 21
0.63 22
0.56 23
0.53 24
0.45 25
0.48 26
0.56 27
0.68 28
0.75 29
0.63 30
0.53 31
0.62 32
0.72 33
0.74 34
0.73 35
0.52 36
0.67 37
0.56 38
0.65 39
0.53 40
0.58 41
0.66 42
0.57 43
0.66 44
0.78 45
0.67 46
0.78 47
0.65 48
0.73 49
0.52 50
0.76 51
0.77 52
0.85 53
0.66 54
0.56 55
0.81 56
0.88 57
0.81 58
0.66 59
0.77 60
0.81 61
0.87 62
0.9 63
0.75 64
0.75 65
0.79 66
0.71 67
0.79 68
0.82 69
1.07 70
1.03 71
1.1 72
1.15 73
1.35 74
1.31 75
1.07 76
0.91 77
0.77 78
0.82 79
1 80
0.88 81
0.9 82
0.91 83
0.83 84
0.98 85
1.13 86
1.13 87
0.92 88
0.89 89
0.7 90
0.82 91
0.87 92
0.76 93
0.88 94
0.86 95
0.89 96
0.77 97
0.85 98
0.91 99
0.87 100
0.81 101
0.74 102
0.78 103
0.73 104
0.76 105
0.99 106
0.78 107
0.89 108
0.87 109
0.92 110
1.11 111
0.97 112
0.85 113
0.86 114
.    115
.    116
.    117
.    118
.    119
.    120
run;
symbol interpol=l;
proc gplot data = work.Proj;
plot CO2*time;
proc reg data = work.Proj;
model CO2 = time/clm cli dw;
output out = results predicted = yhat residual = CO2;
proc gplot data = work.Proj;
plot CO2*time;
run;

/*proc glm data= work.Proj;
model CO2=Time Time*Time/clm cli dw;
run;
*/
/* STEP 3 -- fit a regression model, linear time trend */

/* STEP 4 -- fit a regression model, quadratic model */
proc glmselect data=work.Proj;
	model CO2=Time Time*Time /showpvalues selection=none;
run;


/* STEP 5 -- create 11 dummy variables to represent the 12 months */

/* STEP 5 -- create 11 dummy variables to represent the 12 months */

Data CO2Data_Months;
Set work.PROJ;
JAN = 0; Feb = 0; Mar = 0; Apr = 0; May = 0; Jun = 0; Jul=0; Aug = 0; Sep= 0; Oct=0; Nov=0;
If Mod(Time, 12) = 1 then Jan = 1;
If Mod(Time, 12) = 2 then Feb = 1;
If Mod(Time, 12) = 3 then Mar = 1;
If Mod(Time, 12) = 4 then Apr = 1;
If Mod(Time, 12) = 5 then May = 1;
If Mod(Time, 12) = 6 then Jun = 1;
If Mod(Time, 12) = 7 then Jul = 1;
If Mod(Time, 12) = 8 then Aug = 1;
If Mod(Time, 12) = 9 then Sep = 1;
If Mod(Time, 12) = 10 then Oct = 1;
If Mod(Time, 12) = 11 then Nov = 1;
;
proc print data = CO2Data_Months;
title "CO2Data_Months";
run;
/* STEP 5 -- fit another regression model using time and month as predictors */

Proc Reg data=CO2Data_Months;
model CO2 = Time JAN Feb Mar Apr May Jun Jul Aug Sep Oct Nov/DW;
output out=tempfile r=residual;
plot r.*time;
title "CO2 regressed on Time and Month";
run;
data Proj2; 
	Set Proj; 
	Time=_n_; 
	LnCO2=Log(CO2); 
	SqrtCO2=CO2**.5; 
	QtrootCO2=CO2**.25; 
run; 
Proc gplot data = work.Proj2; 
	Plot CO2*Time; 
	Plot SqrtCO2*Time; 
	plot QtrootCO2*Time; 
	plot LnCO2*Time; 
run;
/*  This program demonstrates the classical decomposition of a time series:
         Y = T + C + S + I where
         Y = time series to be described
         T = Trend
         C = Cycle
         S = Seasonal
         I = Irregular           */
     
/*  This segment of the program generates a Deterministic Trend. */

data Proj;

do t = 1 to 100;
  
tr = 100.0 + 4.0*t;

  output;

end;

keep tr t;

proc gplot data=Proj;
  symbol v=dot c=black i=join h=.8;
  title1 'Deterministic Trend Data';
  title2 'X=Time Y=Trend Series';
  axis1 order=(0 to 100 by 10)
  label=(f=duplex 'Time');
  axis2 order=(-100 to 700 by 100)
  label=(f=duplex 'Trend Series');
  plot tr*t / haxis=axis1 vaxis=axis2;

  run;

/*  This segment of the program generates a Deterministic Cycle. */

data Proj2;

do t = 1 to 100;

c = 50*cos(3.1416*t/10);

 output;

end;

keep c t;

proc gplot data=Proj2;
  symbol v=dot c=black i=join h=.8;
  title1 'Cycle with a=50, w = 2pi/20 (period = 20 months), theta = 0';
  title2 'X=Time Y=Cyclical Series';
  axis1 order=(0 to 100 by 10)
  label=(f=duplex 'Time');
  axis2 order=(-150 to 150 by 30)
  label=(f=duplex 'Cycle');
  plot c*t / haxis=axis1 vaxis=axis2;

  run;
/*  This program demonstrates the classical decomposition of a time series:
         Y = T + C + S + I where
         Y = time series to be described
         T = Trend
         C = Cycle
         S = Seasonal
         I = Irregular           */
     
/*  This segment of the program generates a Deterministic Trend. */

data Proj;

do t = 1 to 100;
  
tr = 100.0 + 4.0*t;

  output;

end;

keep tr t;

proc gplot data=Proj;
  symbol v=dot c=black i=join h=.8;
  title1 'Deterministic Trend Data';
  title2 'X=Time Y=Trend Series';
  axis1 order=(0 to 100 by 10)
  label=(f=duplex 'Time');
  axis2 order=(-100 to 700 by 100)
  label=(f=duplex 'Trend Series');
  plot tr*t / haxis=axis1 vaxis=axis2;

  run;

/*  This segment of the program generates a Deterministic Cycle. */

data Proj2;

do t = 1 to 100;

c = 50*cos(3.1416*t/10);

 output;

end;

keep c t;

proc gplot data=Proj2;
  symbol v=dot c=black i=join h=.8;
  title1 'Cycle with a=50, w = 2pi/20 (period = 20 months), theta = 0';
  title2 'X=Time Y=Cyclical Series';
  axis1 order=(0 to 100 by 10)
  label=(f=duplex 'Time');
  axis2 order=(-150 to 150 by 30)
  label=(f=duplex 'Cycle');
  plot c*t / haxis=axis1 vaxis=axis2;

  run;
 /*end of chapter 7
/* chapter 8 exponetial smoothing
/* STEP 1 */
proc import out= Proj
datafile= "/home/u58824655/CO2 Emission Data.xls"
dbms=xls replace; getnames=yes; datarow=2;
run;
proc print data= Proj;
title "CO2 Emission Data from 2010";
run;
symbol interpol=l;
Data Actuals;
Set Proj end = myendoffile;
Actual = CO2; 
If NOT myendoffile then output;
If myendoffile then do;
  output;
  Do I = 1 to 5;
    Actual = "."; output;
  end;
end;
Keep Actual;
proc print data=Actuals;
title2 "Actual Data";


/* STEP 2 */

proc forecast data=Proj out=myout1 /*outfull*/ trend = 2 
  method=Winters 
  weight = .1 lead=5 /*outlimit*/
  out1step outest=est1 interval = month;
  id Date;
  var CO2;

proc print data=myout1;
  title2 "myout1";


/* STEP 3 */

Data MyForecast;
  Set Actuals; Set myout1;
  PredCO2WintersAlphapt1 = CO2;
  Keep MyDate Actual PredCO2WintersAlphapt1;

proc print data = MyForecast;
title2 "MyForecast - Winters alpha = .1 and Actual"; 

proc forecast data=Proj out=myout2 /*outfull*/ trend = 2 method=Winters weight = .3 lead=5 /*outlimit*/
  out1step outest=est1 interval = month;
  id Date;
  var CO2;

proc print data=myout2;
title2 "myout2";


/* STEP 4 */

Data MyForecast;
  Set MyForecast; Set myout2;
  PredCO2WintersAlphapt2 = CO2 ;
  Keep Date Actual PredCO2WintersAlphaPT1 PredCo2WintersAlphapt2;

proc print data = MyForecast;

title2 "MyForecast - Winters alpha = .1 and .2 and Actual"; 
proc forecast data=Proj out=myout3 /*outfull*/ trend = 2 method=Winters weight = .2 lead=5 /*outlimit*/
  out1step outest=est1 interval = month; /***no trend since trend =1***/
  id Date;
  var CO2;
  proc print data=myout3;
title2 "myout3";

Data MyForecast;
  Set MyForecast; Set myout3;
  PredCO2noTrendAlphaPT2 = CO2 ;
  Keep Date Actual PredCO2WintersAlphaPT1 PredCO2WintersAlphapt2 PredCO2noTrendAlphaPT2;

proc print data = MyForecast;
title2 "MyForecast - Winters alpha = .1 and .2 and No Trend alpha = .2 and Actual"; 


/* STEP 5 */

data ttrend;
      set MyForecast;
      t+1;
   run;
   Proc print data=ttrend;
   title2 "ttrend data";
/*
Use PROC REG to create an output data set, myout4, containing the predicted values from a regression of Co2 on a time trend.
*/

proc reg data=ttrend;
    model Actual = t;
    output out=myout4 p=ptrend;
run;

proc print data=myout4;
title2 "myout4";


/* STEP 6 */

/* -------  Graphics Output  ------- */

goptions cback=white ctitle=black ctext=black /*border*/
         ftitle="Times New Roman" ftext="Times New Roman" htext=1.5;

   title h=4 'CO2 Emission Data' ;
   title2 h=2 'Plot of Forecast for CO2 Emission' ;
   symbol1 i=spline width=1 v=dot  c=black;  /* for actual */
   symbol2 i=spline width=2 v=none c=red;    /* for Winters alpha = .1 */
   symbol3 i=spline width=2 v=none c=green;  /* for Winters alpha = .3 */
   symbol4 i=spline width=2 v=none c=maroon;  /* for No Trend Alpha =.2 */
   symbol5 i=spline width=2 v=none c=blue;   /* for ptrend forecast */

axis1 offset=(1 cm)
         label=('Year') /*minor=none*/
         order=('01jan2010'd to '07jan2019'd by year);

axis2 label=(angle=90 'CO2 Emissions')
         order=(0.30 to 1.50 by 0.05);


/* STEP 7 */

legend1 across=1
           cborder=black
           position=(top inside right)
           offset=(-4,0)
           value=(tick=1 'ACTUAL'
                  tick=2 'Winters Alpha=.1 '
                  tick=3 'Winters Alpha=.3 '
		  tick=4 'NoTrend Alpha=.2 '
                  tick=5 'TIME TREND')
           shape=symbol(5,.7)
           mode=share 
         /*  label=none; */;

/* STEP 8 */

proc gplot data=myout4;
      format Date year4.;
      plot actual * Date = 1
           PredCO2WintersAlphaPT1 * Date = 2
           PredCO2WintersAlphaPT2 * Date = 3
	     PredCo2noTrendAlphaPT2 * Date = 4
           ptrend * Date = 5 / overlay noframe
                               href='01jan2010'd
                               chref=green
                               vaxis=axis2
                               vminor=1
                               haxis=axis1
                               legend=legend1;
run;
proc import out= work.Proj
datafile= "/home/u58824655/CO2 Emission Data.xls"
dbms=xls replace; getnames=yes; datarow=2;
run;
data Proj;
input CO2;
time=_n_;
z=dif1(CO2); 
datalines;
0.73
0.79
0.91
0.85
0.73
0.62
0.59
0.63
0.59
0.69
0.77
0.46
0.48
0.51
0.62
0.62
0.51
0.57
0.71
0.71
0.54
0.63
0.56
0.53
0.45
0.48
0.56
0.68
0.75
0.63
0.53
0.62
0.72
0.74
0.73
0.52
0.67
0.56
0.65
0.53
0.58
0.66
0.57
0.66
0.78
0.67
0.78
0.65
0.73
0.52
0.76
0.77
0.85
0.66
0.56
0.81
0.88
0.81
0.66
0.77
0.81
0.87
0.9
0.75
0.75
0.79
0.71
0.79
0.82
1.07
1.03
1.1
1.15
1.35
1.31
1.07
0.91
0.77
0.82
1
0.88
0.9
0.91
0.83
0.98
1.13
1.13
0.92
0.89
0.7
0.82
0.87
0.76
0.88
0.86
0.89
0.77
0.85
0.91
0.87
0.81
0.74
0.78
0.73
0.76
0.99
0.78
0.89
0.87
0.92
1.11
0.97
0.85
0.86
0.9
run;
proc print data=work.Proj;
run;
symbol interpol=l;
/*programming commands for procedures to plot data and find SAC and SPAC*/

proc gplot data=work.Proj;
plot CO2*time;
plot z*time; 
run;
symbol interpol=l;
/* code below used to check if time series is stationary or not*/
proc arima data=work.Proj; /*PROC ARIMA*/
identify var=CO2; /*Generate SAC and SPAC for y_t*/  
identify var=CO2(1);  /*Generate SAC and SPAC for z_t first differencing*/
run;
/*SAS commands for estimation and forecasting with PROC ARIMA noconstant means no delta ARIMA (0,1,1)*/
proc arima data=work.Proj;
identify var=CO2(1);
estimate q=(1) noconstant printall plot;
estimate q=(1) printall plot;
forecast lead=12;
run;
/*this is code to difference for comparing AR model just to see. Comparing only use*/
/*since after differencing, our SAC cuts off after lag one and Spac dies down the first good model is AR(1)*/
/*this will be for comparing complex models*/
data Proj;
input CO2;
time=_n_; 
datalines;
0.73
0.79
0.91
0.85
0.73
0.62
0.59
0.63
0.59
0.69
0.77
0.46
0.48
0.51
0.62
0.62
0.51
0.57
0.71
0.71
0.54
0.63
0.56
0.53
0.45
0.48
0.56
0.68
0.75
0.63
0.53
0.62
0.72
0.74
0.73
0.52
0.67
0.56
0.65
0.53
0.58
0.66
0.57
0.66
0.78
0.67
0.78
0.65
0.73
0.52
0.76
0.77
0.85
0.66
0.56
0.81
0.88
0.81
0.66
0.77
0.81
0.87
0.9
0.75
0.75
0.79
0.71
0.79
0.82
1.07
1.03
1.1
1.15
1.35
1.31
1.07
0.91
0.77
0.82
1
0.88
0.9
0.91
0.83
0.98
1.13
1.13
0.92
0.89
0.7
0.82
0.87
0.76
0.88
0.86
0.89
0.77
0.85
0.91
0.87
0.81
0.74
0.78
0.73
0.76
0.99
0.78
0.89
0.87
0.92
1.11
0.97
0.85
0.86
0.9
run;
symbol interpol=l;
proc gplot data=work.Proj;
plot CO2*time;
run;
/*Next comparing ARIMA (1,0,0) AR(1) model for our behavior since SPAC cuts off at lag 3 after only spike*/
/*and SAC dies quickly*/
proc arima data=work.Proj;
identify var=CO2(1);
estimate p=(1,3) noconstant printall plot;
estimate p=(1,3) printall plot;
run;
proc arima data=work.Proj;
identify var=CO2(1);
estimate p=(1) method=ml printall plot;
forecast lead=12;
run;

/*Next comparing ARMA model asuming lag 2 and lag 3 spike for SAC*/
/*and lag 1 and 2 spike for SPAC*/
proc arima data=work.Proj;
identify var=CO2(1);
estimate p=(1,2) printall plot;
estimate q=(1,3) printall plot;
estimate q=(1,3) p=(1,2) printall plot;
run;
/*ARIMA (1,1,1)*/
proc arima data=work.Proj;
identify var=CO2(1);
estimate p=(1) q=(1) noconstant printall plot;
forecast lead=12;
run;
/*ARIMA (2,1,3)*/
proc arima data=work.Proj;
identify var=CO2(1);
estimate p=(2) q=(3) printall plot;
run;
/*Scan function to see SAS suggested best ARIMA models*/
proc arima data=work.Proj;
identify var=CO2(1) scan stationarity=(adf);
run;
proc arima data=work.Proj;
identify var=CO2(1);
estimate p=(1,2) q=(3) noconstant printall plot;
estimate p=(1,2,5) q=(1,6) noconstant printall plot;
run;
/* STEP 1 */

title 'Time Series Analysis';
data CO2Emission;
input CO2;
datalines;
0.73
0.79
0.91
0.85
0.73
0.62
0.59
0.63
0.59
0.69
0.77
0.46
0.48
0.51
0.62
0.62
0.51
0.57
0.71
0.71
0.54
0.63
0.56
0.53
0.45
0.48
0.56
0.68
0.75
0.63
0.53
0.62
0.72
0.74
0.73
0.52
0.67
0.56
0.65
0.53
0.58
0.66
0.57
0.66
0.78
0.67
0.78
0.65
0.73
0.52
0.76
0.77
0.85
0.66
0.56
0.81
0.88
0.81
0.66
0.77
0.81
0.87
0.9
0.75
0.75
0.79
0.71
0.79
0.82
1.07
1.03
1.1
1.15
1.35
1.31
1.07
0.91
0.77
0.82
1
0.88
0.9
0.91
0.83
0.98
1.13
1.13
0.92
0.89
0.7
0.82
0.87
0.76
0.88
0.86
0.89
0.77
0.85
0.91
0.87
0.81
0.74
0.78
0.73
0.76
0.99
0.78
0.89
0.87
0.92
1.11
0.97
0.85
0.86
0.9
.
.
.
.
.
.
.
.
.
.
.
.
run;
proc print data=CO2Emission;
title "data=CO2Emission";
run;


/* STEP 2 */

Data CO2Emission_MovingAverage;
Set CO2Emission;
Array CO2Lag {12} CO2Lag0-CO2Lag11;
CO2Lag{1} = CO2;
do i = 2 to 12;
  CO2Lag{i} = Lag(CO2Lag{i-1});/*note Lag is a SAS function*/
end;
MovingAverage = 0;
do i = 1 to 12;
  MovingAverage = MovingAverage + CO2Lag{i};
end;
MovingAverage = MovingAverage/12;
CenteredMV = (MovingAverage + Lag(MovingAverage))/2;
Drop i; 
proc print data = CO2Emission_MovingAverage;
title "data = CO2Emission_MovingAverage";
run;



/* STEP 3 */

Data CO2Emission_MovingAverage;
Set CO2Emission_MovingAverage;
Keep CenteredMV;
If _N_ <=12 then delete;

Data CO2Emission_SeasonalIndex;
Set CO2Emission_MovingAverage; Set CO2Emission;
If CenteredMV = "." then SeasonalIndexInitial = 0;
Else SeasonalIndexInitial = CO2-CenteredMV;
proc print data = CO2Emission_SeasonalIndex;
title "data = CO2Emission_SeasonalIndex";



/* STEP 4 */

Data CO2Emission_SeasonalIndex;
set CO2Emission_SeasonalIndex end=myEOF;
Array SeasonalIndex {12} SeasIndex1-SeasIndex12;
Retain SeasIndex1-SeasIndex12 0;
Time = _N_;
Do i = 1 to 12;
   If Mod(Time, 12)= i then SeasonalIndex{i} = SeasonalIndex{i} + SeasonalIndexInitial;   
end;
If Mod(Time, 12)= 0 then SeasIndex12 = SeasIndex12 + SeasonalIndexInitial;
/*  Get average on next set of lines */ 
If myEOF then do;
  sum_of_indices =0;
  Do i = 1 to 12;
     SeasonalIndex{i} = SeasonalIndex{i}/ 11; 
     sum_of_indices = sum_of_indices + SeasonalIndex{i}; 
  End;
End;
/**Only keep last line**/
If ~myEOF then delete;
Keep sum_of_indices SeasIndex1-SeasIndex12 ;
run;

proc print data = CO2Emission_SeasonalIndex;
var sum_of_indices SeasIndex1-SeasIndex12;
title "Seasonal Indexes";
run;



/* STEP 5 */

Data DeseasonalizedData;
If _N_ =1 then Set CO2Emission_SeasonalIndex;  Set CO2Emission;
Array SeasonalIndex {12} SeasIndex1-SeasIndex12;
Time = _N_; 
Do i = 1 to 12;
   If Mod(Time, 12)= i then SeasonalEffect  = SeasonalIndex{i};  
end;
If Mod(Time, 12)= 0 then SeasonalEffect  = SeasonalIndex{12};  
DeseasonalizedCO2 = CO2-SeasonalEffect;
Keep  Time DeseasonalizedCO2 CO2 SeasonalEffect;
proc print data = DeseasonalizedData;
title "Deseasonalized Data";


/* STEP 6 */

Proc Reg data=DeseasonalizedData;
model DeseasonalizedCO2  = Time ;
output out=tempfile p=Trend;
title "DeseasonalizedCO2 regressed on Time";

proc print data = tempfile;
title "Predicted DeseasonalizedCO2 - Trend ";



/* STEP 7 */

Data Cyclical;
Set tempfile;
CyclicalInitial = DeseasonalizedCO2-Trend;

Data Cyclical;
Set Cyclical;
Array CyclicalLag {11} CyclicalLag1-CyclicalLag11;
CyclicalLag{1} = CyclicalInitial;
do i = 2 to 11;
  CyclicalLag{i} = Lag(CyclicalLag{i-1});/*note Lag is a SAS function*/
end;
CycMovingAverage = 0;
do i = 1 to 11;
  CycMovingAverage = CycMovingAverage + CyclicalLag{i};
end;
CycMovingAverage = CycMovingAverage/11;
Keep CycMovingAverage;
If _N_ = 1 then delete;
Drop i; 

proc print data = Cyclical;
title "data = Cyclical";
run;


/* STEP 8 */

Data Decomposition;
Set tempfile; Set Cyclical;
Irreg = CO2-(SeasonalEffect+Trend+CycMovingAverage);

proc print data = Decomposition;
Title "Decomposition";
Run;



/* STEP 9 */

proc reg data = Deseasonalizeddata;
model DeseasonalizedCO2 = Time/ cli clm;
title "CO2 Emission predicted values for new observations";
run;


proc forecast data = DeseasonalizedData lead=12 out=prediction;
var CO2;
run;

proc print data=prediction;
title "CO2 emissions forecasts for the next 12 months";
run;



proc arima data=work.Proj;
identify var=CO2(1) crosscor=(Time) noprint;
estimate input=(Time) p=1 q=(1,12) noconstant printall plot;
forecast lead=12;
run;

proc arima data=work.Proj;
identify var=CO2(1) crosscor=(Time) noprint;
estimate input=(Time) p=3 printall plot;
forecast lead=12;
run;

proc arima data=work.Proj;
identify var=CO2(1) crosscor=(Time) noprint;
estimate input=(Time) q=3 printall plot;
forecast lead=12;
run;
proc arima data=work.Proj;
identify var=CO2(1) crosscor=(Time) noprint;
estimate input=(Time) q=3 noconstant printall plot;
forecast lead=12;
run;
