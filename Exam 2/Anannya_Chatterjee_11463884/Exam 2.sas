/*Question 2*/

/*Exercise 6.4a*/
data energybill;
input y t;
datalines;
344.39 1
246.63 2
131.53 3
288.87 4
313.45 5
189.76 6
179.10 7
221.10 8
246.84 9
209.00 10
51.21 11
133.89 12
277.01 13
197.98 14
50.68 15
218.08 16
365.10 17
207.51 18
54.63 19
214.09 20
267.00 21
230.28 22
230.32 23
426.41 24
467.06 25
306.03 26
253.23 27
279.46 28
336.56 29
196.67 30
152.15 31
319.67 32
440.00 33
315.04 34
216.42 35
339.78 36
434.66 37
399.66 38
330.80 39
539.78 40
run;
/*symbol value=none interpol=sm width=2;
proc gplot data=work.energybill;
plot y*t;
run;*/

symbol1 interpol=join
        value=dot;
proc gplot data=work.energybill;
plot y* t/haxis=1 to 40 by 1;




/6.4b: * applying transformation*/
data ebill2; 
	Set energybill; 
	t=_n_; 
	Lny=Log(y); 
	Sqrty=y**.5; 
	Qtrooty=y**.25; 
run; 
/*Note: Transformations must be done within a data step. */
/*Plot each of y, square root of y, quartic root of y, and natural logarithm of y versus Time (similar to JMP IN output in Figures 6.15 to 6.18)*/
symbol1 interpol=join
        value=dot;
Proc gplot data = work.ebill2; 
	Plot y*t; 
	Plot Sqrty*t; 
	plot Qtrooty*t; 
	plot Lny*t; 
run; 



/*6.4c: * Regression analysis using dummy variables*/

data energybill;
input y t;
datalines;
344.39 1
246.63 2
131.53 3
288.87 4
313.45 5
189.76 6
179.10 7
221.10 8
246.84 9
209.00 10
51.21 11
133.89 12
277.01 13
197.98 14
50.68 15
218.08 16
365.10 17
207.51 18
54.63 19
214.09 20
267.00 21
230.28 22
230.32 23
426.41 24
467.06 25
306.03 26
253.23 27
279.46 28
336.56 29
196.67 30
152.15 31
319.67 32
440.00 33
315.04 34
216.42 35
339.78 36
434.66 37
399.66 38
330.80 39
539.78 40
. 41 
. 42
. 43 
. 44
;
run;
data ebill3;
      set energybill;
      if mod(t,4)=1 then Q1=1; else Q1=0;
      if mod(t,4)=2 then Q2=1; else Q2=0;
      if mod(t,4)=3 then Q3=1; else Q3=0;
 timesq=t**2;
 
proc gplot data=energybill;
	plot y*t;
symbol color=bib value=dot interpol=spline; 

proc reg data = work.ebill3;
      model y = t timesq  Q1 Q2 Q3/CLM CLI clb DW;
run;


/*6.4d: * ARIMA analysis */

proc arima data = work.ebill3; 
	identify var = y 
	crosscor = (t timesq Q1 Q2 Q3 ) noprint; 
	estimate input = (t timesq Q1 Q2 Q3 ) printall plot; 
	
proc arima data = work.ebill3; 
	identify var = y 
	crosscor = (t timesq Q1 Q2 Q3 ) noprint; 
	estimate input = (t timesq Q1 Q2 Q3 ) p=(1) printall plot; 
	forecast lead = 4 out = work.fcast1; 
	
data fcast2; 
	set work.fcast1; 
	Forecasty = Exp(Forecast); 
	L95CI = Exp(L95); 
	U95CI = Exp(U95); 
proc print data = work.fcast2; 
	var Forecasty L95CI U95CI; 
run; 

/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/

/*Question 3*/

/*Exercise 7.2*/
/*Here I am considering using the multiplicative decomposition method to forecast Oligopoly sales for year 4.*/

/* STEP 1 */
data OLsalesdata;
input sales;
datalines;
20
25
35
44
28
29
43
48
24
37
39
56
.
.
.
.
;
proc print data=OLSalesData;
title "data=Oligopoly Sales Data";
run;


/* STEP 2 */

Data SalesData_MovingAverage;
Set OLSalesData;
Array SalesLag {4} SalLag0-SalLag3;
SalesLag{1} = Sales;
do i = 2 to 4;
  SalesLag{i} = Lag(SalesLag{i-1});/*note Lag is a SAS function*/
end;
MovingAverage = 0;
do i = 1 to 4;
  MovingAverage = MovingAverage + SalesLag{i};
end;
MovingAverage = MovingAverage/4;
CenteredMV = (MovingAverage + Lag(MovingAverage))/2;
Drop i; 
proc print data = SalesData_MovingAverage;
title "data = Oligopoly SalesData_MovingAverage";
run;


/* STEP 3 */

Data SalesData_MovingAverage;
Set SalesData_MovingAverage;
Keep CenteredMV;
If _N_ <=2 then delete;
proc print data = SalesData_MovingAverage;
title "Updated";
run;

Data SalesData_SeasonalIndex;
Set SalesData_MovingAverage; Set OLSalesData;
If CenteredMV = "." then SeasonalIndexInitial = 0;
Else SeasonalIndexInitial = Sales/CenteredMV;
proc print data = SalesData_SeasonalIndex;
title "data = Oligopoly SalesData_SeasonalIndex";


/* STEP 4 */

Data SalesData_SeasonalIndex;
set SalesData_SeasonalIndex end=myEOF;
Array SeasonalIndex {4} SeasIndex1-SeasIndex4;
Retain SeasIndex1-SeasIndex4 0;
Time = _N_;
Do i = 1 to 4;
   If Mod(Time, 4)= i then SeasonalIndex{i} = (SeasonalIndex{i} + SeasonalIndexInitial);   
end;
If Mod(Time, 4)= 0 then SeasIndex4 = (SeasIndex4 + SeasonalIndexInitial);
/*  Get average on next set of lines */ 
If myEOF then do;
  sum_of_indices =0;
  Do i = 1 to 4;
     SeasonalIndex{i} = SeasonalIndex{i}/ 3; 
     sum_of_indices = sum_of_indices + SeasonalIndex{i}; 
  End;
End;
/**Only keep last line**/
If ~myEOF then delete;
Keep sum_of_indices SeasIndex1-SeasIndex4 ;
run;

proc print data = SalesData_SeasonalIndex;
var sum_of_indices SeasIndex1-SeasIndex4;
title "Seasonal Indexes";
run;


/* STEP 5 */

Data DeseasonalizedData;
If _N_ =1 then Set SalesData_SeasonalIndex;  Set OLSalesData;
Array SeasonalIndex {4} SeasIndex1-SeasIndex4;
Time = _N_; 
Do i = 1 to 4;
   If Mod(Time, 4)= i then SeasonalEffect  = SeasonalIndex{i};  
end;
If Mod(Time, 4)= 0 then SeasonalEffect  = SeasonalIndex{4};  
DeseasonalizedSales = Sales/SeasonalEffect;
Keep  Time DeseasonalizedSales Sales SeasonalEffect;
proc print data = DeseasonalizedData;
title "Deseasonalized Data";


/* STEP 6 */

Proc Reg data=DeseasonalizedData;
model DeseasonalizedSales  = Time ;
output out=tempfile p=Trend;
title "Deseasonalized Oligopoly Sales regressed on Time";

proc print data = tempfile;
title "Predicted DeseasonalizedSales - Trend ";


/* STEP 7 */

Data Cyclical;
Set tempfile;
CyclicalInitial = DeseasonalizedSales /Trend;


Data Cyclical;
Set Cyclical;
Array CyclicalLag {3} CyclicalLag1-CyclicalLag3;
CyclicalLag{1} = CyclicalInitial;
do i = 2 to 3;
  CyclicalLag{i} = Lag(CyclicalLag{i-1});/*note Lag is a SAS function*/
end;
CycMovingAverage = 0;
do i = 1 to 3;
  CycMovingAverage = CycMovingAverage + CyclicalLag{i};
end;
CycMovingAverage = CycMovingAverage/3;
Keep CycMovingAverage;
If _N_ = 1 then delete;
Drop i; 
proc print data = Cyclical;
title "data = Cyclical";
run;


/* STEP 8 */

Data Decomposition;
Set tempfile; Set Cyclical;
Irreg = Sales/(SeasonalEffect*Trend*CycMovingAverage);

proc print data = Decomposition;
Title "Decomposition";
 Run;


/* STEP 9 */
Proc Reg data=DeseasonalizedData;
	model DeseasonalizedSales  = Time / cli clm;
	run;
proc forecast data = DeseasonalizedData lead=4 out=prediction;
var Sales;
run;

proc print data=prediction;
title "Sales forecasts for each of the quater of year 4 based on Multiplicative Decomposition";
run;
Quit;


/*Exercise 7.4*/
/*Here I am considering using the additive decomposition method to forecast Oligopoly sales for year 4.*/


/* STEP 1 */
data OLsalesdata;
input sales;
datalines;
20
25
35
44
28
29
43
48
24
37
39
56
.
.
.
.
;
proc print data=OLSalesData;
title "data=Oligopoly Sales Data";
run;


/* STEP 2 */

Data SalesData_MovingAverage;
Set OLSalesData;
Array SalesLag {4} SalLag0-SalLag3;
SalesLag{1} = Sales;
do i = 2 to 4;
  SalesLag{i} = Lag(SalesLag{i-1});/*note Lag is a SAS function*/
end;
MovingAverage = 0;
do i = 1 to 4;
  MovingAverage = MovingAverage + SalesLag{i};
end;
MovingAverage = MovingAverage/4;
CenteredMV = (MovingAverage + Lag(MovingAverage))/2;
Drop i; 
proc print data = SalesData_MovingAverage;
title "data = Oligopoly Sales (Additive) SalesData_MovingAverage";
run;


/* STEP 3 */

Data SalesData_MovingAverage;
Set SalesData_MovingAverage;
Keep CenteredMV;
If _N_ <=2 then delete;
proc print data = SalesData_MovingAverage;
title "Updated";
run;

Data SalesData_SeasonalIndex;
Set SalesData_MovingAverage; Set OLSalesData;
If CenteredMV = "." then SeasonalIndexInitial = 0;
Else SeasonalIndexInitial = Sales-CenteredMV;
proc print data = SalesData_SeasonalIndex;
title "data = Oligopoly Sales (Additive) SalesData_SeasonalIndex";


/* STEP 4 */

Data SalesData_SeasonalIndex;
set SalesData_SeasonalIndex end=myEOF;
Array SeasonalIndex {4} SeasIndex1-SeasIndex4;
Retain SeasIndex1-SeasIndex4 0;
Time = _N_;
Do i = 1 to 4;
   If Mod(Time, 4)= i then SeasonalIndex{i} = (SeasonalIndex{i} + SeasonalIndexInitial);   
end;
If Mod(Time, 4)= 0 then SeasIndex4 = (SeasIndex4 + SeasonalIndexInitial);
/*  Get average on next set of lines */ 
If myEOF then do;
  sum_of_indices =0;
  Do i = 1 to 4;
     SeasonalIndex{i} = SeasonalIndex{i}/ 3; 
     sum_of_indices = sum_of_indices + SeasonalIndex{i}; 
  End;
End;
/**Only keep last line**/
If ~myEOF then delete;
Keep sum_of_indices SeasIndex1-SeasIndex4 ;
run;

proc print data = SalesData_SeasonalIndex;
var sum_of_indices SeasIndex1-SeasIndex4;
title "Oligopoly Sales (Additive) Seasonal Indexes";
run;


/* STEP 5 */

Data DeseasonalizedData;
If _N_ =1 then Set SalesData_SeasonalIndex;  Set OLSalesData;
Array SeasonalIndex {4} SeasIndex1-SeasIndex4;
Time = _N_; 
Do i = 1 to 4;
   If Mod(Time, 4)= i then SeasonalEffect  = SeasonalIndex{i};  
end;
If Mod(Time, 4)= 0 then SeasonalEffect  = SeasonalIndex{4};  
DeseasonalizedSales = Sales-SeasonalEffect;
Keep  Time DeseasonalizedSales Sales SeasonalEffect;
proc print data = DeseasonalizedData;
title "Oligopoly Sales (Additive) Deseasonalized Data";


/* STEP 6 */

Proc Reg data=DeseasonalizedData;
model DeseasonalizedSales  = Time ;
output out=tempfile p=Trend;
title "Deseasonalized Oligopoly Sales regressed on Time";

proc print data = tempfile;
title "Oligopoly Sales (Additive) Predicted DeseasonalizedSales - Trend ";


/* STEP 7 */

Data Cyclical;
Set tempfile;
CyclicalInitial = DeseasonalizedSales-Trend;


Data Cyclical;
Set Cyclical;
Array CyclicalLag {3} CyclicalLag1-CyclicalLag3;
CyclicalLag{1} = CyclicalInitial;
do i = 2 to 3;
  CyclicalLag{i} = Lag(CyclicalLag{i-1});/*note Lag is a SAS function*/
end;
CycMovingAverage = 0;
do i = 1 to 3;
  CycMovingAverage = CycMovingAverage + CyclicalLag{i};
end;
CycMovingAverage = CycMovingAverage/3;
Keep CycMovingAverage;
If _N_ = 1 then delete;
Drop i; 
proc print data = Cyclical;
title "Oligopoly Sales (Additive) data = Cyclical";
run;


/* STEP 8 */

Data Decomposition;
Set tempfile; Set Cyclical;
Irreg = Sales-(SeasonalEffect+Trend+CycMovingAverage);

proc print data = Decomposition;
Title "Oligopoly Sales (Additive) Decomposition";
 Run;


/* STEP 9 */
Proc Reg data=DeseasonalizedData;
	model DeseasonalizedSales  = Time / cli clm;
	title "Oligopoly Sales predicted values for new observations";
	run;
proc forecast data = DeseasonalizedData lead=4 out=prediction;
var Sales;
run;

proc print data=prediction;
title "Sales forecasts for each of the quater of year 4 based on Additive Decomposition";
run;
Quit;

/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/

/*Question 5*/


data stockprice;
input y;
time=_n_;
z=dif1(y);      /*z=y_t-y_{t-1}*/
datalines;
460
457
452
459
462
459
463
479
493
490
492
498
499
497
496
490
489
478
487
491
487
482
479
478
479
477
479
475
479
476
476
478
479
477
476
475
475
473
474
474
474
465
466
467
471
471
467
473
481
488
490
489
489
485
491
492
494
499
498
500
497
494
495
500
504
513
511
514
510
509
515
519
523
519
523
531
547
551
547
541
545
549
545
549
547
543
540
539
532
517
527
540
542
538
541
541
547
553
559
557
557
560
571
571
569
575
580
584
585
590
599
603
599
596
585
587
585
581
583
592
592
596
596
595
598
598
595
595
592
588
582
576
578
589
585
580
579
584
581
581
577
577
578
580
586
583
581
576
571
575
575
573
577
582
584
579
572
577
571
560
549
556
557
563
564
567
561
559
553
553
553
547
550
544
541
532
525
542
555
558
551
551
552
553
557
557
548
547
545
545
539
539
535
537
535
536
537
543
548
546
547
548
549
553
553
552
551
550
553
554
551
551
545
547
547
537
539
538
533
525
513
510
521
521
521
523
516
511
518
517
520
519
519
519
518
513
499
485
454
462
473
482
486
475
459
451
453
446
455
452
457
449
450
435
415
398
399
361
383
393
385
360
364
365
370
374
359
335
323
306
333
330
336
328
316
320
332
320
333
344
339
350
351
350
345
350
359
375
379
376
382
370
365
367
372
373
363
371
369
376
387
387
376
385
385
380
373
382
377
376
379
386
387
386
389
394
393
409
411
409
408
393
391
388
396
387
383
388
382
384
382
383
383
388
395
392
386
383
377
364
369
355
350
353
340
350
349
358
360
360
366
359
356
355
367
357
361
355
348
343
330
340
339
331
345
352
346
352
357
run;
proc print data=work.stockprice;
run;
symbol1 interpol=join
        value=dot;
proc gplot data=work.stockprice;
plot y*time;
plot z*time;

proc arima data=work.stockprice; /*PROC ARIMA*/
identify var=y scan stationarity=(adf);      /*Generate SAC and SPAC for y_t*/
identify var=y(1) scan stationarity=(adf);  /*Generate SAC and SPAC for z_t* for checking stationarity/
run;  


proc arima data=work.stockprice; /*PROC ARIMA*/
identify var=y(1) scan stationarity=(adf);
estimate p=(6) noconstant printall plot;
estimate p=(6) printall plot;
estimate q=(6) noconstant printall plot;
estimate q=(6) printall plot;
run;


/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/



***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/*Question 6:*/

data sports;
input y;
time=_n_;
Lny=log(y);
Sqrty=y**.5;
QtRooty=y**.25;
datalines;
730
717
769
858
921
1018
980
1027
906
847
981
1502
821
871
938
1044
1097
1155
1069
1150
981
915
1087
1698
892
942
1095
1099
1186
1215
1125
1283
1143
1030
1233
1934
1000
1052
1240
1182
1298
1321
1210
1340
1178
1117
1192
1857
945
991
1151
1190
1287
1332
1299
1430
1236
1091
1205
1908
998
1122
1234
1278
1300
1335
1336
1370
1198
1112
1197
2137
1033
984
1217
1372
1395
1465
1467
1543
1325
1210
1390
2499
1178
1205
1502
1566
1566
1694
1600
1755
1485
1339
1488
2640
1239
1265
1621
1629
1668
1774
1730
1873
1593
1419
1571
2771
1346
1327
1672
1727
1801
1925
1865
2029
1629
1488
1651
2749
1392
1388
1683
1793
1860
2052
1924
2048
1671
1596
1738
2990
1458
1485
1848
1919
2043
2231
2081
2143
1779
1678
1764
2979
run;
proc print data=work.sports;
run;
symbol1 interpol=join
        value=dot;
proc gplot data=work.sports;
plot y*time;
plot Lny*time;

proc arima data=work.sports;
/*identify var=Lny;
identify var=Lny(1);   */
identify var=Lny(12);
identify var=Lny(1,12);  
run;

/**********************************************************************************************************/

/*Question 1*/

%let NObs = 48;
data Unif(keep=u x k n m);
call streaminit(123);
a = -1; b = 1;
Min = 5; Max = 10;
do i = 1 to &NObs;
   u = rand("Uniform");            /* decimal values in (0,1)    */
   x = a + (b-a)*u;                /* decimal values (a,b)       */
   k = ceil( Max*u );              /* integer values in 1..Max   */
   n = floor( (1+Max)*u );         /* integer values in 0..Max   */
   m = min + floor((1+Max-Min)*u); /* integer values in Min..Max */
   output;
end;
run;

proc univariate data=Unif;
var u x;
histogram u/ endpoints=0 to 1 by 0.05;
histogram x/ endpoints=-1 to 1 by 0.1;
run;
 
proc freq data=Unif;
tables k n m / chisq;
run;

