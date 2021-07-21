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
Else SeasonalIndexInitial = CO2/CenteredMV;
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
DeseasonalizedCO2 = CO2/SeasonalEffect;
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
CyclicalInitial = DeseasonalizedCO2 /Trend;

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
Irreg = CO2/(SeasonalEffect*Trend*CycMovingAverage);

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
title "Sales forecasts for the next 12 months";
run;
Quit;


