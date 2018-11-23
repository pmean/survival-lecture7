* class7.sas
  written by Steve Simon
  October 28, 2018;

** preliminaries **;

%let path=/folders/myfolders;
%let xpath=c:/Users/simons/Documents/SASUniversityEdition/myfolders;

ods pdf file="&path/survival-lecture7/sas/class7.pdf";

libname survival
  "&path/data";
  
* crack1 is an example of left/right censored data.
;
  
data survival.crack1;
  infile "&path/data/crack1.txt";
  input t0 t1 n;
run;

proc print
    data=survival.crack1(obs=5);
  title1 "Partial listing of crack1 data";
run;


proc lifereg
    data=survival.crack1;
  model (t0, t1)= / distribution=exponential;
  output
    out=prob0
    cdf=exponential_p;
  weight n;
  title "Exponential fit to crack1 data";
run;

data prob0;
  set prob0;
  if t0 = . then delete;
  exponential_s = 1 - exponential_p;
  keep t0 exponential_s;
run;

data prob1;
  set survival.crack1;
  if t1 = . then delete;
  t0=t1;
  np=n;
  keep t0 np;
run;

data prob2;
  set survival.crack1;
  if t0 = . then delete;
  nq=n;
  keep t0 nq;
run;

data prob3;
  merge prob0 prob1 prob2;
  by t0;
  observed_s = 1 - np / (np+nq);
run;

proc print data=prob3;
  title1 "Comparison of observed and predicted survival";
run;

proc sgplot
    data=prob3;
  scatter x=t0 y=observed_s;
  series x=t0 y=exponential_s;
  yaxis min=0;
run;

* crack2 is an example of interval censored data.
;

data survival.crack2;
  infile "&path/data/crack2.txt";
  input t0 t1 n c;
run;

proc print
    data=survival.crack2(obs=5);
  title1 "Partial listing of crack2 data";
run;

proc lifereg
    data=survival.crack2;
  model (t0, t1)= / distribution=exponential;
  output
    out=prob4
    cdf=exponential_p;
  weight n;
  title "Exponential fit to crack2 data";
run;

data prob4;
  set prob4;
  if t0 ^= .;
  t=t0;
  exponential_s = 1 - exponential_p;
  keep t exponential_s;
run;

data prob5;
  set survival.crack2;
  if t1 = . then delete;
  t=t1;
  observed_s = 1 - (c / 167);
  keep t n observed_s;
run;

data prob6;
  merge prob4 prob5;
  by t;
run;

proc print
    data=prob6;
  title "Comparison of observed and predicted probabilities";
run;

proc sgplot
    data=prob6;
  scatter x=t y=observed_s;
  series x=t y=exponential_s;
  yaxis min=0;
run;

* psychiatric patients. This data set can be found at 

math.usu.edu/jrstevens/biostat/projects2013/pres_LeftTruncation.pdf

  It illustrates an application of left truncation.
;

proc import
    datafile="&path/data/psychiatric patients.csv" 
    dbms=dlm
    out=survival.psych;
    delimiter=",";
    getnames=yes;
run;

proc print
    data=survival.psych(obs=10);
  title1 "Psychiatric patients";
run;

data survival.psych;
  set survival.psych;
  age2=age+time;
run;

proc phreg
    data=survival.psych;
  model (age, age2)*death(0)=sex;
run;
    
* rats data set (found in survival package in R);

proc import
    datafile="&path/data/rats.csv"
    dbms=dlm
    out=survival.rats;
    delimiter=",";
    getnames=yes;
run;

proc print
    data=survival.rats(obs=10);
  title1 "Rats litter example";
run;
    
* Notice that within every litter, you have one
  treated animal (rx=1) and two controls (rx=0).    
;
    
proc freq 
    data=survival.rats;
  tables litter*rx /
    norow nocol nopercent;
  where litter <= 10;
  title2 "Relationship between litter and rx";
run;

* Also notice the small number of events among the
  male rats. I will analyze only the females from
  this point forward.
;

proc freq 
    data=survival.rats;
  tables sex*status /
    norow nocol nopercent;
  title2 "Relationship between sex and status";
run;

proc phreg
    data=survival.rats;
  model time*status(0)=rx;
  id litter;
  where sex="f";
  title2 "Cluster (marginal) model";
run;

proc phreg
    data=survival.rats;
  class litter;
  model time*status(0)=rx;
  random litter;
  where sex="f";
  title2 "Frailty (random) model";
run;

ods pdf close;
