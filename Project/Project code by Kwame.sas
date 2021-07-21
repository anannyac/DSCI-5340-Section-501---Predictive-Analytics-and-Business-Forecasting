proc import out= work.Proj
datafile= "/home/u58824655/CO2 Emission Data.xls"
dbms=xls replace; getnames=yes; datarow=2;
run;
proc print data=work.Proj;
title "CO2 Emission Data from 1920";
run;
symbol interpol=l;
/* STEP 3 -- fit a regression model, linear time trend */
proc reg data= work.Proj;
model CO2 = Time/clm cli dw;
plot r.*Time;
title "CO2 regressed on Time";
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
title "CO2 Emission Data from 1920";
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

proc forecast data=Proj out=myout1 /*outfull*/ trend = 3 
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

proc forecast data=Proj out=myout2 /*outfull*/ trend = 3 method=Winters weight = .3 lead=5 /*outlimit*/
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
proc forecast data=Proj out=myout3 /*outfull*/ trend = 3 method=Winters weight = .2 lead=5 /*outlimit*/
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
Use PROC REG to create an output data set, myout4, containing the predicted values from a regression of LEADPROD on a time trend.
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

  